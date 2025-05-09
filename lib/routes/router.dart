import 'package:flutter/material.dart';
import '../screens/about_screen.dart';
import '../screens/contribution_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/feedback_screen.dart';
import '../screens/home_screen.dart';
import '../screens/recipe_details_screen.dart';
import '../screens/recipes_screen.dart';

class AppRouter {
  static const String home = '/';
  static const String recipes = '/recipes';
  static const String contribution = '/contribution';
  static const String favorites = '/favorites';
  static const String feedback = '/feedback';
  static const String recipeDetails = '/recipe-details';
  static const String about = '/about';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case recipes:
        final args = settings.arguments as Map<String, String>?;
        return MaterialPageRoute(
          builder: (_) => RecipesScreen(
            initialCategory: args?['category'],
            initialArea: args?['area'],
          ),
        );
      case contribution:
        return MaterialPageRoute(builder: (_) => const ContributionScreen());
      case favorites:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => FavoritesScreen(
            favorites: args?['favorites'] ?? <String>{},
            allRecipes: args?['allRecipes'] ?? <dynamic>[],
            onToggleFavorite: args?['onToggleFavorite'] ?? (String? id) {},
          ),
        );
      case feedback:
        return MaterialPageRoute(builder: (_) => const FeedbackScreen());
      case recipeDetails:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => RecipeDetailsScreen(
            recipe: args['recipe'],
            isFavorite: args['isFavorite'],
            onFavoriteToggle: args['onFavoriteToggle'],
          ),
        );
      case about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route not found')),
          ),
        );
    }
  }

  static void navigateTo(BuildContext context, String routeName,
      {Map<String, dynamic>? arguments, bool replace = false}) {
    if (replace) {
      Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
    } else {
      Navigator.pushNamed(context, routeName, arguments: arguments);
    }
  }
}
