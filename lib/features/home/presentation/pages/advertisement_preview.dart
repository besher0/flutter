import 'package:coursaty_student_and_teacher/app/widgets/title_app_bar.dart';
import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/home_response_model.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/widgets/video_widget.dart';

class AdvertisementPreview extends StatelessWidget {
  final Advertisement advertisement;

  const AdvertisementPreview({super.key, required this.advertisement});

  Future<void> _openLink(BuildContext context) async {
    if (advertisement.helperLink == null) {
      return;
    }
    final uri = Uri.parse(advertisement.helperLink!);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('فشل فتح الرابط')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TitleAppBar(
        title: "تفاصيل الإعلان",
        onBackTap: () {
          context.pop();
        },
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 Cached Image
            if (advertisement.fullScreenImageUrl != null)
              InteractiveViewer(
                minScale: 0.5,
                maxScale: 4,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: advertisement.fullScreenImageUrl!,
                    fit: BoxFit.fitWidth,

                    placeholder: (context, url) => SizedBox(
                      height: 0.7.sh,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => SizedBox(
                      height: 0.7.sh,
                      child: Center(
                        child: Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
              )
            else if (advertisement.videoUrl != null)
              VideoWidget(videoUrl: advertisement.videoUrl!),

            const SizedBox(height: 16),

            // 📝 Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    advertisement.title ?? '',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 🔗 Link Button
                  if (advertisement.helperLink != null)
                    InkWell(
                      onTap: () => _openLink(context),
                      child: Text(
                        advertisement.helperLink!,
                        style: GoogleFonts.cairo(fontSize: 20),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
