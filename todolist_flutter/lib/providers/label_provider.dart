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

      if (response.data != null && response.data is List) {
        _labels =
            (response.data as List)
                .map((json) => Label.fromJson(json))
                .toList();
        notifyListeners();
      } else {
        print("⚠ Unexpected response format: ${response.data}");
        throw Exception("Invalid response format");
      }
    } catch (e) {
      print("❌ Error fetching labels: $e");
    }
  }

  Future<void> addLabel(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.addLabels(data);
      if (response.statusCode == 201 && response.data != null) {
        _labels.add(Label.fromJson(response.data));
        notifyListeners();
      } else {
        print("⚠ Failed to add label. Response: ${response.data}");
      }
    } catch (e) {
      print("❌ Error adding label: $e");
    }
  }

  Future<void> updateLabel(String id, Map<String, dynamic> data) async {
    try {
      if (id.isEmpty) {
        print("⚠ ID tidak boleh kosong!");
        return;
      }

      final int labelId = int.tryParse(id) ?? -1;
      if (labelId == -1) {
        print("⚠ ID tidak valid!");
        return;
      }

      print("🔄 Mengirim data update: $data");

      final response = await _apiService.updateLabels(labelId, data);

      if (response.statusCode == 200 && response.data != null) {
        int index = _labels.indexWhere((label) => label.id == labelId);
        if (index != -1) {
          // Debugging
          print("✅ Data sebelum update: ${_labels[index]}");
          print("✅ Data dari API: ${response.data}");

          // Cek apakah response.data memiliki title yang benar
          String newTitle = response.data['title'] ?? data['title'];

          _labels[index] = Label(
            id: labelId,
            title: newTitle, // Pastikan title di-update
          );

          print("✅ Data setelah update: ${_labels[index]}");
          notifyListeners();
        }
      } else {
        print("⚠ Failed to update label. Response: ${response.data}");
      }
    } catch (e) {
      print("❌ Error updating label: $e");
    }
  }

  Future<void> deleteLabel(int id) async {
    try {
      final response = await _apiService.deleteLabels(id);
      if (response.statusCode == 200) {
        _labels.removeWhere((label) => label.id == id);
        notifyListeners();
      } else {
        print("⚠ Failed to delete label. Response: ${response.data}");
      }
    } catch (e) {
      print("❌ Error deleting label: $e");
    }
  }
}
