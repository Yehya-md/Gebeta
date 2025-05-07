import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'recipes_screen.dart';
import 'footer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> headlineRecipes = [];
  bool isLoadingHeadlines = true;

  @override
  void initState() {
    super.initState();
    fetchHeadlineRecipes();
  }

  Future<void> fetchHeadlineRecipes() async {
    try {
      final ids = ['52772', '52804', '52959'];
      List<dynamic> fetchedRecipes = [];
      for (var id in ids) {
        final response = await http.get(Uri.parse(
            'https://www.themealdb.com/api/json/v1/1/lookup.php?i=$id'));
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['meals'] != null && data['meals'].isNotEmpty) {
            fetchedRecipes.add(data['meals'][0]);
          }
        } else {
          print('Failed to load recipe $id, status: ${response.statusCode}');
        }
      }
      setState(() {
        headlineRecipes = fetchedRecipes;
        isLoadingHeadlines = false;
      });
    } catch (e) {
      print('Error fetching headline recipes: $e');
      setState(() {
        isLoadingHeadlines = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Recipes',
            style: TextStyle(color: Color(0xFF4B0082))),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: const Text(
              'Headline Recipes',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B0082)),
            ),
          ),
          Expanded(
            child: isLoadingHeadlines
                ? const Center(child: CircularProgressIndicator())
                : headlineRecipes.isEmpty
                    ? const Center(child: Text('No recipes available.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: headlineRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = headlineRecipes[index];
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
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        RecipesScreen(initialRecipe: recipe),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RecipesScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4B0082),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'Show More',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
          const FooterWidget(),
        ],
      ),
    );
  }
}
