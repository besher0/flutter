import 'package:coursaty_student_and_teacher/core/common/constant/design/app_assets.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/helper_functions.dart';
import 'package:coursaty_student_and_teacher/features/courses/presentation/widgets/course_link_tile.dart';
import 'package:flutter/material.dart';

/// The Telegram video explaining payment and subscription, under the steps on
/// the payment page. Shows nothing until the backend sets a link.
class PaymentVideoLink extends StatelessWidget {
  const PaymentVideoLink({super.key, required this.url, this.onOpen});

  static const String label = 'فيديو توضيحي لعملية الدفع والاشتراك';

  final String? url;

  /// Opens the link; defaults to the external app (Telegram).
  final Future<void> Function(String url)? onOpen;

  @override
  Widget build(BuildContext context) {
    final link = url?.trim();
    if (link == null || link.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: CourseLinkTile(
          title: label,
          assetUrl: AppAssets.telegramLogo,
          isSvg: true,
          onTap: () => (onOpen ?? HelperFunctions.urlLauncher)(link),
        ),
      ),
    );
  }
}
