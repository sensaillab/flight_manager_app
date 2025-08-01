// lib/widgets/base_scaffold.dart
import 'package:flutter/material.dart';

class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final VoidCallback onFab;
  final IconData fabIcon;
  final VoidCallback? helpAction;

  const BaseScaffold({
    Key? key,
    required this.title,
    required this.body,
    required this.onFab,
    this.fabIcon = Icons.add,
    this.helpAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: helpAction != null
            ? [
          IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: helpAction)
        ]
            : null,
      ),
      body: body,
      floatingActionButton:
      FloatingActionButton(onPressed: onFab, child: const Icon(Icons.add)),
    );
  }
}
