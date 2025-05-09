import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/navigation_widget.dart';

class RecipeDetailsScreen extends StatefulWidget {
  final dynamic recipe;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const RecipeDetailsScreen({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<RecipeDetailsScreen> createState() => _RecipeDetailsScreenState();
}

class _RecipeDetailsScreenState extends State<RecipeDetailsScreen> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onFavoriteToggle();
  }

  @override
  Widget build(BuildContext context) {
    final ingredients = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = widget.recipe['strIngredient$i']?.toString().trim();
      final measure = widget.recipe['strMeasure$i']?.toString().trim();
      if (ingredient != null &&
          ingredient.isNotEmpty &&
          measure != null &&
          measure.isNotEmpty) {
        ingredients.add('$measure $ingredient');
      }
    }

    return Scaffold(
      body: Container(
        color: AppConstants.backgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      widget.recipe['strMealThumb'] ?? '',
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.error,
                        color: AppConstants.errorColor,
                        size: 250,
                      ),
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      child: IconButton(
                        icon: Icon(Icons.arrow_back, color: AppConstants.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite
                              ? AppConstants.favoriteColor
                              : AppConstants.white,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: AppConstants.defaultPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.recipe['strMeal'] ?? 'Unnamed Recipe',
                        style: AppConstants.headline2,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            widget.recipe['strCategory'] ?? 'Unknown',
                            style: AppConstants.bodyText2,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: AppConstants.bodyText2,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.recipe['strArea'] ?? 'Unknown',
                            style: AppConstants.bodyText2,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Ingredients',
                        style: AppConstants.headline3,
                      ),
                      const SizedBox(height: 8),
                      ...ingredients.map((ingredient) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: AppConstants.primaryColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ingredient,
                                    style: AppConstants.bodyText1,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 16),
                      Text(
                        'Instructions',
                        style: AppConstants.headline3,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.recipe['strInstructions'] ??
                            'No instructions available.',
                        style: AppConstants.bodyText1,
                      ),
                      const SizedBox(height: 16),
                      if (widget.recipe['strCulturalInfo'] != null &&
                          widget.recipe['strCulturalInfo'].isNotEmpty) ...[
                        Text(
                          'Cultural Info',
                          style: AppConstants.headline3,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.recipe['strCulturalInfo'],
                          style: AppConstants.bodyText1,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const NavigationWidget(currentIndex: 0),
    );
  }
}
