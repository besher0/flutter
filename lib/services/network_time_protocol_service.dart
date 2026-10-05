import 'dart:io';
import 'package:get_it/get_it.dart';

import '../core/storage/prefs_repository.dart';

class NetworkTimeProtocolService {
  static final PrefsRepository prefsRepository = GetIt.I<PrefsRepository>();
  static bool checkedInThisLaunching = false;
  static String? storedDate = prefsRepository.realTime.toString();

  static DateTime? _dealWithIos() {
    // Get the current date
    DateTime currentDate = DateTime.now();
    String currentDateString = currentDate
        .toIso8601String(); // Store as ISO 8601 string for simplicity

    // Get previously stored date
    String? storedDateString = prefsRepository.realTime;

    if (storedDateString == null) {
      // No previous date stored, so we store the current one
      prefsRepository.setRealTime(DateTime.parse(currentDateString.toString()));
      print('Device date stored as: $currentDateString');
    } else {
      // Convert the stored date string back to DateTime
      DateTime storedDate = DateTime.parse(storedDateString);

      // If the current date is newer, update the stored date
      if (currentDate.isAfter(storedDate)) {
        prefsRepository.setRealTime(
          DateTime.parse(currentDateString.toString()),
        );
        print('Device date updated to: $currentDateString');
      } else {
        print('Stored date is already newer or the same.');
      }
    }
    return DateTime.tryParse(prefsRepository.realTime.toString());
  }

  static bool checkLocalTimeValidity() {
    DateTime? networkTime = storedDate != 'null'
        ? DateTime.tryParse(storedDate.toString())
        : _dealWithIos();
    DateTime deviceTime = DateTime.now();
    if (networkTime != null) {
      return deviceTime.isBefore(networkTime);
    } else {
      return true;
    }
  }
}
