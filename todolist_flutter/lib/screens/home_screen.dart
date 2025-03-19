import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todolist_flutter/models/category.dart';
import 'package:todolist_flutter/models/label.dart';
import 'package:todolist_flutter/models/todo.dart';
import '../providers/todo_provider.dart';
import '../providers/category_provider.dart';
import '../providers/label_provider.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:badges/badges.dart' as badges;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Active tab index
  String searchQuery = "";
  bool ascending = true; // Status urutan (true = naik, false = turun)
  String sortBy = "status"; // Default sort by status

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
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text("Todo List Maker"), _buildDeadlineNotification()],
          ),
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

  Widget _buildDeadlineNotification() {
    final todoProvider = Provider.of<TodoProvider>(context);
    DateTime now = DateTime.now();
    DateTime tomorrow = now.add(Duration(days: 1));

    List<Todo> upcomingTodos =
        todoProvider.todos.where((todo) {
          DateTime? deadline = DateTime.tryParse(todo.deadline);
          return deadline != null &&
              deadline.year == tomorrow.year &&
              deadline.month == tomorrow.month &&
              deadline.day == tomorrow.day;
        }).toList();

    return GestureDetector(
      onTap: () {
        _showDeadlineBottomSheet(context, upcomingTodos);
      },
      child: badges.Badge(
        badgeContent: Text(
          upcomingTodos.length.toString(),
          style: TextStyle(color: Colors.white),
        ),
        child: Icon(Icons.notifications, size: 28),
      ),
    );
  }

  void _showDeadlineBottomSheet(
    BuildContext context,
    List<Todo> upcomingTodos,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Tugas Hampir Deadline",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              ...upcomingTodos.map((todo) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  child: ListTile(
                    title: Text(todo.title),
                    subtitle: Text("Deadline: ${todo.deadline}"),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
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

        List<Todo> filteredTodos =
            todoProvider.todos.where((todo) {
              String query = searchQuery.toLowerCase();
              return todo.title.toLowerCase().contains(query) ||
                  (todo.description ?? '').toLowerCase().contains(query) ||
                  todo.category.title.toLowerCase().contains(query) ||
                  todo.label.title.toLowerCase().contains(query) ||
                  todo.status.toLowerCase().contains(query);
            }).toList();

        // Fungsi Sorting
        void sortTable(String field) {
          setState(() {
            if (sortBy == field) {
              ascending = !ascending; // Toggle ascending dan descending
            } else {
              sortBy = field;
              ascending = true; // Default ascending jika baru memilih field
            }

            todoProvider.todos.sort((a, b) {
              dynamic valueA, valueB;

              switch (field) {
                case "title":
                  valueA = a.title;
                  valueB = b.title;
                  break;
                case "description":
                  valueA = a.description ?? "";
                  valueB = b.description ?? "";
                  break;
                case "category":
                  valueA = a.category.title;
                  valueB = b.category.title;
                  break;
                case "label":
                  valueA = a.label.title;
                  valueB = b.label.title;
                  break;
                case "status":
                  Map<String, int> statusOrder = {
                    "tinggi": 0,
                    "sedang": 1,
                    "rendah": 2,
                  };
                  valueA = statusOrder[a.status]!;
                  valueB = statusOrder[b.status]!;
                  break;
                case "deadline":
                  valueA = DateTime.tryParse(a.deadline) ?? DateTime.now();
                  valueB = DateTime.tryParse(b.deadline) ?? DateTime.now();
                  break;
                default:
                  return 0;
              }

              return ascending
                  ? valueA.compareTo(valueB)
                  : valueB.compareTo(valueA);
            });
          });
        }

        return Column(
          children: [
            // 🔹 Input Pencarian
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Cari Todo",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),

            // 🔹 Dropdown untuk Sorting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Urutkan Berdasarkan:"),
                  DropdownButton<String>(
                    value: sortBy,
                    items: [
                      DropdownMenuItem(value: "title", child: Text("Judul")),
                      DropdownMenuItem(
                        value: "description",
                        child: Text("Deskripsi"),
                      ),
                      DropdownMenuItem(
                        value: "category",
                        child: Text("Kategori"),
                      ),
                      DropdownMenuItem(value: "label", child: Text("Label")),
                      DropdownMenuItem(value: "status", child: Text("Status")),
                      DropdownMenuItem(
                        value: "deadline",
                        child: Text("Deadline"),
                      ),
                    ],
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        sortTable(newValue);
                      }
                    },
                  ),
                ],
              ),
            ),

            // 🔹 Tabel Todo
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth, // Tabel responsif
                        ),
                        child: DataTable(
                          columnSpacing: 15,
                          headingRowHeight: 40,
                          dataRowHeight: 50,
                          columns: [
                            DataColumn(label: Text("Judul")),
                            DataColumn(label: Text("Deskripsi")),
                            DataColumn(label: Text("Kategori")),
                            DataColumn(label: Text("Label")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Deadline")),
                            DataColumn(label: Text("Aksi")),
                          ],
                          rows:
                              filteredTodos.map((todo) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text(todo.title)),
                                    DataCell(
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          todo.description ??
                                              "Tidak ada deskripsi",
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    DataCell(Text(todo.category.title)),
                                    DataCell(Text(todo.label.title)),
                                    DataCell(Text(todo.status)),
                                    DataCell(Text(todo.deadline)),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed:
                                                () => _showEditTodoDialog(todo),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => _showDeleteDialog(
                                                  () => todoProvider.deleteTodo(
                                                    todo.id,
                                                  ),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // MODAL EDIT TODO
  // ==============================
  void _showEditTodoDialog(Todo todo) {
    final TextEditingController _titleController = TextEditingController(
      text: todo.title,
    );
    final TextEditingController _descriptionController = TextEditingController(
      text: todo.description,
    );
    final TextEditingController _deadlineController = TextEditingController(
      text: todo.deadline,
    );

    // Make sure category and label are not null
    String _selectedCategory = todo.category?.id?.toString() ?? "0";
    String _selectedLabel = todo.label?.id?.toString() ?? "0";
    String _selectedStatus = todo.status;
    DateTime? _selectedDate = DateTime.tryParse(todo.deadline);

    final categoryProvider = Provider.of<CategoryProvider>(
      context,
      listen: false,
    );
    final labelProvider = Provider.of<LabelProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Todo"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Nama Todo",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Deskripsi",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCategory != "0" ? _selectedCategory : null,
                  hint: Text("Pilih Kategori"),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
                  items:
                      categoryProvider.categories.map((category) {
                        return DropdownMenuItem(
                          value: category.id.toString(),
                          child: Text(category.title),
                        );
                      }).toList(),
                  onChanged: (value) {
                    _selectedCategory = value ?? "0";
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedLabel != "0" ? _selectedLabel : null,
                  hint: Text("Pilih Label"),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
                  items:
                      labelProvider.labels.map((label) {
                        return DropdownMenuItem(
                          value: label.id.toString(),
                          child: Text(label.title),
                        );
                      }).toList(),
                  onChanged: (value) {
                    _selectedLabel = value ?? "0";
                  },
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
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
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _deadlineController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(pickedDate);
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Deadline",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(_deadlineController.text),
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
              child: Text("Simpan"),
              onPressed: () {
                final int? categoryId = int.tryParse(_selectedCategory);
                final int? labelId = int.tryParse(_selectedLabel);

                // Make sure category and label are not null or 0
                if (categoryId == null || categoryId == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Kategori tidak valid")),
                  );
                  return;
                }
                if (labelId == null || labelId == 0) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Label tidak valid")));
                  return;
                }

                Provider.of<TodoProvider>(
                  context,
                  listen: false,
                ).updateTodo(todo.id, {
                  "title": _titleController.text.trim(),
                  "description": _descriptionController.text.trim(),
                  "category_id": categoryId,
                  "label_id": labelId,
                  "status": _selectedStatus,
                  "deadline": _deadlineController.text.trim(),
                });

                if (_selectedDate != null) {}

                Navigator.of(context).pop();
              },
            ),
          ],
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
              onEdit: () => _showEditCategoryDialog(category),
              color: Colors.purple.shade100,
            );
          },
        );
      },
    );
  }

  // ==============================
  // MODAL EDIT CATEGORY
  // ==============================
  void _showEditCategoryDialog(Category category) {
    final TextEditingController _controller = TextEditingController(
      text: category.title,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Category"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: "Nama Category",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Simpan"),
              onPressed: () {
                Provider.of<CategoryProvider>(
                  context,
                  listen: false,
                ).updateCategory(category.id.toString(), {
                  "title": _controller.text.trim(),
                });

                Navigator.of(context).pop();
              },
            ),
          ],
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
              onEdit: () => _showEditLabelDialog(label),
              color: Colors.blue.shade100,
            );
          },
        );
      },
    );
  }

  // ==============================
  // MODAL EDIT LABEL
  // ==============================
  void _showEditLabelDialog(Label label) {
    final TextEditingController _controller = TextEditingController(
      text: label.title,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Label"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: "Nama Label",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: Text("Batal"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text("Simpan"),
              onPressed: () async {
                final updatedTitle = _controller.text.trim();

                if (updatedTitle.isNotEmpty) {
                  await Provider.of<LabelProvider>(
                    context,
                    listen: false,
                  ).updateLabel(label.id.toString(), {"title": updatedTitle});

                  // Update state to see changes immediately
                  setState(() {});

                  // Close dialog
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
  // WIDGET LIST ITEM
  // ==============================
  Widget _buildListItem(
    String title,
    VoidCallback onDelete, {
    VoidCallback? onEdit,
    Color? color,
  }) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color ?? Colors.grey.shade200,
          child: Text(title.isNotEmpty ? title[0].toUpperCase() : "?"),
        ),
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onEdit != null)
              IconButton(
                icon: Icon(Icons.edit, color: Colors.blue),
                onPressed: onEdit,
              ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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

    DateTime? _selectedDeadline;
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
                  decoration: InputDecoration(
                    labelText: "Nama Todo",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: "Deskripsi",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Pilih Kategori",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
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
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Pilih Label",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
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
                SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 15,
                    ),
                  ),
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
                SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        _selectedDeadline = pickedDate;
                        _deadlineController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(pickedDate);
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: "Deadline",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(
                      _selectedDeadline == null
                          ? "Pilih Deadline"
                          : DateFormat('yyyy-MM-dd').format(_selectedDeadline!),
                    ),
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

                if (title.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Judul tidak boleh kosong")),
                  );
                  return;
                }

                if (_selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Pilih kategori terlebih dahulu")),
                  );
                  return;
                }

                if (_selectedLabel == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Pilih label terlebih dahulu")),
                  );
                  return;
                }

                if (_selectedDeadline == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Pilih deadline terlebih dahulu")),
                  );
                  return;
                }

                String formattedDeadline = DateFormat(
                  'yyyy-MM-dd',
                ).format(_selectedDeadline!);

                Provider.of<TodoProvider>(context, listen: false).addTodo({
                  "title": title,
                  "description": description,
                  "category_id": _selectedCategory,
                  "label_id": _selectedLabel,
                  "status": _selectedStatus,
                  "deadline": formattedDeadline,
                });

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // ==============================
  // MODAL TAMBAH CATEGORY
  // ==============================
  void _showAddCategoryDialog() {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Category"),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              labelText: "Nama Category",
              border: OutlineInputBorder(),
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
                final String title = _controller.text.trim();
                if (title.isNotEmpty) {
                  Provider.of<CategoryProvider>(
                    context,
                    listen: false,
                  ).addCategory({"title": title});
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Nama kategori tidak boleh kosong")),
                  );
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
            decoration: InputDecoration(
              labelText: "Nama Label",
              border: OutlineInputBorder(),
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
                final String title = _controller.text.trim();
                if (title.isNotEmpty) {
                  Provider.of<LabelProvider>(
                    context,
                    listen: false,
                  ).addLabel({"title": title});
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Nama label tidak boleh kosong")),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
