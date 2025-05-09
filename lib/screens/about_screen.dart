import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'recipes_screen.dart';
import 'contribution_screen.dart';
import 'favorites_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  void _onItemTapped(BuildContext context, int index) {
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FavoritesScreen(
            favorites: const {},
            allRecipes: const [],
            onToggleFavorite: (String? recipeId) {},
          ),
        ),
      );
    } else if (index == 4) {
      // Already on AboutScreen, do nothing
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey[100],
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E3192),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Gebeta App',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3192),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Welcome to Gebeta App! Discover a wide variety of recipes from around the world, including special Habesha dishes. Save your favorite recipes, contribute your own, and explore culinary traditions with ease.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Version',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3192),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1.0.0',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Developed By',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3192),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'yehya, nuredin and fuad',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
            icon: Icon(Icons.info, size: 24),
            label: 'About',
          ),
        ],
        currentIndex: 4, // About tab is selected
        selectedItemColor: const Color(0xFF2E3192),
        unselectedItemColor: Colors.grey,
        onTap: (index) => _onItemTapped(context, index),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 8.0),
        child: FloatingActionButton(
          onPressed: () {
            _onItemTapped(context, 2);
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
