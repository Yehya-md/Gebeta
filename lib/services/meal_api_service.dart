import 'dart:convert';
import 'package:http/http.dart' as http;

class MealApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String _habeshaUrl = 'http://127.0.0.1:3000/api/recipes';

  Future<List<dynamic>> fetchFeaturedRecipes() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search.php?f=c'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['meals']?.where((meal) => meal != null).toList() ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching featured recipes: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchHabeshaRecipes() async {
    try {
      final response = await http.get(Uri.parse(_habeshaUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['meals']?.where((meal) => meal != null).toList() ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching Habesha recipes: $e');
      return [];
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/list.php?c=list'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['meals']?.map((c) => c['strCategory'] as String).toList() ??
            [];
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<String>> fetchAreas() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/list.php?a=list'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['meals']?.map((a) => a['strArea'] as String).toList() ?? [];
      }
      return [];
    } catch (e) {
      print('Error fetching areas: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchRecipesByArea(String area) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/filter.php?a=$area'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> meals =
            data['meals']?.where((meal) => meal != null).toList() ?? [];
        return await _fetchDetailedRecipes(meals);
      }
      return [];
    } catch (e) {
      print('Error fetching recipes by area $area: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchRecipesByCategory(String category) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/filter.php?c=$category'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> meals =
            data['meals']?.where((meal) => meal != null).toList() ?? [];
        return await _fetchDetailedRecipes(meals);
      }
      return [];
    } catch (e) {
      print('Error fetching recipes by category $category: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchFallbackRecipes() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/search.php?f=a'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> meals =
            data['meals']?.where((meal) => meal != null).toList() ?? [];
        return await _fetchDetailedRecipes(meals);
      }
      return [];
    } catch (e) {
      print('Error fetching fallback recipes: $e');
      return [];
    }
  }

  Future<List<dynamic>> _fetchDetailedRecipes(List<dynamic> meals) async {
    List<dynamic> detailedMeals = [];
    for (var meal in meals) {
      final detailResponse =
          await http.get(Uri.parse('$_baseUrl/lookup.php?i=${meal['idMeal']}'));
      if (detailResponse.statusCode == 200) {
        final detailData = jsonDecode(detailResponse.body);
        if (detailData['meals'] != null && detailData['meals'].isNotEmpty) {
          detailedMeals.add(detailData['meals'][0]);
        }
      }
    }
    return detailedMeals;
  }
}
