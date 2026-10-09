import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/paid_content_dialog.dart';
import 'package:coursaty_student_and_teacher/app/widgets/you_are_guest_dialog.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/video_segement_item.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/secure_video_models.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/models/video_security_errors.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/secure_offline_playback_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_access_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_device_key_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_model.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/common/constant/design/app_assets.dart';
import '../../core/routes/router.dart';
import '../../core/storage/prefs_repository.dart';
import '../../core/theme/app_colors.dart';
import 'chip_widget.dart';

class MyVideoWidgetBetterPlayer extends StatefulWidget {
  const MyVideoWidgetBetterPlayer({
    super.key,
    this.filePath,
    this.isFromNetwork = false,
    required this.videoName,
    required this.videoId,
    required this.duration,
    required this.segments,
    this.videoUrl,
    this.preferredResolution = '720p',
    this.videoDescription,
    this.teacher,
    required this.courseId,
  });

  final List<Segment> segments;
  final String videoName;
  final String videoId;
  final String duration;
  final String? filePath;
  final String? videoUrl;
  final String preferredResolution;
  final bool isFromNetwork;
  final String? videoDescription;
  final Teacher? teacher;
  final String courseId;

  @override
  State<MyVideoWidgetBetterPlayer> createState() =>
      _MyVideoWidgetBetterPlayerState();
}

String _playbackErrorMessage(Object error) {
  if (error is OfflinePlaybackException) return error.message;
  return videoPlaybackErrorMessage(
    error,
    isTeacher: GetIt.I<PrefsRepository>().isTeacher,
  );
}

class _MyVideoWidgetBetterPlayerState extends State<MyVideoWidgetBetterPlayer> {
  /// Renew this long before the server-side session expiry.
  static const _renewalLead = Duration(seconds: 60);
  static const _minRenewalDelay = Duration(seconds: 30);
  static const _maxRenewalDelay = Duration(minutes: 30);

  late BetterPlayerDataSource betterPlayerDataSource;
  late BetterPlayerController betterPlayerController;
  final VideoAccessService _videoAccessService = GetIt.I<VideoAccessService>();
  final SecureOfflinePlaybackService _secureOfflinePlaybackService =
      GetIt.I<SecureOfflinePlaybackService>();
  SecureOfflinePlaybackSession? _offlineSession;
  PlaybackSessionResponse? _onlineSession;
  Timer? _renewalTimer;
  bool _renewingPlaybackSession = false;
  bool _hasRefreshedForCurrentError = false;
  bool _initStarted = false;
  bool initialized = false;
  String? _initializationError;
  bool _replacementAttempted = false;

