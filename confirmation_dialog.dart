import 'package:flutter/material.dart';

/// Show a simple confirmation dialog with [message].
///
/// Returns `true` if the user taps OK, else `false`.
Future<bool> showConfirmationDialog(
    BuildContext context, String message) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('OK'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
