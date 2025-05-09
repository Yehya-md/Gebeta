import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../routes/router.dart';

class RecipeCard extends StatelessWidget {
  final dynamic recipe;
  final bool isFavorite;
  final Function(String?) onToggleFavorite;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape:
          RoundedRectangleBorder(borderRadius: AppConstants.cardBorderRadius),
      child: InkWell(
        onTap: () {
          AppRouter.navigateTo(context, AppRouter.recipeDetails, arguments: {
            'recipe': recipe,
            'isFavorite': isFavorite,
            'onFavoriteToggle': () =>
                onToggleFavorite(recipe['idMeal'] as String?),
          });
        },
        borderRadius: AppConstants.cardBorderRadius,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  recipe['strMealThumb'] ?? '',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.error,
                    color: AppConstants.errorColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe['strMeal'] ?? 'Unnamed',
                      style: AppConstants.headline3.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'From ${recipe['strArea'] ?? 'Unknown'}',
                      style: AppConstants.bodyText2,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe['strCategory'] ?? 'Unknown',
                      style: AppConstants.bodyText2.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? AppConstants.favoriteColor : null,
                ),
                onPressed: () => onToggleFavorite(recipe['idMeal'] as String?),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
