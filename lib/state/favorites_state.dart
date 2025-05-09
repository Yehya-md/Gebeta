import 'package:flutter/material.dart';

class FavoritesState extends ChangeNotifier {
  final Set<String> _favorites = {};

  Set<String> get favorites => _favorites;

  void toggleFavorite(String recipeId) {
    if (_favorites.contains(recipeId)) {
      _favorites.remove(recipeId);
    } else {
      _favorites.add(recipeId);
    }
    notifyListeners();
  }
}
