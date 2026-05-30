import "package:flutter/material.dart";

mixin ThemeAware {
  bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  Color resolveThemeColor({
    required BuildContext context,
    required Color light,
    required Color dark,
  }) => isDarkMode(context) ? dark : light;
}
