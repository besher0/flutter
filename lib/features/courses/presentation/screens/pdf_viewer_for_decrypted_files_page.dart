import 'dart:io';

import 'package:coursaty_student_and_teacher/app/widgets/loading_indicator/coursaty_app_loader.dart';
import 'package:coursaty_student_and_teacher/core/security/secure_student_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/model/lecture_details_model.dart' show FileElement;
import 'package:pdfrx/pdfrx.dart';

class LectureViewer extends StatefulWidget {
  final FileElement lecture;
  final String filePath;
  final bool fromNetwork;

  const LectureViewer({
    super.key,
    required this.lecture,
    required this.filePath,
    this.fromNetwork = false,
  });

  @override
  State<LectureViewer> createState() => _LectureViewerState();
}

class _LectureViewerState extends State<LectureViewer> {
  String fileName = '';
  ScreenCaptureLease? _captureLease;

  @override
  void initState() {
    fileName =
        widget.lecture.fileName ??
        widget.filePath.split('/').last.split('.').first;
    super.initState();
    _captureLease = StudentContentProtection.claim();
  }

  @override
  void dispose() {
    _captureLease?.release();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _setupOrientation() {
    return SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fileName)),
      body: FutureBuilder(
        future: _setupOrientation(),
        builder: (context, snapShot) {
          if (snapShot.connectionState != ConnectionState.done) {
            return CoursatyAppLoader();
          }
          return _buildPDFView();
        },
      ),
    );
  }

  Widget _buildPDFView() {
    if (widget.fromNetwork) {
      return PdfViewer.uri(Uri.parse(widget.filePath));
    }
    return FutureBuilder<int>(
      future: _localFileSize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CoursatyAppLoader();
        }
        final size = snapshot.data ?? 0;
        final exists = snapshot.hasData && size > 0;
        debugPrint(
          '[Downloads] opening local file '
          'path=${widget.filePath} exists=$exists size=$size type=pdf',
        );
        if (!exists) {
          return const Center(child: Text('الملف المحلي غير متوفر'));
        }
        return PdfViewer.file(widget.filePath, params: PdfViewerParams());
      },
    );
  }

  Future<int> _localFileSize() async {
    final file = File(widget.filePath);
    if (!await file.exists()) {
      return 0;
    }
    return file.length();
  }
}
