bool hasArabicCharacter(String text) {
  var regex = RegExp(
    "[\u0600-\u06ff]|[\u0750-\u077f]|[\ufb50-\ufc3f]|[\ufe70-\ufefc]",
  );
  if (regex.hasMatch(text)) {
    return true;
  }
  return false;
}
