import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'recipes_screen.dart';
import 'contribution_screen.dart';
import 'about_screen.dart'; // Import the new AboutScreen

class FavoritesScreen extends StatefulWidget {
  final Set<String> favorites;
  final List<dynamic> allRecipes;
  final void Function(String?)? onToggleFavorite;

  const FavoritesScreen({
    super.key,
    required this.favorites,
    required this.allRecipes,
    required this.onToggleFavorite,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Set<String> _favorites; // Local copy of favorites
  int _selectedIndex = 3; // Favorites tab is selected by default

  @override
  void initState() {
    super.initState();
    _favorites = Set.from(widget.favorites); // Initialize with passed favorites
  }

  @override
  void didUpdateWidget(FavoritesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.favorites != oldWidget.favorites) {
      setState(() {
        _favorites = Set.from(widget.favorites); // Update when parent changes
      });
    }
  }

  void _toggleFavorite(String? recipeId) {
    if (recipeId == null) return;
    setState(() {
      if (_favorites.contains(recipeId)) {
        _favorites.remove(recipeId); // Remove locally
      } else {
        _favorites.add(recipeId); // Add locally
      }
    });
    widget.onToggleFavorite?.call(recipeId); // Notify parent
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
      // Already on FavoritesScreen, do nothing
    } else if (index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AboutScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoriteRecipes = widget.allRecipes
        .where((recipe) => _favorites.contains(recipe['idMeal']))
        .toList();

    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.white,
                child: const Text(
                  'Favorites',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3192),
                  ),
                ),
              ),
              Expanded(
                child: favoriteRecipes.isEmpty
                    ? const Center(
                        child: Text(
                          'No favorite recipes yet!',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16.0),
                        itemCount: favoriteRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = favoriteRecipes[index];
                          final isFavorite =
                              _favorites.contains(recipe['idMeal']);
                          return Card(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image.network(
                                  recipe['strMealThumb'] ?? '',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.error,
                                          color: Colors.red),
                                ),
                              ),
                              title: Text(
                                recipe['strMeal'] ?? 'Unnamed',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                recipe['strArea'] ?? 'Unknown',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isFavorite ? Colors.red : null,
                                ),
                                onPressed: () {
                                  _toggleFavorite(recipe['idMeal']);
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_dining, size: 24),
            label: 'Recipes',
          ),
          BottomNavigationBarItem(
            icon: SizedBox.shrink(),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite, size: 24),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info, size: 24), // Icon for About
            label: 'About',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2E3192),
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
