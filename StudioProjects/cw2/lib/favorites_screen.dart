import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> recipes;
  const FavoritesScreen({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Recipes')),
      body: recipes.isEmpty
          ? const Center(child: Text('No favorites yet!'))
          : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            title: Text(recipe['name']),
            onTap: () {
              Navigator.pushNamed(context, '/details', arguments: recipe);
            },
          );
        },
      ),
    );
  }
}
