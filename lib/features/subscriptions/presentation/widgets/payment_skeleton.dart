import 'package:flutter/material.dart';

import '../../../../app/widgets/skeleton/skeleton.dart';

/// Payment page first load: course summary, the three steps, the QR card and
/// the action button, at the real page's sizes (max width 560).
class PaymentPageSkeleton extends StatelessWidget {
  const PaymentPageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    Widget step() => const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonAvatar(size: 28),
          SizedBox(width: 10),
          Expanded(
            child: SkeletonText(fontSize: 14, lineHeight: 1.55, lines: 2),
          ),
        ],
      ),
    );

    return AppShimmer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final qrSize = constraints.maxWidth >= 600 ? 330.0 : 260.0;
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SkeletonCard(
                      radius: 16,
                      shadow: false,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SkeletonBox(
                            width: 56,
                            height: 56,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonText(
                                  fontSize: 16,
                                  lineHeight: kCairoNaturalLineHeight,
                                  width: 150,
                                ),
                                SizedBox(height: 4),
                                SkeletonText(
                                  fontSize: 14,
                                  lineHeight: kCairoNaturalLineHeight,
                                  width: 90,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SkeletonText(
                      fontSize: 18,
                      lineHeight: kCairoNaturalLineHeight,
                      width: 120,
                    ),
                    const SizedBox(height: 12),
                    step(),
                    step(),
                    step(),
                    const SizedBox(height: 10),
                    SkeletonCard(
                      radius: 18,
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          SkeletonBox(
                            width: qrSize,
                            height: qrSize,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(height: 12),
                          SkeletonBox(
                            width: 170,
                            height: 40,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SkeletonBox(
                      height: 50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
