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
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/secure_offline_playback_service.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/data/services/video_access_service.dart';
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
  if (error is DioException) {
    switch (error.response?.statusCode) {
      case 403:
        return 'هذا الفيديو غير مجاني. سجّل الدخول أو اشترك لمشاهدته';
      case 404:
        return 'الفيديو غير موجود أو غير متاح';
      case 400:
        return 'تعذر تشغيل الفيديو حالياً';
    }
  }
  return 'تعذر تشغيل الفيديو';
}

class _MyVideoWidgetBetterPlayerState extends State<MyVideoWidgetBetterPlayer> {
  late BetterPlayerDataSource betterPlayerDataSource;
  late BetterPlayerController betterPlayerController;
  final VideoAccessService _videoAccessService = GetIt.I<VideoAccessService>();
  final SecureOfflinePlaybackService _secureOfflinePlaybackService =
      GetIt.I<SecureOfflinePlaybackService>();
  SecureOfflinePlaybackSession? _offlineSession;
  PlaybackSessionResponse? _onlineSession;
  bool _refreshingPlaybackSession = false;
  bool _hasRefreshedForCurrentError = false;
  bool initialized = false;
  String? _initializationError;

  Future<void> init() async {
    if (initialized) return;
    try {
      final source = await _resolveSource();
      if (!mounted) return;
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
    final isGuest =
        GetIt.I<PrefsRepository>().isGuest ||
        GetIt.I<PrefsRepository>().token == null;
    final session = isGuest
        ? await _videoAccessService.createGuestPlaybackSession(
            videoId: widget.videoId,
          )
        : await _videoAccessService.createPlaybackSession(
            videoId: widget.videoId,
            preferredResolution: widget.preferredResolution,
          );
    _onlineSession = session;
    if (session.playbackHeaders.isNotEmpty) {
      return _PlaybackSource(session.playbackUrl, session.playbackHeaders);
    }
    final playbackUrl = await _videoAccessService.resolvePlayableHlsUrl(
      playbackUrl: session.playbackUrl,
      preferredResolution: widget.preferredResolution,
    );
    return _PlaybackSource(playbackUrl);
  }

  Future<void> _onBetterPlayerEvent(BetterPlayerEvent event) async {
    if (event.betterPlayerEventType != BetterPlayerEventType.exception) {
      if (event.betterPlayerEventType == BetterPlayerEventType.play) {
        _hasRefreshedForCurrentError = false;
      }
      return;
    }
    if (widget.filePath != null ||
        _refreshingPlaybackSession ||
        _hasRefreshedForCurrentError) {
      return;
    }
    _refreshingPlaybackSession = true;
    _hasRefreshedForCurrentError = true;
    try {
      final wasPlaying = betterPlayerController.isPlaying() ?? false;
      final position =
          await betterPlayerController.videoPlayerController?.position ??
          Duration.zero;
      final speed =
          betterPlayerController.videoPlayerController?.value.speed ?? 1.0;
      final previousSession = _onlineSession;
      final isGuest =
          GetIt.I<PrefsRepository>().isGuest ||
          GetIt.I<PrefsRepository>().token == null;
      final session = isGuest
          ? await _videoAccessService.createGuestPlaybackSession(
              videoId: widget.videoId,
            )
          : previousSession?.accessToken == null
          ? await _videoAccessService.createPlaybackSession(
              videoId: widget.videoId,
              preferredResolution: widget.preferredResolution,
            )
          : await _videoAccessService.refreshPlaybackSession(
              videoId: widget.videoId,
              playbackSessionId: previousSession!.playbackSessionId,
              preferredResolution: widget.preferredResolution,
            );
      _onlineSession = session;
      final playbackUrl = session.playbackHeaders.isNotEmpty
          ? session.playbackUrl
          : await _videoAccessService.resolvePlayableHlsUrl(
              playbackUrl: session.playbackUrl,
              preferredResolution: widget.preferredResolution,
            );
      await betterPlayerController.setupDataSource(
        BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          playbackUrl,
          videoFormat: BetterPlayerVideoFormat.hls,
          headers: session.playbackHeaders,
        ),
      );
      await betterPlayerController.setSpeed(speed);
      await betterPlayerController.seekTo(position);
      if (wasPlaying) {
        betterPlayerController.play();
      }
    } catch (error) {
      if (mounted) {
        showMessage(_playbackErrorMessage(error));
      }
    } finally {
      _refreshingPlaybackSession = false;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
  }

  @override
  void dispose() {
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
