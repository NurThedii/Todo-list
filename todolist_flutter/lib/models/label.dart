class Label {
  final int id;
  final String title;

  const Label({required this.id, required this.title});

  factory Label.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const Label(id: 0, title: "Tanpa Label");
    }
    return Label(
      id: json["id"] ?? 0, // Pastikan tidak null
      title:
          json["title"] as String? ??
          "Tanpa Label", // Pastikan tipe data sesuai
    );
  }
}
