import 'dart:io';
import 'package:coursaty_student_and_teacher/app/widgets/preview_file_video.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/core/theme/app_colors.dart';
import 'package:coursaty_student_and_teacher/features/course_content_management/presentation/bloc/course_content_management_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/utils/theme_state.dart';
import 'package:image_picker/image_picker.dart';

import 'package:file_picker/file_picker.dart';

class CustomChooseFileButton extends StatefulWidget {
  const CustomChooseFileButton({
    super.key,
    required this.title,
    required this.usedForImage,
    required this.choosedFile,
    this.usedForFile = false,
    this.choosedFileSize,
    this.videoDuration,
  });

  final String title;
  final bool usedForImage;
  final bool usedForFile;
  final ValueNotifier<XFile?> choosedFile;
  final TextEditingController? choosedFileSize;
  final TextEditingController? videoDuration;

  @override
  State<CustomChooseFileButton> createState() => _CustomChooseFileButtonState();
}

class _CustomChooseFileButtonState extends ThemeState<CustomChooseFileButton> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFile() async {
    widget.choosedFile.value = null;

    final XFile? file;
    if (widget.usedForFile) {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null) {
        file = XFile(result.files.single.path!);
      } else {
        file = null;
      }
    } else {
      file = await (widget.usedForImage
          ? _picker.pickImage(source: ImageSource.gallery)
          : _picker.pickVideo(source: ImageSource.gallery));
    }
    widget.choosedFile.value = file;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: GoogleFonts.cairo(color: colorScheme.primary, fontSize: 16),
        ),
        10.verticalSpace,
        Column(
          children: [
            InkWell(
              onTap: _pickFile,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.greyLight, width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(6),
                          bottomRight: Radius.circular(6),
                        ),
                        color: AppColors.greyLight,
                      ),
                      child: Text(
                        "رفع ${widget.usedForFile
                            ? "ملف"
                            : widget.usedForImage
                            ? "صورة"
                            : "فيديو"}",
                        style: GoogleFonts.cairo(fontSize: 14),
                      ),
                    ),
                    ValueListenableBuilder<XFile?>(
                      valueListenable: widget.choosedFile,
                      builder: (context, file, _) {
                        return Container(
                          width: 1.sw - 150,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(6),
                              bottomLeft: Radius.circular(6),
                            ),
                          ),
                          child: Text(
                            file == null ? "إضافة ملف" : file.name,
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w400,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            10.verticalSpace,
            ValueListenableBuilder(
              valueListenable: widget.choosedFile,
              builder: (context, file, _) {
                return Column(
                  children: [
                    file == null || widget.usedForFile
                        ? SizedBox.shrink()
                        : widget.usedForImage
                        ? Image.file(
                            File(file.path),
                            height: 150,
                            width: 1.sw - 40,
                          )
                        : SizedBox.shrink(),
                    widget.choosedFileSize != null &&
                            widget.usedForFile &&
                            file != null
                        ? FutureBuilder(
                            future: getReadableFileSize(file.path),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return snapshot.data == null
                                    ? SizedBox.shrink()
                                    : Text("حجم الملف: ${snapshot.data!}");
                              }
                              return SizedBox.shrink();
                            },
                          )
                        : SizedBox.shrink(),
                  ],
                );
              },
            ),
            if (!widget.usedForImage && !widget.usedForFile)
              BlocBuilder<
                CourseContentManagementBloc,
                CourseContentManagementState
              >(
                buildWhen: (p, c) =>
                    p.currentlyUploadingFile.hashCode !=
                    c.currentlyUploadingFile.hashCode,
                builder: (context, state) {
                  return state.currentlyUploadingFile == null
                      ? SizedBox.shrink()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            10.verticalSpace,
                            PreviewFileVideo(
                              key: ValueKey(state.currentlyUploadingFile!.path),
                              filePath: state.currentlyUploadingFile!.path,
                              videoDuration: widget.videoDuration!,
                            ),
                            FutureBuilder(
                              future: getReadableFileSize(
                                state.currentlyUploadingFile!.path,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return snapshot.data == null
                                      ? SizedBox.shrink()
                                      : Text("حجم الملف: ${snapshot.data!}");
                                }
                                return SizedBox.shrink();
                              },
                            ),
                          ],
                        );
                },
              ),
          ],
        ),
        15.verticalSpace,
      ],
    );
  }

  Future<String?> getReadableFileSize(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      widget.choosedFileSize?.text = '';
      return null;
    }

    final bytes = await file.length();

    final result = HelperFunctions.getSizeFromBytes(bytes);
    widget.choosedFileSize?.text = result;
    return result;
  }
}
