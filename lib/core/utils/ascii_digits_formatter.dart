import 'package:flutter/services.dart';

/// Keeps only digits, converting Arabic-Indic (٠-٩) and Persian (۰-۹) digits
/// to 0-9. iOS keyboards in Arabic type Arabic-Indic digits, which
/// `FilteringTextInputFormatter.digitsOnly` silently dropped, so phone numbers
/// could not be typed at all.
class AsciiDigitsFormatter extends TextInputFormatter {
  static String normalize(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.writeCharCode(rune);
      } else if (rune >= 0x0660 && rune <= 0x0669) {
        buffer.writeCharCode(0x30 + rune - 0x0660);
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        buffer.writeCharCode(0x30 + rune - 0x06F0);
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = normalize(newValue.text);
    if (text == newValue.text) return newValue;
    final cursor = normalize(
      newValue.text.substring(
        0,
        newValue.selection.end.clamp(0, newValue.text.length),
      ),
    ).length;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: cursor),
    );
  }
}
