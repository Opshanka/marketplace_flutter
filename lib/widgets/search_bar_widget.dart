import 'package:flutter/material.dart';
import '../screens/search_screen.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Text(
              'Search products...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.tune,
                size: 18,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}