class Category {
  final int id;
  final String title;

  Category({required this.id, required this.title});

  factory Category.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Category(
        id: 0,
        title: "Tanpa Kategori",
      ); // Jika null, beri default
    }
    return Category(
      id: json["id"] as int,
      title: json["title"] ?? "Tanpa Kategori", // Jika title null, beri default
    );
  }
}