  Future<void> init() async {
    // didChangeDependencies fires again on rotation/theme changes; a second
    // concurrent init would open a second session and controller.
    if (_initStarted) return;
    _initStarted = true;
    try {
      final source = await _resolveSource();
      if (!mounted) {
        await _offlineSession?.close();
        return;
      }
      betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        source.url,
        videoFormat: BetterPlayerVideoFormat.hls,
        headers: source.headers,
      );

      betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          autoDetectFullscreenDeviceOrientation: true,
          deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
          deviceOrientationsOnFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ],
          controlsConfiguration: BetterPlayerControlsConfiguration(
            progressBarPlayedColor: Theme.of(context).colorScheme.primary,
          ),
          fit: BoxFit.contain,
          autoPlay: false,
          looping: false,
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );
      betterPlayerController.addEventsListener(_onBetterPlayerEvent);
      setState(() {
        initialized = true;
      });
      _scheduleRenewal();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _initializationError = _playbackErrorMessage(error);
      });
    }
  }

  Future<_PlaybackSource> _resolveSource() async {
    if (widget.filePath != null) {
      _offlineSession = await _secureOfflinePlaybackService.start(
        videoId: widget.videoId,
        allowRenewal: true,
      );
      return _PlaybackSource(_offlineSession!.playlistUri.toString());
    }
    final session = await _createOnlineSessionWithReplacement();
    _onlineSession = session;
    return _sourceFor(session);
  }

  /// Honors the quality the user picked by selecting that HLS variant. The
  /// master playlist is read with the session headers, so this works through
  /// the gateway as well as for legacy signed URLs.
  Future<_PlaybackSource> _sourceFor(PlaybackSessionResponse session) async {
    final playbackUrl = await _videoAccessService.resolvePlayableHlsUrl(
      playbackUrl: session.playbackUrl,
      preferredResolution: widget.preferredResolution,
      headers: session.playbackHeaders,
    );
    return _PlaybackSource(playbackUrl, session.playbackHeaders);
  }

  /// Flow selection is role based and ordered: guest, teacher, student.
  Future<PlaybackSessionResponse> _createOnlineSession() {
    final prefs = GetIt.I<PrefsRepository>();
    if (prefs.isGuest || prefs.token == null) {
      return _videoAccessService.createGuestPlaybackSession(
        videoId: widget.videoId,
      );
    }
    if (prefs.isTeacher) {
      return _videoAccessService.createTeacherPlaybackSession(
        videoId: widget.videoId,
        preferredResolution: widget.preferredResolution,
      );
    }
    if (!prefs.isStudent) {
      throw StateError('Unknown authenticated user role');
    }
    return _videoAccessService.createPlaybackSession(
      videoId: widget.videoId,
      preferredResolution: widget.preferredResolution,
    );
  }

  /// Renewal is not registration: it refreshes the current gateway session
  /// and only starts a new one (full secure flow) if the server no longer
  /// accepts the old session, e.g. it expired while paused.
  Future<PlaybackSessionResponse> _renewOnlineSession() async {
    final prefs = GetIt.I<PrefsRepository>();
    final previous = _onlineSession;
    final canRefresh =
        previous != null &&
        previous.playbackHeaders.isNotEmpty &&
        !prefs.isGuest &&
        prefs.token != null;
    if (canRefresh) {
      try {
        return await _videoAccessService.refreshPlaybackSession(
          videoId: widget.videoId,
          playbackSessionId: previous.playbackSessionId,
          preferredResolution: widget.preferredResolution,
        );
      } on DioException catch (error) {
        final status = error.response?.statusCode;
        if (status != 403 && status != 404) rethrow;
      }
    }
    return _createOnlineSession();
  }

  Future<PlaybackSessionResponse> _createOnlineSessionWithReplacement() async {
    try {
      return await _createOnlineSession();
    } on DeviceReplacementRequiredException catch (required) {
      // At most one confirmation and one retry per player instance, so a
      // failing server can never trap the user in a dialog loop.
      if (_replacementAttempted || !mounted) rethrow;
      _replacementAttempted = true;
      final replace = await _confirmDeviceReplacement(required.reason);
      // Cancelling leaves the currently authorized device untouched.
      if (replace != true || !mounted) rethrow;
      await _videoAccessService.replaceVideoDevice();
      return _createOnlineSession();
    }
  }

  Future<bool?> _confirmDeviceReplacement(DeviceReplacementReason reason) {
    final content = reason == DeviceReplacementReason.keyMismatch
        ? 'تغيّر مفتاح الأمان لهذا الجهاز.\nهل تريد إعادة ربط هذا الجهاز بحسابك؟'
        : 'هذا الحساب مرتبط بجهاز آخر.\nهل تريد استخدام هذا الجهاز بدلاً منه؟\n'
              'سيتوقف تشغيل الفيديوهات على الجهاز الآخر.';
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('استبدال الجهاز'),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('استخدام هذا الجهاز'),
          ),
        ],
      ),
    );
  }

  void _scheduleRenewal() {
    _renewalTimer?.cancel();
    final session = _onlineSession;
    if (!mounted || session == null || widget.filePath != null) return;
    var delay =
        session.expiresAt.toUtc().difference(_videoAccessService.serverNow) -
        _renewalLead;
    if (delay < _minRenewalDelay) delay = _minRenewalDelay;
    if (delay > _maxRenewalDelay) delay = _maxRenewalDelay;
    _renewalTimer = Timer(delay, () => _renewPlayback(proactive: true));
  }

  /// Swaps in a renewed session at the current position. Proactive renewal
  /// runs before expiry; reactive renewal runs after a media request failed.
  Future<void> _renewPlayback({required bool proactive}) async {
    if (_renewingPlaybackSession ||
        !mounted ||
        !initialized ||
        widget.filePath != null) {
      return;
    }
    _renewingPlaybackSession = true;
    try {
      final controller = betterPlayerController;
      final wasPlaying = controller.isPlaying() ?? false;
      final position =
          await controller.videoPlayerController?.position ?? Duration.zero;
      final speed = controller.videoPlayerController?.value.speed ?? 1.0;
      final session = await _renewOnlineSession();
      if (!mounted) return;
      _onlineSession = session;
      final source = await _sourceFor(session);
      if (!mounted) return;
      await controller.setupDataSource(
        BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          source.url,
          videoFormat: BetterPlayerVideoFormat.hls,
          headers: source.headers,
        ),
      );
      await controller.setSpeed(speed);
      await controller.seekTo(position);
      if (wasPlaying) {
        controller.play();
      }
      _scheduleRenewal();
    } on DeviceReplacementRequiredException {
      // Another device took over this account. Never re-prompt from a
      // background renewal; reopening the video offers the replacement.
      _renewalTimer?.cancel();
      if (mounted) {
        showMessage('تم ربط حسابك بجهاز آخر، لذا توقف التشغيل على هذا الجهاز');
      }
    } catch (error) {
      if (!mounted) return;
      if (proactive) {
        // The current session is still valid for about a minute; try again
        // shortly, and let the reactive path recover if that also fails.
        _renewalTimer?.cancel();
        _renewalTimer = Timer(
          const Duration(seconds: 20),
          () => _renewPlayback(proactive: false),
        );
      } else {
        showMessage(_playbackErrorMessage(error));
      }
    } finally {
      _renewingPlaybackSession = false;
    }
  }

  Future<void> _onBetterPlayerEvent(BetterPlayerEvent event) async {
    if (event.betterPlayerEventType != BetterPlayerEventType.exception) {
      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        _hasRefreshedForCurrentError = false;
      }
      return;
    }
    if (widget.filePath != null ||
        _renewingPlaybackSession ||
        _hasRefreshedForCurrentError) {
      return;
    }
    _hasRefreshedForCurrentError = true;
    await _renewPlayback(proactive: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
  }

  @override
  void dispose() {
    _renewalTimer?.cancel();
    if (initialized) {
      betterPlayerController.removeEventsListener(_onBetterPlayerEvent);
      betterPlayerController.dispose();
    }
    _offlineSession?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializationError != null) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Center(
          child: Text(
            _initializationError!,
            style: GoogleFonts.cairo(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return initialized
        ? Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AspectRatio(
                    aspectRatio:
                        betterPlayerController.getAspectRatio() ?? 16 / 9,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BetterPlayer(controller: betterPlayerController),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text(
                      //   widget.videoName,
                      //   style: GoogleFonts.cairo(
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.w700,
                      //     color: Theme.of(context).colorScheme.primary,
                      //   ),
                      // ),
                      // const SizedBox(height: 8),
                      // Text(
                      //   widget.duration,
                      //   style: GoogleFonts.cairo(
                      //     fontSize: 16,
                      //     color: AppColors.greyDark,
                      //   ),
                      // ),
                      if (widget.teacher != null) ...{
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    context.pop(); // video details
                                    context.pop(); // lecture details
                                    // course details
                                    context.pushReplacement(
                                      "${GRouter.config.applicationRoutes.teacherDetails}/${widget.teacher!.id}/${widget.teacher!.name}",
                                    );
                                  },
                                  child: widget.teacher?.image == null
                                      ? CircleAvatar(
                                          radius: 26,
                                          backgroundColor: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          child: SvgPicture.asset(
                                            AppAssets.iconBoy,
                                            height: 26,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(
                                                180,
                                              ),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                widget.teacher?.image ?? '',
                                            width: 40.r,
                                            height: 40.r,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => SizedBox(
                                              width: 40.r,
                                              height: 40.r,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                            errorWidget: (_, __, ___) =>
                                                const Icon(Icons.error),
                                          ),
                                        ),
                                ),
                                10.horizontalSpace,
                                Text(
                                  'أ. ${widget.teacher?.name ?? ''}',
                                  style: GoogleFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              spacing: 10,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Share.share(
                                      'https://coursay.duckdns.org/teacher?tid=${widget.teacher!.id}&name=${widget.teacher!.name}',
                                    );
                                  },
                                  child: ChipWidget(
                                    iconPath: AppAssets.iconShare,
                                  ),
                                ),
                                FutureBuilder(
                                  future:
                                      HelperFunctions.lostInternetConnection(),
                                  builder: (context, snapShot) {
                                    print(snapShot.error);
                                    print(snapShot.data);
                                    print(snapShot.connectionState);
                                    if (snapShot.connectionState ==
                                        ConnectionState.done) {
                                      if (!(snapShot.data ?? true)) {
                                        return BlocBuilder<HomeBloc, HomeState>(
                                          buildWhen: (p, c) =>
                                              p.activeCourses !=
                                              c.activeCourses,
                                          builder: (context, state) {
                                            return BlocBuilder<
                                              CoursesBloc,
                                              CoursesState
                                            >(
                                              buildWhen: (p, c) =>
                                                  p.upsertVideoInteraction !=
                                                  c.upsertVideoInteraction,
                                              builder: (context, state) {
                                                bool liked =
                                                    state
                                                        .videoInteractionModel
                                                        ?.isLikedByUser ??
                                                    false;
                                                return state
                                                        .upsertVideoInteraction
                                                        .isLoading
                                                    ? CoursatyAppLoader()
                                                    : InkWell(
                                                        onTap: () {
                                                          if (GetIt.I<
                                                                PrefsRepository
                                                              >()
                                                              .isGuest) {
                                                            showGuestContentDialog(
                                                              context,
                                                            );
                                                            return;
                                                          }
                                                          final hasAccess = context
                                                              .read<
                                                                MyDownloadsBloc
                                                              >()
                                                              .state
                                                              .courseIdToCourseDetailsReferences
                                                              .keys
                                                              .any(
                                                                (key) =>
                                                                    key ==
                                                                    widget
                                                                        .courseId,
                                                              );
                                                          if (!hasAccess) {
                                                            showPaidContentDialog(
                                                              context,
                                                              courseId: widget
                                                                  .courseId,
                                                            );
                                                            return;
                                                          }
                                                          BlocProvider.of<
                                                                CoursesBloc
                                                              >(context)
                                                              .add(
                                                                ToggleVideoInteractionEvent(
                                                                  widget
                                                                      .videoId,
                                                                ),
                                                              );
                                                        },
                                                        child: ChipWidget(
                                                          text:
                                                              (state.videoInteractionModel?.likesCount ??
                                                                      0)
                                                                  .toString(),
                                                          iconPath: liked
                                                              ? AppAssets
                                                                    .iconHeartFilled
                                                              : AppAssets
                                                                    .iconHeart,
                                                          iconColor:
                                                              const Color(
                                                                0xFFC61F1F,
                                                              ),
                                                        ),
                                                      );
                                              },
                                            );
                                          },
                                        );
                                      }
                                    }
                                    return SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        10.verticalSpace,
                        Divider(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                        ),
                        10.verticalSpace,
                      },
                      if (widget.videoDescription != null &&
                          widget.videoDescription!.trim().isNotEmpty) ...{
                        const SizedBox(height: 16),
                        Text(
                          "عن الفيديو",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          widget.videoDescription!,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Theme.of(context).colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                        10.verticalSpace,
                        Divider(
                          color: AppColors.secondary.withValues(alpha: 0.2),
                        ),
                        10.verticalSpace,
                      },
                      if (widget.segments.isNotEmpty) ...{
                        15.verticalSpace,
                        Text(
                          "تجد في هذا الفيديو",
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        15.verticalSpace,
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: widget.segments.length,
                          shrinkWrap: true,
                          separatorBuilder: (context, index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                10.verticalSpace,
                                Divider(
                                  color: AppColors.secondary.withValues(
                                    alpha: 0.1,
                                  ),
                                  indent: 22.w,
                                  endIndent: 22.w,
                                  height: 0,
                                ),
                                10.verticalSpace,
                              ],
                            );
                          },
                          itemBuilder: (context, index) {
                            Segment p = widget.segments[index];
                            return InkWell(
                              onTap: () {
                                betterPlayerController.seekTo(
                                  Duration(seconds: (p.startSeconds ?? 0)),
                                );
                              },
                              child: VideoSegementItem(
                                index: index,
                                segment: p,
                              ),
                            );
                          },
                        ),
                      },
                    ],
                  ),
                ),
              ],
            ),
          )
        : Center(child: CoursatyAppLoader());
  }
}

class _PlaybackSource {
  const _PlaybackSource(this.url, [this.headers = const {}]);

  final String url;
  final Map<String, String> headers;
}
