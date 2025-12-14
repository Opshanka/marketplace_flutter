import 'package:flutter/material.dart';

class SearchSuggestionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final Color? iconColor;

  const SearchSuggestionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.onDelete,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? Colors.grey[600],
        size: 20,
      ),
      title: Text(title),
      trailing: onDelete != null
          ? IconButton(
              icon: Icon(Icons.close, size: 18, color: Colors.grey[400]),
              onPressed: onDelete,
            )
          : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}