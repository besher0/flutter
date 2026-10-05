import 'package:cached_network_image/cached_network_image.dart';
import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/paid_content_dialog.dart';
import 'package:coursaty_student_and_teacher/app/widgets/you_are_guest_dialog.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/features/courses/data/model/lecture_details_model.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/video_segement_item.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/bloc/home_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:coursaty_student_and_teacher/features/teachers/data/model/teacher_model.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
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
    required this.videoUrl,
    this.videoDescription,
    this.teacher,
    required this.courseId,
  });

  final List<Segment> segments;
  final String videoName;
  final String videoId;
  final String duration;
  final String? filePath;
  final String videoUrl;
  final bool isFromNetwork;
  final String? videoDescription;
  final Teacher? teacher;
  final String courseId;

  @override
  State<MyVideoWidgetBetterPlayer> createState() =>
      _MyVideoWidgetBetterPlayerState();
}

class _MyVideoWidgetBetterPlayerState extends State<MyVideoWidgetBetterPlayer> {
  late final BetterPlayerDataSource betterPlayerDataSource;
  late final BetterPlayerController betterPlayerController;
  bool initialized = false;

  Future<void> init() async {
    if (initialized) return;
    betterPlayerDataSource = BetterPlayerDataSource(
      widget.filePath != null
          ? BetterPlayerDataSourceType.file
          : BetterPlayerDataSourceType.network,
      widget.filePath ?? widget.videoUrl,
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
    setState(() {
      initialized = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    init();
  }

  @override
  void dispose() {
    betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
