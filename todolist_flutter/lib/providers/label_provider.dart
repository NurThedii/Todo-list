import 'package:flutter/material.dart';
import '../../models/label.dart';
import '../../services/api_service.dart';

class LabelProvider with ChangeNotifier {
  List<Label> _labels = [];
  final ApiService _apiService = ApiService();

  List<Label> get labels => _labels;

  Future<void> fetchLabels() async {
    try {
      final response = await _apiService.getLabels();

      if (response.data is List) {
        _labels =
            (response.data as List)
                .map((json) => Label.fromJson(json))
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

  Future<void> addLabel(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.addLabels(data);
      if (response.statusCode == 201) {
        _labels.add(Label.fromJson(response.data));
        notifyListeners();
      }
    } catch (e) {
      print("Error adding label: $e");
    }
  }

  Future<void> updateLabel(String id, Map<String, dynamic> data) async {
    try {
      final response = await _apiService.updateLabels(id as int, data);
      if (response.statusCode == 200) {
        int index = _labels.indexWhere((label) => label.id == id);
        if (index != -1) {
          _labels[index] = Label.fromJson(response.data);
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error updating label: $e");
    }
  }

  Future<void> deleteLabel(int id) async {
    try {
      final response = await _apiService.deleteLabels(id as int);
      if (response.statusCode == 200) {
        _labels.removeWhere((label) => label.id == id);
        notifyListeners();
      }
    } catch (e) {
      print("Error deleting label: $e");
    }
  }
}
