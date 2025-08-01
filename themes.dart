import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.indigo,
  snackBarTheme:
  const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  dialogTheme: const DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
);
