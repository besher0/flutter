import 'dart:io';
import 'package:coursaty_student_and_teacher/core/theme/app_colors.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ZoomableImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BorderRadius borderRadius;
  final bool fromNetwork;

  const ZoomableImage({
    super.key,
    required this.imageUrl,
    this.height = 150,
    this.width = double.infinity,
    this.fromNetwork = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
  });

  @override
  Widget build(BuildContext context) {
    final tag = imageUrl; // unique hero tag
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 300),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            pageBuilder: (_, __, ___) => _FullScreenImage(
              imageUrl: imageUrl,
              tag: tag,
              fromNetwork: fromNetwork,
            ),
          ),
        );
      },
      child: Hero(
        tag: tag,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: fromNetwork
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: height,
                  width: width,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const SizedBox(
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => const Icon(Icons.error),
                )
              : Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.primaryLightTrackBorder,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(image: FileImage(File(imageUrl))),
                  ),
                ),
        ),
      ),
    );
  }
}

class _FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String tag;
  final bool fromNetwork;

  const _FullScreenImage({
    required this.imageUrl,
    required this.tag,
    this.fromNetwork = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10,
      body: Stack(
        alignment: Alignment.topRight,
        children: [
          Center(
            child: Hero(
              tag: tag,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: fromNetwork
                    ? CachedNetworkImage(
                        width: 1.sw,
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (_, __, ___) =>
                            const Icon(Icons.error, color: Colors.white),
                      )
                    : Container(
                        width: 1.sw,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primaryLightTrackBorder,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: FileImage(File(imageUrl)),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          SafeArea(
            child: InkWell(
              onTap: () => context.pop(),
              child: Icon(
                Icons.arrow_back_outlined,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
