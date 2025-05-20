import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../routes/router.dart';
import '../services/meal_api_service.dart';
import '../state/favorites_state.dart'; // New state file
import '../widgets/footer_widget.dart';
import '../widgets/navigation_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchData();
    FavoritesState().addListener(_onFavoritesChanged);
  }

  @override
  void dispose() {
    FavoritesState().removeListener(_onFavoritesChanged);
    super.dispose();
  }

  void _onFavoritesChanged() {
    setState(() {}); // Refresh UI when favorites change
  }

  Future<void> _fetchData() async {
    final apiService = MealApiService();
    try {
      final results = await Future.wait([
        apiService.fetchFeaturedRecipes(),
        apiService.fetchHabeshaRecipes(),
        apiService.fetchCategories(),
        apiService
            .fetchRecipesByArea('Italian')
            .then((meals) => meals.take(3).toList()),
        apiService
            .fetchRecipesByCategory('Dessert')
            .then((meals) => meals.take(3).toList()),
      ]);

      setState(() {
        featuredRecipes = results[0];
        habeshaRecipes = results[1];
        categories = results[2] as List<String>;
        topMealsByCountry = results[3];
        topMealsByCategory = results[4];
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        featuredRecipes = [];
        habeshaRecipes = [];
        categories = [];
        topMealsByCountry = [];
        topMealsByCategory = [];
      });
    }
  }

  void toggleFavorite(String? recipeId) {
    if (recipeId != null) {
      FavoritesState().toggleFavorite(recipeId);
    }
  }

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
        color: AppConstants.backgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: AppConstants.defaultPadding,
                  color: AppConstants.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '${_getGreeting()}!',
                        style: AppConstants.headline1,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                _buildRecipeSection(
                  context,
                  title: 'Habesha Food Recipes',
                  recipes: habeshaRecipes,
                  onSeeAll: () => AppRouter.navigateTo(
                    context,
                    AppRouter.recipes,
                    arguments: {'area': 'Ethiopian'},
                  ),
                ),
                _buildRecipeSection(
                  context,
                  title: 'New recipes',
                  recipes: featuredRecipes,
                  onSeeAll: () =>
                      AppRouter.navigateTo(context, AppRouter.recipes),
                ),
                _buildRecipeSection(
                  context,
                  title: 'Top 3 Meals by Country',
                  recipes: topMealsByCountry,
                  onSeeAll: () => AppRouter.navigateTo(
                    context,
                    AppRouter.recipes,
                    arguments: {'area': 'Italian'},
                  ),
                ),
                _buildRecipeSection(
                  context,
                  title: 'Top 3 Meals by Category',
                  recipes: topMealsByCategory,
                  onSeeAll: () => AppRouter.navigateTo(
                    context,
                    AppRouter.recipes,
                    arguments: {'category': 'Dessert'},
                  ),
                ),
                const FooterWidget(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const NavigationWidget(currentIndex: 0),
    );
  }

  Widget _buildRecipeSection(
    BuildContext context, {
    required String title,
    required List<dynamic> recipes,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: AppConstants.defaultPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppConstants.headline3,
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'See all',
                  style: TextStyle(color: AppConstants.primaryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: recipes.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = recipes[index];
                      final recipeId = recipe['idMeal'] ?? recipe['_id'] ?? '';
                      final isFav =
                          FavoritesState().favorites.contains(recipeId);
                      final imageUrl =
                          recipe['strMealThumb'] ?? recipe['image'] ?? '';
                      final title =
                          recipe['strMeal'] ?? recipe['title'] ?? 'Unnamed';
                      final subtitle = recipe['strArea'] ??
                          recipe['strCategory'] ??
                          'Habesha';

                      return GestureDetector(
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
                        child: Container(
                          width: 150,
                          margin: const EdgeInsets.only(right: 16.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: AppConstants.cardBorderRadius),
                            elevation: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10)),
                                  child: Image.network(
                                    imageUrl,
                                    height: 120,
                                    width: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                            Icons.error,
                                            color: AppConstants.errorColor),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        subtitle,
                                        style: AppConstants.bodyText2,
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
    );
  }
}
