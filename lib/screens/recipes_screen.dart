import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../services/meal_api_service.dart';
import '../widgets/filter_dropdown.dart';
import '../widgets/navigation_widget.dart';
import '../widgets/recipe_card.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.initialCategory != null) {
      selectedCategory = widget.initialCategory!;
    }
    if (widget.initialArea != null) {
      selectedArea = widget.initialArea!;
    }
    _fetchInitialData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isLoadingMore) {
        fetchMoreRecipes();
      }
    });
  }

  Future<void> _fetchInitialData() async {
    final apiService = MealApiService();
    final results = await Future.wait([
      apiService.fetchCategories(),
      apiService.fetchAreas(),
    ]);

    setState(() {
      categories = ['All', ...results[0]];
      areas = ['All', ...results[1]];
    });

    await fetchAllRecipes();
  }

  Future<void> fetchAllRecipes() async {
    setState(() {
      isLoading = true;
      recipes.clear();
      searchResults.clear();
    });

    final apiService = MealApiService();
    try {
      if (selectedArea != 'All') {
        recipes = await apiService.fetchRecipesByArea(selectedArea);
      } else if (selectedCategory != 'All') {
        recipes = await apiService.fetchRecipesByCategory(selectedCategory);
      }

      if (recipes.isEmpty) {
        int initialAreasToFetch = 3;
        for (int i = 0;
            i < initialAreasToFetch && currentAreaIndex < areas.length - 1;
            i++) {
          String area = areas[currentAreaIndex + 1];
          final areaRecipes = await apiService.fetchRecipesByArea(area);
          recipes.addAll(areaRecipes);
          currentAreaIndex++;
        }
      }

      if (recipes.isEmpty) {
        recipes = await apiService.fetchFallbackRecipes();
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

    final apiService = MealApiService();
    try {
      String area = areas[currentAreaIndex + 1];
      final areaRecipes = await apiService.fetchRecipesByArea(area);
      setState(() {
        recipes.addAll(areaRecipes);
        currentAreaIndex++;
        applyFiltersAndSort();
        isLoadingMore = false;
      });
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
        color: AppConstants.backgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: AppConstants.defaultPadding,
                color: AppConstants.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Explore Recipes',
                      style: AppConstants.headline1,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: AppConstants.white,
                        borderRadius: AppConstants.cardBorderRadius,
                        border: Border.all(color: AppConstants.grey[300]!),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (query) => applyFiltersAndSort(),
                        decoration: InputDecoration(
                          hintText: "What's in your fridge?",
                          prefixIcon: Icon(Icons.search,
                              color: AppConstants.secondaryTextColor),
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
                              style: AppConstants.bodyText1,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: AppConstants.defaultPadding,
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
                                          color: AppConstants.primaryColor,
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
      bottomNavigationBar: const NavigationWidget(currentIndex: 1),
    );
  }
}
