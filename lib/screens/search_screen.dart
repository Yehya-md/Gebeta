import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../routes/router.dart';
import '../services/meal_api_service.dart';
import '../state/favorites_state.dart';
import '../widgets/navigation_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> searchResults = [];
  bool isLoading = false;
  String? selectedArea;
  String? selectedCategory;
  List<String> areas = ['All', 'Ethiopian', 'Italian', 'Mexican'];
  List<String> categories = ['All', 'Dessert', 'Main Course', 'Appetizer'];

  @override
  void initState() {
    super.initState();
    FavoritesState().addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    FavoritesState().removeListener(_onFavoritesChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onFavoritesChanged() {
    setState(() {});
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty && selectedArea == null && selectedCategory == null) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    final apiService = MealApiService();
    try {
      List<dynamic> results = [];
      if (query.isNotEmpty) {
        // results = await apiService.searchRecipes(query);
      } else if (selectedArea != null && selectedArea != 'All') {
        results = await apiService.fetchRecipesByArea(selectedArea!);
      } else if (selectedCategory != null && selectedCategory != 'All') {
        results = await apiService.fetchRecipesByCategory(selectedCategory!);
      }

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      print('Error searching recipes: $e');
      setState(() {
        searchResults = [];
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load recipes: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void toggleFavorite(String? recipeId) {
    if (recipeId != null) {
      FavoritesState().toggleFavorite(recipeId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppConstants.white,
        elevation: 0,
        title: const Text('Search Recipes', style: AppConstants.headline2),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppConstants.primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: AppConstants.backgroundColor,
        padding: AppConstants.defaultPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for recipes...',
                prefixIcon:
                    Icon(Icons.search, color: AppConstants.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: AppConstants.buttonBorderRadius,
                ),
                filled: true,
                fillColor: AppConstants.white,
              ),
              onSubmitted: (value) => _performSearch(value),
            ),
            const SizedBox(height: 16),
            // Filters
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Area Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedArea,
                    hint: const Text('Select Area'),
                    items: areas.map((area) {
                      return DropdownMenuItem<String>(
                        value: area,
                        child: Text(area),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedArea = value;
                        if (value != null) {
                          selectedCategory = null; // Reset other filter
                          _searchController.clear();
                          _performSearch('');
                        }
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: AppConstants.buttonBorderRadius,
                      ),
                      filled: true,
                      fillColor: AppConstants.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Category Filter
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    hint: const Text('Select Category'),
                    items: categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                        if (value != null) {
                          selectedArea = null; // Reset other filter
                          _searchController.clear();
                          _performSearch('');
                        }
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: AppConstants.buttonBorderRadius,
                      ),
                      filled: true,
                      fillColor: AppConstants.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Search Results
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : searchResults.isEmpty
                      ? const Center(
                          child: Text(
                            'No recipes found. Try a different search.',
                            style: AppConstants.bodyText1,
                          ),
                        )
                      : ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final recipe = searchResults[index];
                            final recipeId =
                                recipe['idMeal'] ?? recipe['_id'] ?? '';
                            final isFav =
                                FavoritesState().favorites.contains(recipeId);
                            final imageUrl =
                                recipe['strMealThumb'] ?? recipe['image'] ?? '';
                            final title = recipe['strMeal'] ??
                                recipe['title'] ??
                                'Unnamed';
                            final subtitle = recipe['strArea'] ??
                                recipe['strCategory'] ??
                                'Unknown';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: AppConstants.cardBorderRadius,
                              ),
                              elevation: 2,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: AppConstants.cardBorderRadius,
                                  child: Image.network(
                                    imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                      Icons.error,
                                      color: AppConstants.errorColor,
                                    ),
                                  ),
                                ),
                                title:
                                    Text(title, style: AppConstants.headline3),
                                subtitle: Text(subtitle,
                                    style: AppConstants.bodyText2),
                                trailing: IconButton(
                                  icon: Icon(
                                    isFav
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFav
                                        ? AppConstants.primaryColor
                                        : AppConstants.grey,
                                  ),
                                  onPressed: () => toggleFavorite(recipeId),
                                ),
                                onTap: () {
                                  AppRouter.navigateTo(
                                    context,
                                    AppRouter.recipeDetails,
                                    arguments: {
                                      'recipe': recipe,
                                      'isFavorite': isFav,
                                      'onFavoriteToggle': () =>
                                          toggleFavorite(recipeId),
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          const NavigationWidget(currentIndex: 1), // Recipes tab
    );
  }
}
