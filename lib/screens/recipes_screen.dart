import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../widgets/filter_dropdown.dart';
import '../widgets/recipe_card.dart';
import 'home_screen.dart';
import 'favorites_screen.dart';
import 'contribution_screen.dart';
import 'feedback_screen.dart';

class RecipesScreen extends StatefulWidget {
  final String? initialCategory;
  final String? initialArea;

  const RecipesScreen({super.key, this.initialCategory, this.initialArea});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  List<dynamic> recipes = [];
  List<dynamic> searchResults = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  int currentAreaIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> favorites = {};
  final ScrollController _scrollController = ScrollController();
  List<String> categories = ['All'];
  List<String> areas = ['All'];
  String selectedCategory = 'All';
  String selectedArea = 'All';
  String selectedSort = 'Name (A-Z)';
  int _selectedIndex = 1; // Recipes tab is selected by default

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      selectedCategory = widget.initialCategory!;
    }
    if (widget.initialArea != null) {
      selectedArea = widget.initialArea!;
    }
    fetchCategoriesAndAreas();
    fetchAllRecipes();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        fetchMoreRecipes();
      }
    });
  }

  Future<void> fetchCategoriesAndAreas() async {
    try {
      final categoryResponse = await http.get(
          Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?c=list'));
      if (categoryResponse.statusCode == 200) {
        final categoryData = jsonDecode(categoryResponse.body);
        categories = [
          'All',
          ...categoryData['meals']
              .map((c) => c['strCategory'] as String)
              .toList()
        ];
      }

      final areaResponse = await http.get(
          Uri.parse('https://www.themealdb.com/api/json/v1/1/list.php?a=list'));
      if (areaResponse.statusCode == 200) {
        final areaData = jsonDecode(areaResponse.body);
        areas = [
          'All',
          ...areaData['meals'].map((a) => a['strArea'] as String).toList()
        ];
      }

      setState(() {});
    } catch (e) {
      print('Error fetching categories/areas: $e');
    }
  }

  Future<void> fetchAllRecipes() async {
    setState(() {
      isLoading = true;
      recipes.clear();
      searchResults.clear();
    });

    try {
      if (selectedArea != 'All') {
        final response = await http.get(Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/filter.php?a=$selectedArea'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          List<dynamic> areaRecipes =
              data['meals']?.where((meal) => meal != null).toList() ?? [];
          for (var meal in areaRecipes) {
            final detailResponse = await http.get(Uri.parse(
                'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${meal['idMeal']}'));
            if (detailResponse.statusCode == 200) {
              final detailData = jsonDecode(detailResponse.body);
              if (detailData['meals'] != null &&
                  detailData['meals'].isNotEmpty) {
                recipes.add(detailData['meals'][0]);
              }
            }
          }
        }
      } else if (selectedCategory != 'All') {
        final response = await http.get(Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/filter.php?c=$selectedCategory'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          List<dynamic> categoryRecipes =
              data['meals']?.where((meal) => meal != null).toList() ?? [];
          for (var meal in categoryRecipes) {
            final detailResponse = await http.get(Uri.parse(
                'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${meal['idMeal']}'));
            if (detailResponse.statusCode == 200) {
              final detailData = jsonDecode(detailResponse.body);
              if (detailData['meals'] != null &&
                  detailData['meals'].isNotEmpty) {
                recipes.add(detailData['meals'][0]);
              }
            }
          }
        }
      }

      if (recipes.isEmpty) {
        int initialAreasToFetch = 3;
        for (int i = 0;
            i < initialAreasToFetch && currentAreaIndex < areas.length - 1;
            i++) {
          String area = areas[currentAreaIndex + 1];
          final response = await http.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/filter.php?a=$area'));
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            List<dynamic> areaRecipes =
                data['meals']?.where((meal) => meal != null).toList() ?? [];
            for (var meal in areaRecipes) {
              final detailResponse = await http.get(Uri.parse(
                  'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${meal['idMeal']}'));
              if (detailResponse.statusCode == 200) {
                final detailData = jsonDecode(detailResponse.body);
                if (detailData['meals'] != null &&
                    detailData['meals'].isNotEmpty) {
                  recipes.add(detailData['meals'][0]);
                }
              }
            }
          }
          currentAreaIndex++;
        }
      }

      if (recipes.isEmpty) {
        final fallbackResponse = await http.get(Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/search.php?f=a'));
        if (fallbackResponse.statusCode == 200) {
          final data = jsonDecode(fallbackResponse.body);
          List<dynamic> fallbackRecipes =
              data['meals']?.where((meal) => meal != null).toList() ?? [];
          for (var meal in fallbackRecipes) {
            final detailResponse = await http.get(Uri.parse(
                'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${meal['idMeal']}'));
            if (detailResponse.statusCode == 200) {
              final detailData = jsonDecode(detailResponse.body);
              if (detailData['meals'] != null &&
                  detailData['meals'].isNotEmpty) {
                recipes.add(detailData['meals'][0]);
              }
            }
          }
        }
      }

      applyFiltersAndSort();
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching recipes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMoreRecipes() async {
    if (currentAreaIndex >= areas.length - 1) {
      setState(() {
        isLoadingMore = false;
      });
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      String area = areas[currentAreaIndex + 1];
      final response = await http.get(Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/filter.php?a=$area'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> areaRecipes =
            data['meals']?.where((meal) => meal != null).toList() ?? [];
        for (var meal in areaRecipes) {
          final detailResponse = await http.get(Uri.parse(
              'https://www.themealdb.com/api/json/v1/1/lookup.php?i=${meal['idMeal']}'));
          if (detailResponse.statusCode == 200) {
            final detailData = jsonDecode(detailResponse.body);
            if (detailData['meals'] != null && detailData['meals'].isNotEmpty) {
              recipes.add(detailData['meals'][0]);
            }
          }
        }
        currentAreaIndex++;
        applyFiltersAndSort();
        setState(() {
          isLoadingMore = false;
        });
      } else {
        print(
            'Failed to load recipes for area $area, status: ${response.statusCode}');
        setState(() {
          isLoadingMore = false;
        });
      }
    } catch (e) {
      print('Error fetching more recipes: $e');
      setState(() {
        isLoadingMore = false;
      });
    }
  }

  void applyFiltersAndSort() {
    List<dynamic> filteredResults = List.from(recipes);

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filteredResults = filteredResults.where((recipe) {
        final name = recipe['strMeal']?.toString().toLowerCase() ?? '';
        final ingredients = <String>[];
        for (int i = 1; i <= 20; i++) {
          final ingredient = recipe['strIngredient$i']?.toString().trim();
          if (ingredient != null && ingredient.isNotEmpty) {
            ingredients.add(ingredient.toLowerCase());
          }
        }
        return name.contains(query) ||
            ingredients.any((ingredient) => ingredient.contains(query));
      }).toList();
    }

    if (selectedCategory != 'All') {
      filteredResults = filteredResults.where((recipe) {
        final category = recipe['strCategory']?.toString() ?? '';
        return category == selectedCategory;
      }).toList();
    }

    if (selectedArea != 'All') {
      filteredResults = filteredResults.where((recipe) {
        final area = recipe['strArea']?.toString() ?? '';
        if (area == 'Ethiopian') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Ethiopian recipes are not available in this database. Consider contributing at https://www.themealdb.com/meal-submit.php!'),
                duration: Duration(seconds: 5),
              ),
            );
          });
        }
        return area == selectedArea;
      }).toList();
    }

    if (selectedSort == 'Name (A-Z)') {
      filteredResults
          .sort((a, b) => (a['strMeal'] ?? '').compareTo(b['strMeal'] ?? ''));
    } else if (selectedSort == 'Name (Z-A)') {
      filteredResults
          .sort((a, b) => (b['strMeal'] ?? '').compareTo(a['strMeal'] ?? ''));
    } else if (selectedSort == 'Area (A-Z)') {
      filteredResults
          .sort((a, b) => (a['strArea'] ?? '').compareTo(b['strArea'] ?? ''));
    }

    setState(() {
      searchResults = filteredResults;
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 1) {
      // Already on RecipesScreen, do nothing
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
            allRecipes: recipes,
            onToggleFavorite: toggleFavorite,
          ),
        ),
      );
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Recipes',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E3192),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (query) => applyFiltersAndSort(),
                        decoration: InputDecoration(
                          hintText: "What's in your fridge?",
                          prefixIcon:
                              Icon(Icons.search, color: Colors.grey[600]),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 48) / 3,
                          child: FilterDropdown(
                            value: selectedCategory,
                            label: 'Category',
                            items: categories,
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                                fetchAllRecipes();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 48) / 3,
                          child: FilterDropdown(
                            value: selectedArea,
                            label: 'Area',
                            items: areas,
                            onChanged: (value) {
                              setState(() {
                                selectedArea = value!;
                                fetchAllRecipes();
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width - 48) / 3,
                          child: FilterDropdown(
                            value: selectedSort,
                            label: 'Sort By',
                            items: const [
                              'Name (A-Z)',
                              'Name (Z-A)',
                              'Area (A-Z)'
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedSort = value!;
                                applyFiltersAndSort();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : searchResults.isEmpty
                        ? Center(
                            child: Text(
                              selectedArea != 'All'
                                  ? 'No $selectedArea recipes found. Try a different area!'
                                  : selectedCategory != 'All'
                                      ? 'No $selectedCategory recipes found. Try a different category!'
                                      : 'No recipes found.',
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16.0),
                            itemCount: searchResults.length +
                                (isLoadingMore ? 1 : 0) +
                                1,
                            itemBuilder: (context, index) {
                              if (index == searchResults.length) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (index ==
                                  searchResults.length +
                                      (isLoadingMore ? 1 : 0)) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16.0),
                                  child: Center(
                                    child: GestureDetector(
                                      onTap: fetchMoreRecipes,
                                      child: Text(
                                        'Explore More Delights →',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Color(0xFF2E3192),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                              final recipe = searchResults[index];
                              if (recipe['idMeal'] == null)
                                return const SizedBox.shrink();
                              final isFav =
                                  favorites.contains(recipe['idMeal']);
                              return RecipeCard(
                                recipe: recipe,
                                isFavorite: isFav,
                                onToggleFavorite: toggleFavorite,
                              );
                            },
                          ),
              ),
            ],
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
            icon: const SizedBox
                .shrink(), // Placeholder for custom Contribute icon
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: 24),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 24),
            label: 'Profile',
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

  Widget _buildIngredientChip(String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        avatar: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.local_dining, size: 20, color: Colors.grey[600]),
        ),
        label: Text(label, style: TextStyle(color: Colors.grey[600])),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

// Placeholder for ProfileScreen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: const Center(
        child: Text('Profile Screen Placeholder'),
      ),
    );
  }
}
