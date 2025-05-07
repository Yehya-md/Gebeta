import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipe_details_screen.dart';
import 'favorites_screen.dart';
import 'contribution_screen.dart';
import 'feedback_screen.dart';

class RecipesScreen extends StatefulWidget {
  final dynamic initialRecipe;

  const RecipesScreen({super.key, this.initialRecipe});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  List<dynamic> recipes = [];
  List<dynamic> searchResults = [];
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> favorites = {};

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      final response = await http.get(
          Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s='));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          recipes = data['meals'] ?? [];
          searchResults = recipes;
          isLoading = false;
        });
      } else {
        print('Failed to load recipes, status: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching recipes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchRecipes(String query) {
    setState(() {
      searchResults = recipes.where((recipe) {
        final name = recipe['strMeal']?.toString().toLowerCase() ?? '';
        return name.contains(query.toLowerCase());
      }).toList();
    });
  }

  void toggleFavorite(String? recipeId) {
    if (recipeId != null) {
      setState(() {
        if (favorites.contains(recipeId)) {
          favorites.remove(recipeId);
        } else {
          favorites.add(recipeId);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Recipes', style: TextStyle(color: Color(0xFF4B0082))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: searchRecipes,
              decoration: InputDecoration(
                hintText: "Search recipes...",
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : searchResults.isEmpty
                    ? const Center(child: Text('No recipes found.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final recipe = searchResults[index];
                          if (recipe['idMeal'] == null)
                            return const SizedBox.shrink();
                          final isFav = favorites.contains(recipe['idMeal']);
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0)),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  recipe['strMealThumb'] ?? '',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error),
                                ),
                              ),
                              title: Text(
                                recipe['strMeal'] ?? 'Unnamed',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4B0082)),
                              ),
                              subtitle: Text(
                                'From ${recipe['strArea'] ?? 'Unknown'}',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isFav
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFav ? Colors.red : null,
                                ),
                                onPressed: () =>
                                    toggleFavorite(recipe['idMeal'] as String?),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RecipeDetailsScreen(
                                      recipe: recipe,
                                      isFavorite: isFav,
                                      onFavoriteToggle: () {},
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavoritesScreen(
                  favorites: favorites,
                  allRecipes: recipes,
                  onToggleFavorite: toggleFavorite,
                ),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const ContributionScreen()));
          } else if (index == 3) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const FeedbackScreen()));
          }
        },
        selectedItemColor: const Color(0xFF4B0082),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Contribute'),
          BottomNavigationBarItem(
              icon: Icon(Icons.feedback), label: 'Feedback'),
        ],
      ),
    );
  }
}
