import 'package:flutter/material.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final dynamic recipe;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const RecipeDetailsScreen({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final String mealName = recipe['strMeal'] ?? 'Unnamed Recipe';
    final String mealThumb = recipe['strMealThumb'] ?? '';
    final String category = recipe['strCategory'] ?? 'N/A';
    final String area = recipe['strArea'] ?? 'Unknown';
    final String instructions =
        recipe['strInstructions'] ?? 'No instructions available';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          mealName,
          style: const TextStyle(
              color: Color(0xFF4B0082), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Color(0xFF4B0082)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'recipe-image-${recipe['idMeal'] ?? mealName}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.network(
                  mealThumb,
                  fit: BoxFit.cover,
                  height: 250,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 250,
                    color: Colors.grey[300],
                    child: const Center(
                        child: Icon(Icons.error, color: Colors.red, size: 50)),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mealName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B0082),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.category,
                            color: Color(0xFF4B0082), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Category: $category',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Color(0xFF4B0082), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Origin: $area',
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Instructions',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B0082)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      instructions
                          .replaceAll('\r\n', '\n')
                          .split('\n')
                          .where((line) => line.isNotEmpty)
                          .map((line) => '• $line')
                          .join('\n'),
                      style: const TextStyle(
                          fontSize: 16, height: 1.5, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cultural Insight',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B0082)),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This dish is a traditional recipe from $area, often enjoyed during ${area == 'Italian' ? 'family gatherings' : 'special occasions'}.',
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Cooking Tips',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B0082)),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '• Use fresh ingredients for enhanced flavor.\n• Adjust seasoning to taste during cooking.\n• Serve warm for the best experience.',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
