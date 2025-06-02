import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../routes/router.dart';
import '../services/meal_api_service.dart';
import '../state/favorites_state.dart';
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
    setState(() {});
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

  Widget _buildRecipeSection(
    BuildContext context, {
    required String title,
    required List<dynamic> recipes,
    required VoidCallback onSeeAll,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                style: AppConstants.headline3.copyWith(
                  color: Theme.of(context).textTheme.bodyLarge!.color,
                ),
              ),
              TextButton(
                onPressed: onSeeAll,
                child: Text(
                  'See all',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
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
                              borderRadius: AppConstants.cardBorderRadius,
                            ),
                            elevation: 2,
                            color: isDark ? Colors.grey[900] : Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  child: Image.network(
                                    imageUrl,
                                    height: 120,
                                    width: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) => Icon(
                                      Icons.error,
                                      color: AppConstants.errorColor,
                                    ),
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
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .color,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        subtitle,
                                        style: AppConstants.bodyText2.copyWith(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .color,
                                        ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(Icons.menu, color: theme.colorScheme.primary),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gebeta',
                style: AppConstants.headline1
                    .copyWith(color: theme.colorScheme.primary)),
            Text(
              'Discover Authentic Recipes',
              style: AppConstants.bodyText2.copyWith(
                color: theme.colorScheme.primary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Gebeta',
                    style: AppConstants.headline1.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore Culinary Delights',
                    style: AppConstants.bodyText2.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(Icons.home, 'Home', () {
              Navigator.pop(context);
              AppRouter.navigateTo(context, AppRouter.home);
            }, context),
            _buildDrawerItem(Icons.settings, 'Settings', () {
              Navigator.pop(context);
              AppRouter.navigateTo(context, AppRouter.settingsButton);
            }, context),
            _buildDrawerItem(Icons.feedback, 'Feedback', () {
              Navigator.pop(context);
              AppRouter.navigateTo(context, AppRouter.feedback);
            }, context),
            _buildDrawerItem(Icons.info, 'About', () {
              Navigator.pop(context);
              AppRouter.navigateTo(context, AppRouter.about);
            }, context),
          ],
        ),
      ),
      body: Container(
        color: theme.scaffoldBackgroundColor,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
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

  ListTile _buildDrawerItem(
      IconData icon, String title, VoidCallback onTap, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: AppConstants.bodyText1),
      onTap: onTap,
    );
  }
}
