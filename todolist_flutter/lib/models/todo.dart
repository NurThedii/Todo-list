import 'category.dart';
import 'label.dart';

class Todo {
  final int id;
  final String title;
  final String description;
  final int categoryId;
  final int labelId;
  final String status;
  final String deadline;
  final Category category;
  final Label label; // Tambahkan label di sini

  Todo({
    required this.id,
    required this.title,
    required this.description,
    required this.categoryId,
    required this.labelId,
    required this.status,
    required this.deadline,
    required this.category,
    required this.label, // Tambahkan label di sini
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json["id"] ?? 0,
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      categoryId: json["category_id"] ?? 0,
      labelId: json["label_id"] ?? 0,
      status: json["status"] ?? "rendah",
      deadline: json["deadline"] ?? "",
      category: Category.fromJson(json["category"] ?? {}),
      label: Label.fromJson(json["label"] ?? {}), // Pastikan ini ada
    );
  }
}
