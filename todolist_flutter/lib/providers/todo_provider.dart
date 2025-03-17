import 'package:flutter/material.dart';
import 'package:todolist_flutter/models/category.dart';
import 'package:todolist_flutter/models/label.dart';
import '../../models/todo.dart';
import '../../services/api_service.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  List<Category> categories = [];
  List<Label> labels = [];
  final ApiService _apiService = ApiService();

  List<Todo> get todos => _todos;

  Future<void> fetchTodos() async {
    try {
      final response = await _apiService.getTodos();

      print("Response Data: ${response.data}"); // Debugging

      if (response.data == null || response.data is! List) {
        throw Exception("Invalid response format");
      }

      _todos = response.data.map<Todo>((json) => Todo.fromJson(json)).toList();
    } catch (e) {
      print("Error fetching todos: $e");
    } finally {
      notifyListeners(); // 🔥 Selalu update UI meskipun error
    }
  }

  Future<void> addTodo(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.addTodo(data);

      if (response.statusCode == 201 && response.data != null) {
        Todo newTodo = Todo.fromJson(response.data);
        _todos.add(newTodo);
      } else {
        print("Error: Unexpected response format");
      }
    } catch (e) {
      print("Error adding todo: $e");
    } finally {
      notifyListeners(); // 🔥 Tetap update UI meskipun error
    }
  }

  Future<void> updateTodo(int id, Map<String, dynamic> data) async {
    try {
      print("🔄 Mengirim request update todo ID: $id dengan data: $data");

      final response = await _apiService.updateTodo(id, data);

      if (response.statusCode == 200 && response.data != null) {
        print("✅ Data dari API: ${response.data}");

        // Cari index todo yang sesuai
        int index = _todos.indexWhere((todo) => todo.id == id);
        if (index != -1) {
          _todos[index] = Todo.fromJson(response.data['data']);
          print("✅ Todo berhasil diperbarui di state.");
        } else {
          print("⚠ Todo tidak ditemukan dalam daftar.");
        }

        notifyListeners(); // 🔥 Pastikan UI diperbarui
      } else {
        print("❌ Gagal update todo. Response: ${response.data}");
      }
    } catch (e) {
      print("❌ Error updating todo: $e");
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      final response = await _apiService.deleteTodo(id);
      if (response.statusCode == 200) {
        _todos.removeWhere((todo) => todo.id == id);
      } else {
        print("Error: Unexpected response format");
      }
    } catch (e) {
      print("Error deleting todo: $e");
    } finally {
      notifyListeners(); // 🔥 Pastikan UI diperbarui
    }
  }
}
