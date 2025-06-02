import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  dynamic _recipeData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
    _recipeData = widget.recipe;
    _fetchRecipeDetails();
  }

  Future<void> _fetchRecipeDetails() async {
    final recipeId = widget.recipe['idMeal'] ?? widget.recipe['_id'];
    if (recipeId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid recipe ID';
      });
      return;
    }

    // If idMeal is present, assume TheMealDB data and use passed recipe
    if (widget.recipe['idMeal'] != null &&
        widget.recipe['strInstructions'] != null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    // Otherwise, fetch from custom backend
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:3000/api/recipes/$recipeId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _recipeData = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              jsonDecode(response.body)['error'] ?? 'Failed to fetch recipe';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onFavoriteToggle();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
        bottomNavigationBar: const NavigationWidget(currentIndex: 0),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body:
            Center(child: Text(_errorMessage!, style: AppConstants.bodyText1)),
        bottomNavigationBar: const NavigationWidget(currentIndex: 0),
      );
    }

    // Handle ingredients: TheMealDB vs. backend format
    final ingredients = <String>[];
    if (_recipeData['idMeal'] != null) {
      // TheMealDB format
      for (int i = 1; i <= 20; i++) {
        final ingredient = _recipeData['strIngredient$i']?.toString().trim();
        final measure = _recipeData['strMeasure$i']?.toString().trim();
        if (ingredient != null &&
            ingredient.isNotEmpty &&
            measure != null &&
            measure.isNotEmpty) {
          ingredients.add('$measure $ingredient');
        }
      }
    } else {
      // Backend format (ingredients as list)
      final backendIngredients =
          _recipeData['ingredients'] as List<dynamic>? ?? [];
      ingredients.addAll(backendIngredients.cast<String>());
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
                      _recipeData['strMealThumb'] ?? _recipeData['image'] ?? '',
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
                        _recipeData['strMeal'] ??
                            _recipeData['title'] ??
                            'Unnamed Recipe',
                        style: AppConstants.headline2,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _recipeData['strCategory'] ?? 'Habesha',
                            style: AppConstants.bodyText2,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: AppConstants.bodyText2,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _recipeData['strArea'] ?? 'Ethiopian',
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
                      if (ingredients.isEmpty)
                        Text(
                          'No ingredients available.',
                          style: AppConstants.bodyText1,
                        )
                      else
                        ...ingredients.map((ingredient) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
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
                        _recipeData['strInstructions'] ??
                            _recipeData['instructions'] ??
                            'No instructions available.',
                        style: AppConstants.bodyText1,
                      ),
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
