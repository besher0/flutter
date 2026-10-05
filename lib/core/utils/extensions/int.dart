extension IntConversion on int {
  String formatDurationFromSeconds() {
    int seconds = this;
    String ans = "";
    final int sec = seconds % 60;
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    ans += hours.toString().padLeft(2, '0');
    ans += ":";
    ans += minutes.toString().padLeft(2, '0');
    ans += ":";
    ans += sec.toString().padLeft(2, '0');
    return ans;
  }

  String formatDurationAr() {
    int seconds = this;
    if (seconds <= 0) return 'دقيقة واحدة';

    final totalMinutes = (seconds / 60).ceil();

    // أقل من دقيقة → دقيقة واحدة
    if (totalMinutes < 1) return 'دقيقة واحدة';

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    // أقل من ساعة → عرض الدقائق فقط
    if (hours == 0) {
      if (totalMinutes == 1) return 'دقيقة واحدة';
      if (totalMinutes == 2) return 'دقيقتان';
      return '$totalMinutes دقائق';
    }

    // ساعات بدون دقائق
    if (minutes == 0) {
      if (hours == 1) return 'ساعة واحدة';
      if (hours == 2) return 'ساعتان';
      return '$hours ساعات';
    }

    // ساعات + دقائق
    String hoursPart;
    if (hours == 1) {
      hoursPart = 'ساعة واحدة';
    } else if (hours == 2) {
      hoursPart = 'ساعتان';
    } else {
      hoursPart = '$hours ساعات';
    }

    String minutesPart;
    if (minutes == 1) {
      minutesPart = 'دقيقة واحدة';
    } else if (minutes == 2) {
      minutesPart = 'دقيقتان';
    } else {
      minutesPart = '$minutes دقائق';
    }

    return '$hoursPart و $minutesPart';
  }
}
