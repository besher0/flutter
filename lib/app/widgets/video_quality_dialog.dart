import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/app/widgets/try_again_widget.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/bloc/courses_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/common/helper/helper_functions.dart';

Future<String?> showVideoQualityDialog(
  BuildContext context, {
  required String videoId,
  required bool toDownload,
  required final Function(BuildContext context, String quelity) onChooseQuality,
}) {
  BlocProvider.of<CoursesBloc>(
    context,
  ).add(GetVideoResolutionsEvent(videoId: videoId));
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: context.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (_) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "اختر جودة ${toDownload ? "التحميل" : "التشغيل"}",
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: context.colorScheme.onSurface,
                ),
              ),

              const SizedBox(height: 20),
              BlocBuilder<CoursesBloc, CoursesState>(
                buildWhen: (p, c) => p.getResolutions != c.getResolutions,
                builder: (context, state) {
                  final resolutions = state.resolutions
                      .where(
                        (resolution) =>
                            resolution.resolution != null &&
                            resolution.resolution!.isNotEmpty,
                      )
                      .toList();
                  return state.getResolutions.isLoading
                      ? CoursatyAppLoader()
                      : state.getResolutions.isFailed
                      ? Center(
                          child: TryAgainWidget(
                            onPress: () {
                              BlocProvider.of<CoursesBloc>(
                                context,
                              ).add(GetVideoResolutionsEvent(videoId: videoId));
                            },
                          ),
                        )
                      : resolutions.isNotEmpty
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ...resolutions.map(
                              (resolution) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    Navigator.pop(context);
                                    onChooseQuality.call(
                                      context,
                                      resolution.resolution ?? '720p',
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.video_settings,
                                          color: context.colorScheme.onSurface,
                                        ),
                                        const SizedBox(width: 12),

                                        Expanded(
                                          child: Text(
                                            resolution.resolution ?? '',
                                            style: GoogleFonts.cairo(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  context.colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        if (resolution.sizeBytes != null) ...[
                                          Text(
                                            HelperFunctions.getSizeFromBytes(
                                              resolution.sizeBytes!,
                                            ),
                                            style: GoogleFonts.cairo(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Text(
                            "لايوجد دقات متاحة ل${toDownload ? "تحميل" : "تشغيل"} الفيديو الرجاء الانتظار لبعض الوقت",
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
