import 'package:flutter/material.dart';
import 'recipe_details_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final Set<String> favorites;
  final List<dynamic> allRecipes;
  final Function(String?) onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.allRecipes,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteRecipes = allRecipes
        .where((recipe) => favorites.contains(recipe['idMeal']?.toString()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Favorites', style: TextStyle(color: Color(0xFF4B0082))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: favoriteRecipes.isEmpty
          ? const Center(
              child: Text('No favorite recipes yet.',
                  style: TextStyle(fontSize: 18, color: Color(0xFF4B0082))))
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: favoriteRecipes.length,
              itemBuilder: (context, index) {
                final recipe = favoriteRecipes[index];
                if (recipe['idMeal'] == null) return const SizedBox.shrink();
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0)),
                  child: ListTile(
                    leading: Image.network(
                      recipe['strMealThumb'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                    title: Text(recipe['strMeal'] ?? 'Unnamed'),
                    subtitle: Text(recipe['strCategory'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      onPressed: () {
                        onToggleFavorite(recipe['idMeal'] as String?);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailsScreen(
                            recipe: recipe,
                            isFavorite: true,
                            onFavoriteToggle: () {},
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
