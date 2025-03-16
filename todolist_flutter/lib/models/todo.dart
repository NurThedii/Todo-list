import 'category.dart';
import 'label.dart';

class Todo {
  final int id;
  final String title;
  final String? description;
  final Category category;
  final Label label;
  final String status;
  final String deadline;

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.label,
    required this.status,
    required this.deadline,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json["id"] as int,
      title: json["title"],
      description: json["description"] ?? "",
      category: Category.fromJson(json["category"] as Map<String, dynamic>?),
      label: Label.fromJson(json["label"] as Map<String, dynamic>?),
      status: json["status"],
      deadline: json["deadline"],
    );
  }
}
