import 'package:flutter/material.dart';

class DetailsScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final Function(String) onToggleFavorite;

  const DetailsScreen({
    super.key,
    required this.recipe,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(recipe['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ingredients:', style: Theme.of(context).textTheme.titleLarge),
            Text(recipe['ingredients']),
            const SizedBox(height: 16),
            Text('Instructions:', style: Theme.of(context).textTheme.titleLarge),
            Text(recipe['instructions']),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(
                  recipe['isFavorite'] ? Icons.favorite : Icons.favorite_border,
                  color: Colors.red,
                ),
                label: Text(recipe['isFavorite'] ? 'Unfavorite' : 'Add to Favorites'),
                onPressed: () {
                  onToggleFavorite(recipe['name']);
                  Navigator.pop(context); // go back after marking
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
