import 'package:flutter/material.dart';

abstract class ThemeState<T extends StatefulWidget> extends State<T> {
  ThemeData get theme => Theme.of(context);
  TextTheme get textTheme => Theme.of(context).textTheme;
  ColorScheme get colorScheme => Theme.of(context).colorScheme;
}

abstract class ThemeStateless extends StatefulWidget {
  const ThemeStateless({super.key, required this.child, this.onBuild});

  final Widget child;
  final VoidCallback? onBuild;

  @override
  State<ThemeStateless> createState() => _ThemeStatelessState();
}

class _ThemeStatelessState extends State<ThemeStateless> {
  ColorScheme? colorScheme;

  ThemeData? theme;

  TextTheme? textTheme;

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    theme = Theme.of(context);
    textTheme = Theme.of(context).textTheme;
    widget.onBuild?.call();
    return widget.child;
  }
}
