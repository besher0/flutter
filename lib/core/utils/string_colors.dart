import 'dart:ui';

extension HexColorExtension on String? {
  Color? toColor() {
    if (this == null || this!.isEmpty) return null;
    String hex = this!.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Add 100% opacity if not provided
    }
    return Color(int.parse('0x$hex'));
  }
}
