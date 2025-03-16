import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/api_service.dart';

class CategoryProvider with ChangeNotifier {
  List<Category> _categories = [];
  final ApiService _apiService = ApiService();

  List<Category> get categories => _categories;

  Future<void> fetchCategories() async {
    try {
      final response = await _apiService.getCategories();

      if (response.data is List) {
        _categories =
            (response.data as List)
                .map((json) => Category.fromJson(json))
                .toList();
      } else {
        print("Unexpected response format: ${response.data}");
        throw Exception("Invalid response format");
      }

      notifyListeners();
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }

  Future<void> addCategory(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.addCategories(data);
      if (response.statusCode == 201) {
        _categories.add(Category.fromJson(response.data));
        notifyListeners();
      }
    } catch (e) {
      print("Error adding category: $e");
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.updateCategories(id as int, data);
      if (response.statusCode == 200) {
        int index = _categories.indexWhere((category) => category.id == id);
        if (index != -1) {
          _categories[index] = Category.fromJson(response.data);
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error updating category: $e");
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      final response = await _apiService.deleteCategories(id as int);
      if (response.statusCode == 200) {
        _categories.removeWhere((category) => category.id == id);
        notifyListeners();
      }
    } catch (e) {
      print("Error deleting category: $e");
    }
  }
}
