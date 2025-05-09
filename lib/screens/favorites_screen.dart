import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/navigation_widget.dart';

class FavoritesScreen extends StatelessWidget {
  final Set<String> favorites;
  final List<dynamic> allRecipes;
  final void Function(String?)? onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.allRecipes,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteRecipes = allRecipes
        .where((recipe) => favorites.contains(recipe['idMeal']))
        .toList();

    return Scaffold(
      body: Container(
        color: AppConstants.backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: AppConstants.defaultPadding,
                color: AppConstants.white,
                child: Text(
                  'Favorites',
                  style: AppConstants.headline1,
                ),
              ),
              Expanded(
                child: favoriteRecipes.isEmpty
                    ? Center(
                        child: Text(
                          'No favorite recipes yet!',
                          style: AppConstants.bodyText1,
                        ),
                      )
                    : ListView.builder(
                        padding: AppConstants.defaultPadding,
                        itemCount: favoriteRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = favoriteRecipes[index];
                          final isFavorite =
                              favorites.contains(recipe['idMeal']);
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: AppConstants.cardBorderRadius),
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  recipe['strMealThumb'] ?? '',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.error,
                                          color: AppConstants.errorColor),
                                ),
                              ),
                              title: Text(
                                recipe['strMeal'] ?? 'Unnamed',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                recipe['strArea'] ?? 'Unknown',
                                style: AppConstants.bodyText2,
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite
                                      ? AppConstants.favoriteColor
                                      : null,
                                ),
                                onPressed: () =>
                                    onToggleFavorite?.call(recipe['idMeal']),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavigationWidget(currentIndex: 3),
    );
  }
}
