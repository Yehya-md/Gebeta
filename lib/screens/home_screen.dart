import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'about_screen.dart';
import 'recipes_screen.dart';
import 'recipe_details_screen.dart';
import 'favorites_screen.dart';
import 'contribution_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> featuredRecipes = [];
  List<dynamic> habeshaRecipes = [];
  List<dynamic> topMealsByCountry = [];
  List<dynamic> topMealsByCategory = [];
  List<String> categories = [];
  final Set<String> favorites = {};
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchFeaturedRecipes();
    fetchHabeshaRecipes();
    fetchCategories();
    fetchTopMealsByCountry();
    fetchTopMealsByCategory();
  }

  Future<void> fetchFeaturedRecipes() async {
    try {
      final response = await http.get(
          Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?f=c'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          featuredRecipes =
              data['meals']?.where((meal) => meal != null).toList() ?? [];
        });
      }
    } catch (e) {
      print('Error fetching featured recipes: $e');
    }
  }

  Future<void> fetchHabeshaRecipes() async {
    try {
      final response =
          await http.get(Uri.parse('http://localhost:3000/habesha-recipes'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          habeshaRecipes =
              data['meals']?.where((meal) => meal != null).toList() ?? [];
        });
      }
    } catch (e) {
      print('Error fetching Habesha recipes: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
          Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?c=list'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          categories =
              data['meals']?.map((c) => c['strCategory'] as String).toList() ??
                  [];
        });
      }
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchTopMealsByCountry() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/filter.php?a=Italian'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> meals =
            data['meals']?.where((meal) => meal != null).toList() ?? [];
        List<dynamic> detailedMeals = [];
        for (var meal in meals.take(3)) {
          final detailResponse = await http.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${meal['idMeal']}'));
          if (detailResponse.statusCode == 200) {
            final detailData = jsonDecode(detailResponse.body);
            if (detailData['meals'] != null && detailData['meals'].isNotEmpty) {
              detailedMeals.add(detailData['meals'][0]);
            }
          }
        }
        setState(() {
          topMealsByCountry = detailedMeals;
        });
      }
    } catch (e) {
      print('Error fetching top meals by country: $e');
    }
  }

  Future<void> fetchTopMealsByCategory() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> meals =
            data['meals']?.where((meal) => meal != null).toList() ?? [];
        List<dynamic> detailedMeals = [];
        for (var meal in meals.take(3)) {
          final detailResponse = await http.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${meal['idMeal']}'));
          if (detailResponse.statusCode == 200) {
            final detailData = jsonDecode(detailResponse.body);
            if (detailData['meals'] != null && detailData['meals'].isNotEmpty) {
              detailedMeals.add(detailData['meals'][0]);
            }
          }
        }
        setState(() {
          topMealsByCategory = detailedMeals;
        });
      }
    } catch (e) {
      print('Error fetching top meals by category: $e');
    }
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      // Already on HomeScreen
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RecipesScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ContributionScreen()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FavoritesScreen(
            favorites: favorites,
            allRecipes: [
              ...featuredRecipes,
              ...habeshaRecipes,
              ...topMealsByCountry,
              ...topMealsByCategory,
            ],
            onToggleFavorite: toggleFavorite,
          ),
        ),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AboutScreen()),
      );
    }
  }

  // Function to get dynamic greeting based on time of day
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Text(
                        '${_getGreeting()}!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E3192),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Habesha Food Recipes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3192),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const RecipesScreen(
                                        initialArea: 'Ethiopian')),
                              );
                            },
                            child: Text(
                              'See all',
                              style: TextStyle(color: Color(0xFF2E3192)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: habeshaRecipes.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: habeshaRecipes.length,
                                itemBuilder: (context, index) {
                                  final recipe = habeshaRecipes[index];
                                  final isFav =
                                      favorites.contains(recipe['idMeal']);
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RecipeDetailsScreen(
                                            recipe: recipe,
                                            isFavorite: isFav,
                                            onFavoriteToggle: () =>
                                                toggleFavorite(
                                                    recipe['idMeal']),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 150,
                                      margin:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        elevation: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(10)),
                                              child: Image.network(
                                                recipe['strMealThumb'] ?? '',
                                                height: 120,
                                                width: 150,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Icon(Icons.error,
                                                        color: Colors.red),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                recipe['strMeal'] ?? 'Unnamed',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'New recipes',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3192),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const RecipesScreen()),
                              );
                            },
                            child: Text(
                              'See all',
                              style: TextStyle(color: Color(0xFF2E3192)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: featuredRecipes.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: featuredRecipes.length,
                                itemBuilder: (context, index) {
                                  final recipe = featuredRecipes[index];
                                  final isFav =
                                      favorites.contains(recipe['idMeal']);
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RecipeDetailsScreen(
                                            recipe: recipe,
                                            isFavorite: isFav,
                                            onFavoriteToggle: () =>
                                                toggleFavorite(
                                                    recipe['idMeal']),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 150,
                                      margin:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        elevation: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(10)),
                                              child: Image.network(
                                                recipe['strMealThumb'] ?? '',
                                                height: 120,
                                                width: 150,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Icon(Icons.error,
                                                        color: Colors.red),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                recipe['strMeal'] ?? 'Unnamed',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Top 3 Meals by Country',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3192),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecipesScreen(
                                      initialArea: 'Italian'),
                                ),
                              );
                            },
                            child: Text(
                              'See all',
                              style: TextStyle(color: Color(0xFF2E3192)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: topMealsByCountry.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: topMealsByCountry.length,
                                itemBuilder: (context, index) {
                                  final recipe = topMealsByCountry[index];
                                  final isFav =
                                      favorites.contains(recipe['idMeal']);
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RecipeDetailsScreen(
                                            recipe: recipe,
                                            isFavorite: isFav,
                                            onFavoriteToggle: () =>
                                                toggleFavorite(
                                                    recipe['idMeal']),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 150,
                                      margin:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        elevation: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(10)),
                                              child: Image.network(
                                                recipe['strMealThumb'] ?? '',
                                                height: 120,
                                                width: 150,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Icon(Icons.error,
                                                        color: Colors.red),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    recipe['strMeal'] ??
                                                        'Unnamed',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    recipe['strArea'] ??
                                                        'Unknown',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Top 3 Meals by Category',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E3192),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RecipesScreen(
                                      initialCategory: 'Dessert'),
                                ),
                              );
                            },
                            child: Text(
                              'See all',
                              style: TextStyle(color: Color(0xFF2E3192)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 200,
                        child: topMealsByCategory.isEmpty
                            ? const Center(child: CircularProgressIndicator())
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: topMealsByCategory.length,
                                itemBuilder: (context, index) {
                                  final recipe = topMealsByCategory[index];
                                  final isFav =
                                      favorites.contains(recipe['idMeal']);
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              RecipeDetailsScreen(
                                            recipe: recipe,
                                            isFavorite: isFav,
                                            onFavoriteToggle: () =>
                                                toggleFavorite(
                                                    recipe['idMeal']),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 150,
                                      margin:
                                          const EdgeInsets.only(right: 16.0),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        elevation: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top: Radius.circular(10)),
                                              child: Image.network(
                                                recipe['strMealThumb'] ?? '',
                                                height: 120,
                                                width: 150,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Icon(Icons.error,
                                                        color: Colors.red),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    recipe['strMeal'] ??
                                                        'Unnamed',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    recipe['strCategory'] ??
                                                        'Unknown',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors.grey[600]),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Gebeta © 2025',
                      style: TextStyle(fontSize: 14, color: Color(0xFF2E3192)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_dining, size: 24),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: const SizedBox.shrink(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: 24),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info, size: 24),
            label: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFF2E3192),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton(
          onPressed: () {
            _onItemTapped(2);
          },
          backgroundColor: const Color(0xFF2E3192),
          child: const Icon(Icons.add, size: 36, color: Colors.white),
          elevation: 4.0,
          shape: const CircleBorder(),
        ),
      ),
    );
  }
}
