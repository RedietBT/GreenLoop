import 'package:flutter/material.dart';

extension ContextExtension on BuildContext {
  /// Returns the current [ThemeData] of the app.
  ThemeData get theme => Theme.of(this);

  /// Returns the current [TextTheme] of the app.
  TextTheme get textTheme => theme.textTheme;

  /// Returns the current [ColorScheme] of the app.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Returns the current [Brightness] of the app.
  Brightness get brightness => theme.brightness;

  /// Returns the current [MediaQueryData] of the app.
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Returns the current [Size] of the app.
  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;
  }