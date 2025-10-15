import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recipes;
  const HomeScreen({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Book')),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            title: Text(recipe['name']),
            trailing: Icon(
              recipe['isFavorite'] ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onTap: () {
              Navigator.pushNamed(context, '/details', arguments: recipe);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/favorites');
        },
        label: const Text('View Favorites'),
        icon: const Icon(Icons.favorite),
      ),
    );
  }
}
