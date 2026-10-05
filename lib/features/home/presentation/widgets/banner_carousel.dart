import 'package:coursaty_student_and_teacher/core/utils/extensions/build_context.dart';
import 'package:coursaty_student_and_teacher/features/home/data/models/home_response_model.dart';
import 'package:coursaty_student_and_teacher/features/home/presentation/pages/advertisement_preview.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'banner_media_cover.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, this.height = 158, required this.banners});

  final double height;
  final List<Advertisement> banners;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.banners.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryLightTrack.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: 16 / 8.5,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemCount: widget.banners.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  context.pushPage(
                    AdvertisementPreview(advertisement: widget.banners[index]),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: BannerMediaWidget(
                    videoUrl: widget.banners[index].videoUrl,
                    imageUrl: widget.banners[index].imageUrl,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 7.5,
              height: 7.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _currentIndex
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.primaryLightTrack,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
