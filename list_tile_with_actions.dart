import 'package:flutter/material.dart';

/// A reusable ListTile with edit and delete actions.
/// Now supports an optional subtitle.
class ListTileWithActions extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ListTileWithActions({
    Key? key,
    required this.title,
    this.subtitle,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
