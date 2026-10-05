import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_bloc.dart';
import 'package:coursaty_student_and_teacher/features/my_downloads/presentation/bloc/my_downloads_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/common/constant/design/app_assets.dart';
import '../../../../core/routes/router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions/date_time.dart';
import '../../../courses/presentation/widgets/course_card.dart';
import '../../../courses/presentation/widgets/empty_courses.dart';
import '../../../courses/presentation/widgets/empty_courses_in_downloads.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<MyDownloadsBloc>(
      context,
    ).add(DeleteCoursesWhichAreExpired());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: TitleAppBar(title: "التنزيلات"),

        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: BlocBuilder<MyDownloadsBloc, MyDownloadsState>(
            builder: (context, state) {
              if (state.courseIdToCourseDetailsReferences.isEmpty) {
                return EmptyCoursesInDownloads();
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.courseIdToCourseDetailsReferences.keys.length,
                separatorBuilder: (_, __) => const SizedBox(height: 18),
                itemBuilder: (context, i) {
                  final key = state.courseIdToCourseDetailsReferences.keys
                      .elementAt(i);
                  final item = state.courseIdToCourseDetailsReferences[key]!;
                  return CourseCard(
                    height: 230,
                    onTap: () {
                      context.push(
                        GRouter
                            .config
                            .applicationRoutes
                            .downloadedCourseDetails,
                        extra: item,
                      );
                    },
                    title: item.course?.name ?? '',
                    imageUrl: item.course?.imageUrl ?? '',
                    // footer: Padding(
                    //   padding: const EdgeInsets.only(top: 8.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.start,
                    //     crossAxisAlignment: CrossAxisAlignment.end,
                    //     children: [
                    //       if (item.subscribedAt != null)
                    //         Flexible(
                    //           child: Text(
                    //             "تاريخ الاشتراك: ${item.subscribedAt!.dmy}",
                    //             style: GoogleFonts.cairo(
                    //               fontSize: 10,
                    //               fontWeight: FontWeight.w500,
                    //               color: const Color(0xFF39AC27),
                    //               height: 1.4,
                    //             ),
                    //             textAlign: TextAlign.left,
                    //           ),
                    //         ),
                    //       const SizedBox(width: 20),
                    //       if (item.subscriptionExpiresAt != null)
                    //         Flexible(
                    //           child: Text(
                    //             "تاريخ الانتهاء ${item.subscriptionExpiresAt!.dmy}",
                    //             style: GoogleFonts.cairo(
                    //               fontSize: 10,
                    //               fontWeight: FontWeight.w500,
                    //               color: const Color(0xFFC61F1F),
                    //               height: 1.4,
                    //             ),
                    //             textAlign: TextAlign.right,
                    //           ),
                    //         ),
                    //     ],
                    //   ),
                    // ),
                    // chips: [
                    //   CourseChipData(
                    //     '+${item.details?.studentsCount ?? 0} طالب',
                    //     AppAssets.iconUser,
                    //     iconColor: Theme.of(context).colorScheme.primary,
                    //   ),
                    //   if (item.details?.year?.name != null)
                    //     CourseChipData(
                    //       item.details!.year!.name!,
                    //       AppAssets.iconLayers,
                    //       iconColor: AppColors.secondary,
                    //     ),
                    //   if (item.details?.season?.name != null)
                    //     CourseChipData(
                    //       item.details!.season!.name!,
                    //       AppAssets.iconDocument,
                    //       iconColor: Theme.of(context).colorScheme.primary,
                    //     ),
                    // ],
                    // CourseChipData(
                    //   "${item.} ساعة",
                    //   AppAssets.iconTimer,
                    // ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
