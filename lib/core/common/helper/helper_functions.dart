import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:coursaty_student_and_teacher/core/common/helper/show_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelperFunctions {
  static Future<bool> lostInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result.first == ConnectivityResult.none;
  }

  static Locale getInitLocale() {
    return Locale('ar', 'SY');
  }

  static String getSizeFromBytes(int bytes) {
    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;
    String result = '';
    if (bytes >= gb) {
      result = '${(bytes / gb).toStringAsFixed(2)} جيجا';
    } else if (bytes >= mb) {
      result = '${(bytes / mb).toStringAsFixed(2)} ميغا';
    } else if (bytes >= kb) {
      result = '${(bytes / kb).toStringAsFixed(2)} كيلوبايت';
    } else {
      result = '$bytes بايت';
    }
    return result;
  }

  static Future<void> openCallApp(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<DateTime?> pickDate({required BuildContext context}) async {
    final DateTime? datePick = await showDatePicker(
      context: context,
      locale: Locale("ar", "SY"),
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2200),
    );
    return datePick;
  }

  static String getTimeInFormat(Duration duration) {
    String? hours = duration.inHours > 0
        ? twoDigits(duration.inHours.remainder(60))
        : null;
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${hours ?? ''}$minutes:$seconds';
  }

  static String twoDigits(int n) => n.toString().padLeft(2, "0");

  static String getTimeInHMSFormat({required Duration seconds}) {
    String twoDigitMinutes = twoDigits(seconds.inMinutes.remainder(60).abs());
    String twoDigitSeconds = twoDigits(seconds.inSeconds.remainder(60).abs());
    return "${twoDigits(seconds.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  static whatsapp() async {
    String contact = "963968203343";
    String text = "مرحباً, أود طرح سؤال";
    String iosUrl = "https://wa.me/$contact?text=${Uri.encodeFull(text)}";
    String webUrl =
        'https://api.whatsapp.com/send/?phone=$contact&text=${Uri.encodeFull(text)}';
    try {
      if (Platform.isIOS) {
        if (await canLaunchUrl(Uri.parse(iosUrl))) {
          await launchUrl(Uri.parse(iosUrl));
        }
      } else {
        if (await canLaunchUrl(Uri.parse(iosUrl))) {
          await launchUrl(Uri.parse(iosUrl));
        }
      }
    } catch (e) {
      showMessage(e.toString());
      await launchUrl(Uri.parse(webUrl), mode: LaunchMode.externalApplication);
      print('object ${e.toString()}');
    }
  }

  static Future<bool> urlLauncher(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Unable to launch url');
    }
  }

  static void navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  static void slidingNavigation(
    BuildContext context,
    Widget page, {
    int milliseconds = 300,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return page;
        },
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0), //// navigation from right
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
      ),
    );
  }

  static String getYearNameByNumber(int year) {
    switch (year) {
      case 1:
        return "الأولى";
      case 2:
        return "الثانية";
      case 3:
        return "الثالثة";
      case 4:
        return "الرابعة";
      case 5:
        return "الخامسة";
      case 6:
        return "السادسة";
    }
    return "غير محدد";
  }
}
