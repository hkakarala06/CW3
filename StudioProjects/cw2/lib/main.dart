import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'details_screen.dart';
import 'favorites_screen.dart';

void main() => runApp(const RecipeApp());

class RecipeApp extends StatefulWidget {
  const RecipeApp({super.key});
  @override
  State<RecipeApp> createState() => _RecipeAppState();
}

class _RecipeAppState extends State<RecipeApp> {
  final List<Map<String, dynamic>> recipes = [
    {
      'name': 'Pasta Carbonara',
      'ingredients': 'Pasta, Eggs, Cheese, Bacon',
      'instructions': '1. Boil pasta.\n2. Cook bacon.\n3. Mix all with eggs and cheese.',
      'isFavorite': false,
    },
    {
      'name': 'Chicken Curry',
      'ingredients': 'Chicken, Curry Powder, Onion, Garlic',
      'instructions': '1. Fry onion.\n2. Add chicken and curry.\n3. Simmer until cooked.',
      'isFavorite': false,
    },
  ];

  void toggleFavorite(String name) {
    setState(() {
      final recipe = recipes.firstWhere((r) => r['name'] == name);
      recipe['isFavorite'] = !recipe['isFavorite'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe Book',
      theme: ThemeData(primarySwatch: Colors.orange),
      routes: {
        '/': (context) => HomeScreen(recipes: recipes),
        '/favorites': (context) => FavoritesScreen(
          recipes: recipes.where((r) => r['isFavorite']).toList(),
        ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/details') {
          final recipe = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => DetailsScreen(
              recipe: recipe,
              onToggleFavorite: toggleFavorite,
            ),
          );
        }
        return null;
      },
    );
  }
}
