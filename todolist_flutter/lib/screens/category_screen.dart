import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  void _showAddCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Kategori"),
          content: TextField(
            controller: _categoryController,
            decoration: InputDecoration(hintText: "Masukkan nama kategori"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                if (_categoryController.text.isNotEmpty) {
                  Provider.of<CategoryProvider>(
                    context,
                    listen: false,
                  ).addCategory({"title": _categoryController.text});
                  _categoryController.clear();
                  Navigator.pop(context);
                }
              },
              child: Text("Tambah"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Kategori")),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          if (categoryProvider.categories.isEmpty) {
            return Center(child: Text("Belum ada kategori"));
          }
          return ListView.builder(
            itemCount: categoryProvider.categories.length,
            itemBuilder: (context, index) {
              Category category = categoryProvider.categories[index];
              return ListTile(
                title: Text(category.title),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Provider.of<CategoryProvider>(
                      context,
                      listen: false,
                    ).deleteCategory(category.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategoryDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
