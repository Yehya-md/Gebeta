import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/constants.dart';
import '../widgets/navigation_widget.dart';

class ContributionScreen extends StatefulWidget {
  const ContributionScreen({super.key});

  @override
  State<ContributionScreen> createState() => _ContributionScreenState();
}

class _ContributionScreenState extends State<ContributionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipeNameController = TextEditingController();
  final _ingredientsController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  void dispose() {
    _recipeNameController.dispose();
    _ingredientsController.dispose();
    _instructionsController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitRecipe() async {
    if (_formKey.currentState!.validate()) {
      final ingredientsList = _ingredientsController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final payload = {
        'title': _recipeNameController.text,
        'ingredients': ingredientsList,
        'instructions': _instructionsController.text,
        'image':
            _imageUrlController.text.isNotEmpty ? _imageUrlController.text : '',
      };

      try {
        final response = await http.post(
          Uri.parse('http://127.0.0.1:3000/api/food-reviews'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recipe submitted successfully!'),
              duration: Duration(seconds: 2),
            ),
          );
          _recipeNameController.clear();
          _ingredientsController.clear();
          _instructionsController.clear();
          _imageUrlController.clear();
        } else {
          final errorMessage = jsonDecode(response.body)['error'] ??
              'Failed to complete the requested action.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contribute a Recipe'),
        backgroundColor: AppConstants.white,
        elevation: 0,
        titleTextStyle: AppConstants.headline2,
      ),
      body: Container(
        color: AppConstants.backgroundColor,
        padding: AppConstants.defaultPadding,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share your favorite recipe with the community!',
                  style: TextStyle(
                    fontSize: 18,
                    color: AppConstants.grey,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _recipeNameController,
                  decoration: InputDecoration(
                    labelText: 'Recipe Name',
                    labelStyle: TextStyle(color: AppConstants.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: AppConstants.cardBorderRadius,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppConstants.cardBorderRadius,
                      borderSide: BorderSide(color: AppConstants.primaryColor),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the recipe name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ingredientsController,
                  decoration: InputDecoration(
                    labelText: 'Ingredients (one per line)',
                    labelStyle: TextStyle(color: AppConstants.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: AppConstants.cardBorderRadius,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppConstants.cardBorderRadius,
                      borderSide: BorderSide(color: AppConstants.primaryColor),
                    ),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the ingredients';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _instructionsController,
                  decoration: InputDecoration(
                    labelText: 'Instructions',
                    labelStyle: TextStyle(color: AppConstants.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: AppConstants.cardBorderRadius,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppConstants.cardBorderRadius,
                      borderSide: BorderSide(color: AppConstants.primaryColor),
                    ),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the instructions';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    labelText: 'Image URL (optional)',
                    labelStyle: TextStyle(color: AppConstants.primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: AppConstants.cardBorderRadius,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppConstants.cardBorderRadius,
                      borderSide: BorderSide(color: AppConstants.primaryColor),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final urlPattern =
                          RegExp(r'^(https?:\/\/[^\s$.?#].[^\s]*)$');
                      if (!urlPattern.hasMatch(value)) {
                        return 'Please enter a valid URL';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitRecipe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: AppConstants.white,
                      padding: AppConstants.buttonPadding,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppConstants.buttonBorderRadius,
                      ),
                    ),
                    child: Text(
                      'Submit Recipe',
                      style: AppConstants.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const NavigationWidget(currentIndex: 2),
    );
  }
}
