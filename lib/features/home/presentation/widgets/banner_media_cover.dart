import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:path_provider/path_provider.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import '../../../../core/theme/app_colors.dart';

class BannerMediaWidget extends StatefulWidget {
  final String? imageUrl;
  final String? videoUrl;

  const BannerMediaWidget({super.key, this.imageUrl, this.videoUrl});

  @override
  State<BannerMediaWidget> createState() => _BannerMediaWidgetState();
}

class _BannerMediaWidgetState extends State<BannerMediaWidget> {
  String? thumbnailPath;
  bool isLoadingThumbnail = false;

  @override
  void initState() {
    super.initState();

    if (widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty) {
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    try {
      isLoadingThumbnail = true;

      final tempDir = await getTemporaryDirectory();

      final file = await VideoThumbnail.thumbnailFile(
        video: widget.videoUrl!,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 512,
        quality: 75,
      );

      if (mounted) {
        setState(() {
          thumbnailPath = file.path;
          isLoadingThumbnail = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadingThumbnail = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo =
        widget.videoUrl != null && widget.videoUrl!.trim().isNotEmpty;

    if (hasVideo) {
      if (isLoadingThumbnail) {
        return Container(
          color: AppColors.primaryLightTrack,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (thumbnailPath != null) {
        return Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(File(thumbnailPath!), fit: BoxFit.cover),
            ),

            const Center(
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.black54,
                child: Icon(Icons.play_arrow, color: Colors.white, size: 36),
              ),
            ),
          ],
        );
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl ?? '',
        fit: BoxFit.cover,
        width: double.infinity,
        placeholder: (_, __) => Container(
          color: AppColors.primaryLightTrack,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => Container(
          color: AppColors.primaryLightTrack.withValues(alpha: 0.5),
          child: Icon(
            Icons.image_not_supported_outlined,
            color: AppColors.greyNormal,
            size: 48,
          ),
        ),
      ),
    );
  }
}
