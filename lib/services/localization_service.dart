import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../core/common/helper/helper_functions.dart';

class LocalizationService extends StatelessWidget {
  final Widget child;
  final Locale? defaultLocale;
  const LocalizationService({
    super.key,
    required this.child,
    this.defaultLocale,
  });

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      path: "assets/languages",
      saveLocale: true,
      startLocale: defaultLocale ?? HelperFunctions.getInitLocale(),
      fallbackLocale: HelperFunctions.getInitLocale(),
      supportedLocales: [Locale('ar', 'SY')],
      child: child,
    );
  }
}
