import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../providers/category_provider.dart';
import '../providers/label_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Indeks tab yang aktif
  String searchQuery = "";
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TodoProvider>(context, listen: false).fetchTodos();
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
      Provider.of<LabelProvider>(context, listen: false).fetchLabels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Todo List Maker"),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            tabs: [
              Tab(text: "Todos"),
              Tab(text: "Categories"),
              Tab(text: "Labels"),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildTodoTab(), _buildCategoryTab(), _buildLabelTab()],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            if (_currentIndex == 0) {
              _showAddTodoDialog();
            } else if (_currentIndex == 1) {
              _showAddCategoryDialog();
            } else {
              _showAddLabelDialog();
            }
          },
        ),
      ),
    );
  }

  // ==============================
  // TAB TODOS
  // ==============================
  Widget _buildTodoTab() {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        if (todoProvider.todos.isEmpty) {
          return Center(child: Text("Belum ada tugas! Tambahkan sekarang."));
        }
        return ListView.builder(
          itemCount: todoProvider.todos.length,
          itemBuilder: (context, index) {
            final todo = todoProvider.todos[index];
            return Card(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: ListTile(
                title: Text(
                  todo.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Deskripsi: ${todo.description}"),
                    Text("Label: ${todo.label.title}"),
                    Text("Category: ${todo.category.title}"),
                    Text("Status: ${todo.status}"),
                    Text("Deadline: ${todo.deadline}"),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed:
                      () => _showDeleteDialog(
                        () => todoProvider.deleteTodo(todo.id),
                      ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==============================
  // TAB CATEGORIES
  // ==============================
  Widget _buildCategoryTab() {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        if (categoryProvider.categories.isEmpty) {
          return Center(child: Text("Belum ada kategori!"));
        }
        return ListView.builder(
          itemCount: categoryProvider.categories.length,
          itemBuilder: (context, index) {
            final category = categoryProvider.categories[index];
            return _buildListItem(
              category.title,
              () => _showDeleteDialog(
                () => categoryProvider.deleteCategory(category.id),
              ),
            );
          },
        );
      },
    );
  }

  // ==============================
  // TAB LABELS
  // ==============================
  Widget _buildLabelTab() {
    return Consumer<LabelProvider>(
      builder: (context, labelProvider, child) {
        if (labelProvider.labels.isEmpty) {
          return Center(child: Text("Belum ada label!"));
        }
        return ListView.builder(
          itemCount: labelProvider.labels.length,
          itemBuilder: (context, index) {
            final label = labelProvider.labels[index];
            return _buildListItem(
              label.title,
              () =>
                  _showDeleteDialog(() => labelProvider.deleteLabel(label.id)),
            );
          },
        );
      },
    );
  }

  // ==============================
  // WIDGET LIST ITEM
  // ==============================
  Widget _buildListItem(String title, VoidCallback onDelete) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: ListTile(
        title: Text(title),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }

  // ==============================
  // MODAL KONFIRMASI HAPUS
  // ==============================
  void _showDeleteDialog(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Konfirmasi"),
          content: Text("Apakah Anda yakin ingin menghapus item ini?"),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Hapus"),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // MODAL TAMBAH TODO
  // ==============================
  void _showAddTodoDialog() {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _descriptionController =
        TextEditingController();
    final TextEditingController _deadlineController = TextEditingController();

    String? _selectedCategory;
    String? _selectedLabel;
    String _selectedStatus = "rendah"; // Default status

    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final labelProvider = Provider.of<LabelProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Todo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: "Nama Todo"),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: "Deskripsi"),
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Pilih Kategori"),
                  value: _selectedCategory,
                  items:
                      categoryProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id.toString(),
                          child: Text(category.title),
                        );
                      }).toList(),
                  onChanged: (value) {
                    _selectedCategory = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Pilih Label"),
                  value: _selectedLabel,
                  items:
                      labelProvider.labels.map((label) {
                        return DropdownMenuItem(
                          value: label.id.toString(),
                          child: Text(label.title),
                        );
                      }).toList(),
                  onChanged: (value) {
                    _selectedLabel = value;
                  },
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(labelText: "Status"),
                  value: _selectedStatus,
                  items:
                      ['rendah', 'sedang', 'tinggi'].map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                  onChanged: (value) {
                    _selectedStatus = value!;
                  },
                ),
                TextField(
                  controller: _deadlineController,
                  decoration: InputDecoration(
                    labelText: "Deadline (YYYY-MM-DD)",
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Tambah"),
              onPressed: () {
                final String title = _titleController.text.trim();
                final String description = _descriptionController.text.trim();
                final String deadline = _deadlineController.text.trim();

                if (title.isNotEmpty &&
                    _selectedCategory != null &&
                    _selectedLabel != null) {
                  Provider.of<TodoProvider>(context, listen: false).addTodo({
                    "title": title,
                    "description": description,
                    "category_id": _selectedCategory,
                    "label_id": _selectedLabel,
                    "status": _selectedStatus,
                    "deadline": deadline,
                  });

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddCategoryDialog() {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Category"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Nama Category"),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Tambah"),
              onPressed: () {
                final String title = _controller.text.trim();
                if (title.isNotEmpty) {
                  Provider.of<CategoryProvider>(
                    context,
                    listen: false,
                  ).addCategory({"title": title});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // MODAL TAMBAH LABEL
  // ==============================
  void _showAddLabelDialog() {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Label"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: "Nama Label"),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Tambah"),
              onPressed: () {
                final String title = _controller.text.trim();
                if (title.isNotEmpty) {
                  Provider.of<LabelProvider>(
                    context,
                    listen: false,
                  ).addLabel({"title": title});
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
