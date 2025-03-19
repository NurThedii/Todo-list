// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:todolist_flutter/models/category.dart';
// import 'package:todolist_flutter/models/label.dart';
// import 'package:todolist_flutter/models/todo.dart';
// import '../providers/todo_provider.dart';
// import '../providers/category_provider.dart';
// import '../providers/label_provider.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:intl/intl.dart';

// class HomeScreen extends StatefulWidget {
//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _currentIndex = 0; // Active tab index
//   String searchQuery = "";
//   String sortBy = "status"; // Default sort by status
//   final FlutterLocalNotificationsPlugin notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   @override
//   void initState() {
//     super.initState();
//     _initializeNotifications();
//     Future.microtask(() {
//       Provider.of<TodoProvider>(context, listen: false).fetchTodos();
//       Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
//       Provider.of<LabelProvider>(context, listen: false).fetchLabels();
//     });
//   }

//   void _initializeNotifications() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     final InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await notificationsPlugin.initialize(initializationSettings);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text("Todo List Maker"),
//           bottom: TabBar(
//             onTap: (index) {
//               setState(() {
//                 _currentIndex = index;
//               });
//             },
//             tabs: [
//               Tab(text: "Todos"),
//               Tab(text: "Categories"),
//               Tab(text: "Labels"),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [_buildTodoTab(), _buildCategoryTab(), _buildLabelTab()],
//         ),
//         floatingActionButton: FloatingActionButton(
//           child: Icon(Icons.add),
//           onPressed: () {
//             if (_currentIndex == 0) {
//               _showAddTodoDialog();
//             } else if (_currentIndex == 1) {
//               _showAddCategoryDialog();
//             } else {
//               _showAddLabelDialog();
//             }
//           },
//         ),
//       ),
//     );
//   }

//   // ==============================
//   // TAB TODOS
//   // ==============================
//   Widget _buildTodoTab() {
//     return Consumer<TodoProvider>(
//       builder: (context, todoProvider, child) {
//         if (todoProvider.todos.isEmpty) {
//           return Center(child: Text("Belum ada tugas! Tambahkan sekarang."));
//         }

//         // Sort todos based on status
//         List<Todo> sortedTodos = List.from(todoProvider.todos);
//         if (sortBy == "status") {
//           sortedTodos.sort((a, b) {
//             // Custom sorting order: tinggi, sedang, rendah
//             Map<String, int> statusOrder = {
//               'tinggi': 0,
//               'sedang': 1,
//               'rendah': 2,
//             };
//             return statusOrder[a.status]!.compareTo(statusOrder[b.status]!);
//           });
//         } else if (sortBy == "deadline") {
//           sortedTodos.sort((a, b) {
//             DateTime dateA = DateTime.tryParse(a.deadline) ?? DateTime.now();
//             DateTime dateB = DateTime.tryParse(b.deadline) ?? DateTime.now();
//             return dateA.compareTo(dateB);
//           });
//         }

//         return Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Text(
//                     "Sort by: ",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(width: 8),
//                   ChoiceChip(
//                     label: Text("Status"),
//                     selected: sortBy == "status",
//                     onSelected: (selected) {
//                       if (selected) {
//                         setState(() {
//                           sortBy = "status";
//                         });
//                       }
//                     },
//                   ),
//                   SizedBox(width: 8),
//                   ChoiceChip(
//                     label: Text("Deadline"),
//                     selected: sortBy == "deadline",
//                     onSelected: (selected) {
//                       if (selected) {
//                         setState(() {
//                           sortBy = "deadline";
//                         });
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: sortedTodos.length,
//                 itemBuilder: (context, index) {
//                   final todo = sortedTodos[index];

//                   // Get status color
//                   Color statusColor;
//                   switch (todo.status) {
//                     case 'tinggi':
//                       statusColor = Colors.red;
//                       break;
//                     case 'sedang':
//                       statusColor = Colors.orange;
//                       break;
//                     default:
//                       statusColor = Colors.green;
//                   }

//                   return Card(
//                     margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//                     elevation: 3,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                       side: BorderSide(color: statusColor, width: 2),
//                     ),
//                     child: ListTile(
//                       contentPadding: EdgeInsets.all(10),
//                       title: Text(
//                         todo.title,
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 18,
//                         ),
//                       ),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(height: 5),
//                           Text("Deskripsi: ${todo.description}"),
//                           Row(
//                             children: [
//                               Chip(
//                                 label: Text(todo.label.title),
//                                 backgroundColor: Colors.blue.shade100,
//                               ),
//                               SizedBox(width: 5),
//                               Chip(
//                                 label: Text(todo.category.title),
//                                 backgroundColor: Colors.purple.shade100,
//                               ),
//                             ],
//                           ),
//                           Row(
//                             children: [
//                               Chip(
//                                 label: Text(todo.status),
//                                 backgroundColor: statusColor.withOpacity(0.2),
//                                 labelStyle: TextStyle(color: statusColor),
//                               ),
//                               SizedBox(width: 5),
//                               Icon(Icons.calendar_today, size: 16),
//                               SizedBox(width: 5),
//                               Text(todo.deadline),
//                             ],
//                           ),
//                         ],
//                       ),
//                       trailing: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           IconButton(
//                             icon: Icon(Icons.edit, color: Colors.blue),
//                             onPressed: () => _showEditTodoDialog(todo),
//                           ),
//                           IconButton(
//                             icon: Icon(Icons.delete, color: Colors.red),
//                             onPressed:
//                                 () => _showDeleteDialog(
//                                   () => todoProvider.deleteTodo(todo.id),
//                                 ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ==============================
//   // MODAL EDIT TODO
//   // ==============================
//   void _showEditTodoDialog(Todo todo) {
//     final TextEditingController _titleController = TextEditingController(
//       text: todo.title,
//     );
//     final TextEditingController _descriptionController = TextEditingController(
//       text: todo.description,
//     );
//     final TextEditingController _deadlineController = TextEditingController(
//       text: todo.deadline,
//     );

//     // Make sure category and label are not null
//     String _selectedCategory = todo.category?.id?.toString() ?? "0";
//     String _selectedLabel = todo.label?.id?.toString() ?? "0";
//     String _selectedStatus = todo.status;
//     DateTime? _selectedDate = DateTime.tryParse(todo.deadline);

//     final categoryProvider = Provider.of<CategoryProvider>(
//       context,
//       listen: false,
//     );
//     final labelProvider = Provider.of<LabelProvider>(context, listen: false);

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Edit Todo"),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: "Nama Todo",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: "Deskripsi",
//                     border: OutlineInputBorder(),
//                   ),
//                   maxLines: 3,
//                 ),
//                 SizedBox(height: 10),
//                 DropdownButtonFormField<String>(
//                   value: _selectedCategory != "0" ? _selectedCategory : null,
//                   hint: Text("Pilih Kategori"),
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 15,
//                     ),
//                   ),
//                   items:
//                       categoryProvider.categories.map((category) {
//                         return DropdownMenuItem(
//                           value: category.id.toString(),
//                           child: Text(category.title),
//                         );
//                       }).toList(),
//                   onChanged: (value) {
//                     _selectedCategory = value ?? "0";
//                   },
//                 ),
//                 SizedBox(height: 10),
//                 DropdownButtonFormField<String>(
//                   value: _selectedLabel != "0" ? _selectedLabel : null,
//                   hint: Text("Pilih Label"),
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 15,
//                     ),
//                   ),
//                   items:
//                       labelProvider.labels.map((label) {
//                         return DropdownMenuItem(
//                           value: label.id.toString(),
//                           child: Text(label.title),
//                         );
//                       }).toList(),
//                   onChanged: (value) {
//                     _selectedLabel = value ?? "0";
//                   },
//                 ),
//                 SizedBox(height: 10),
//                 DropdownButtonFormField<String>(
//                   value: _selectedStatus,
//                   decoration: InputDecoration(
//                     labelText: "Status",
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 15,
//                     ),
//                   ),
//                   items:
//                       ['rendah', 'sedang', 'tinggi'].map((status) {
//                         return DropdownMenuItem(
//                           value: status,
//                           child: Text(status),
//                         );
//                       }).toList(),
//                   onChanged: (value) {
//                     _selectedStatus = value!;
//                   },
//                 ),
//                 SizedBox(height: 10),
//                 InkWell(
//                   onTap: () async {
//                     DateTime? pickedDate = await showDatePicker(
//                       context: context,
//                       initialDate: _selectedDate ?? DateTime.now(),
//                       firstDate: DateTime.now(),
//                       lastDate: DateTime(2100),
//                     );

//                     if (pickedDate != null) {
//                       setState(() {
//                         _selectedDate = pickedDate;
//                         _deadlineController.text = DateFormat(
//                           'yyyy-MM-dd',
//                         ).format(pickedDate);
//                       });
//                     }
//                   },
//                   child: InputDecorator(
//                     decoration: InputDecoration(
//                       labelText: "Deadline",
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.calendar_today),
//                     ),
//                     child: Text(_deadlineController.text),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: Text("Batal"),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             ElevatedButton(
//               child: Text("Simpan"),
//               onPressed: () {
//                 final int? categoryId = int.tryParse(_selectedCategory);
//                 final int? labelId = int.tryParse(_selectedLabel);

//                 // Make sure category and label are not null or 0
//                 if (categoryId == null || categoryId == 0) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Kategori tidak valid")),
//                   );
//                   return;
//                 }
//                 if (labelId == null || labelId == 0) {
//                   ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(SnackBar(content: Text("Label tidak valid")));
//                   return;
//                 }

//                 Provider.of<TodoProvider>(
//                   context,
//                   listen: false,
//                 ).updateTodo(todo.id, {
//                   "title": _titleController.text.trim(),
//                   "description": _descriptionController.text.trim(),
//                   "category_id": categoryId,
//                   "label_id": labelId,
//                   "status": _selectedStatus,
//                   "deadline": _deadlineController.text.trim(),
//                 });

//                 if (_selectedDate != null) {}

//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ==============================
//   // TAB CATEGORIES
//   // ==============================
//   Widget _buildCategoryTab() {
//     return Consumer<CategoryProvider>(
//       builder: (context, categoryProvider, child) {
//         if (categoryProvider.categories.isEmpty) {
//           return Center(child: Text("Belum ada kategori!"));
//         }
//         return ListView.builder(
//           itemCount: categoryProvider.categories.length,
//           itemBuilder: (context, index) {
//             final category = categoryProvider.categories[index];
//             return _buildListItem(
//               category.title,
//               () => _showDeleteDialog(
//                 () => categoryProvider.deleteCategory(category.id),
//               ),
//               onEdit: () => _showEditCategoryDialog(category),
//               color: Colors.purple.shade100,
//             );
//           },
//         );
//       },
//     );
//   }

//   // ==============================
//   // MODAL EDIT CATEGORY
//   // ==============================
//   void _showEditCategoryDialog(Category category) {
//     final TextEditingController _controller = TextEditingController(
//       text: category.title,
//     );

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Edit Category"),
//           content: TextField(
//             controller: _controller,
//             decoration: InputDecoration(
//               labelText: "Nama Category",
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: Text("Batal"),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             ElevatedButton(
//               child: Text("Simpan"),
//               onPressed: () {
//                 Provider.of<CategoryProvider>(
//                   context,
//                   listen: false,
//                 ).updateCategory(category.id.toString(), {
//                   "title": _controller.text.trim(),
//                 });

//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ==============================
//   // TAB LABELS
//   // ==============================
//   Widget _buildLabelTab() {
//     return Consumer<LabelProvider>(
//       builder: (context, labelProvider, child) {
//         if (labelProvider.labels.isEmpty) {
//           return Center(child: Text("Belum ada label!"));
//         }
//         return ListView.builder(
//           itemCount: labelProvider.labels.length,
//           itemBuilder: (context, index) {
//             final label = labelProvider.labels[index];
//             return _buildListItem(
//               label.title,
//               () =>
//                   _showDeleteDialog(() => labelProvider.deleteLabel(label.id)),
//               onEdit: () => _showEditLabelDialog(label),
//               color: Colors.blue.shade100,
//             );
//           },
//         );
//       },
//     );
//   }

//   // ==============================
//   // MODAL EDIT LABEL
//   // ==============================
//   void _showEditLabelDialog(Label label) {
//     final TextEditingController _controller = TextEditingController(
//       text: label.title,
//     );

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Edit Label"),
//           content: TextField(
//             controller: _controller,
//             decoration: InputDecoration(
//               labelText: "Nama Label",
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: Text("Batal"),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             ElevatedButton(
//               child: Text("Simpan"),
//               onPressed: () async {
//                 final updatedTitle = _controller.text.trim();

//                 if (updatedTitle.isNotEmpty) {
//                   await Provider.of<LabelProvider>(
//                     context,
//                     listen: false,
//                   ).updateLabel(label.id.toString(), {"title": updatedTitle});

//                   // Update state to see changes immediately
//                   setState(() {});

//                   // Close dialog
//                   Navigator.of(context).pop();
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ==============================
//   // WIDGET LIST ITEM
//   // ==============================
//   Widget _buildListItem(
//     String title,
//     VoidCallback onDelete, {
//     VoidCallback? onEdit,
//     Color? color,
//   }) {
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: ListTile(
//         leading: CircleAvatar(
//           backgroundColor: color ?? Colors.grey.shade200,
//           child: Text(title.isNotEmpty ? title[0].toUpperCase() : "?"),
//         ),
//         title: Text(title),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (onEdit != null)
//               IconButton(
//                 icon: Icon(Icons.edit, color: Colors.blue),
//                 onPressed: onEdit,
//               ),
//             IconButton(
//               icon: Icon(Icons.delete, color: Colors.red),
//               onPressed: onDelete,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // ==============================
//   // MODAL KONFIRMASI HAPUS
//   // ==============================
//   void _showDeleteDialog(VoidCallback onConfirm) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Konfirmasi"),
//           content: Text("Apakah Anda yakin ingin menghapus item ini?"),
//           actions: [
//             TextButton(
//               child: Text("Batal"),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//               child: Text("Hapus"),
//               onPressed: () {
//                 onConfirm();
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ==============================
//   // MODAL TAMBAH TODO
//   // ==============================
//   void _showAddTodoDialog() {
//     final TextEditingController _titleController = TextEditingController();
//     final TextEditingController _descriptionController =
//         TextEditingController();
//     final TextEditingController _deadlineController = TextEditingController();

//     DateTime? _selectedDeadline;
//     String? _selectedCategory;
//     String? _selectedLabel;
//     String _selectedStatus = "rendah"; // Default status

//     final categoryProvider = Provider.of<CategoryProvider>(
//       context,
//       listen: false,
//     );
//     final labelProvider = Provider.of<LabelProvider>(context, listen: false);

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Tambah Todo"),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: _titleController,
//                   decoration: InputDecoration(
//                     labelText: "Nama Todo",
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 TextField(
//                   controller: _descriptionController,
//                   decoration: InputDecoration(
//                     labelText: "Deskripsi",
//                     border: OutlineInputBorder(),
//                   ),
//                   maxLines: 3,
//                 ),
//                 SizedBox(height: 10),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: "Pilih Kategori",
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 15,
//                     ),
//                   ),
//                   value: _selectedCategory,
//                   items:
//                       categoryProvider.categories.map((category) {
//                         return DropdownMenuItem(
//                           value: category.id.toString(),
//                           child: Text(category.title),
//                         );
//                       }).toList(),
//                   onChanged: (value) {
//                     _selectedCategory = value;
//                   },
//                 ),
//                 SizedBox(height: 10),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: "Pilih Label",
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 15,
//                     ),
//                   ),
//                   value: _selectedLabel,
//                   items:
//                       labelProvider.labels.map((label) {
//                         return DropdownMenuItem(
//                           value: label.id.toString(),
//                           child: Text(label.title),
//                         );
//                       }).toList(),
//                   onChanged: (value) {
//                     _selectedLabel = value;
//                   },
//                 ),
//                 SizedBox(height: 10),
//                 DropdownButtonFormField<String>(
//                   decoration: InputDecoration(
//                     labelText: "Status",
//                     border: OutlineInputBorder(),
//                     contentPadding: EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 15,
//                     ),
//                   ),
//                   value: _selectedStatus,
//                   items:
//                       ['rendah', 'sedang', 'tinggi'].map((status) {
//                         return DropdownMenuItem(
//                           value: status,
//                           child: Text(status),
//                         );
//                       }).toList(),
//                   onChanged: (value) {
//                     _selectedStatus = value!;
//                   },
//                 ),
//                 SizedBox(height: 10),
//                 InkWell(
//                   onTap: () async {
//                     DateTime? pickedDate = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now(),
//                       firstDate: DateTime.now(),
//                       lastDate: DateTime(2100),
//                     );

//                     if (pickedDate != null) {
//                       setState(() {
//                         _selectedDeadline = pickedDate;
//                         _deadlineController.text = DateFormat(
//                           'yyyy-MM-dd',
//                         ).format(pickedDate);
//                       });
//                     }
//                   },
//                   child: InputDecorator(
//                     decoration: InputDecoration(
//                       labelText: "Deadline",
//                       border: OutlineInputBorder(),
//                       suffixIcon: Icon(Icons.calendar_today),
//                     ),
//                     child: Text(
//                       _selectedDeadline == null
//                           ? "Pilih Deadline"
//                           : DateFormat('yyyy-MM-dd').format(_selectedDeadline!),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: Text("Batal"),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             ElevatedButton(
//               child: Text("Tambah"),
//               onPressed: () {
//                 final String title = _titleController.text.trim();
//                 final String description = _descriptionController.text.trim();

//                 if (title.isEmpty) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Judul tidak boleh kosong")),
//                   );
//                   return;
//                 }

//                 if (_selectedCategory == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Pilih kategori terlebih dahulu")),
//                   );
//                   return;
//                 }

//                 if (_selectedLabel == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Pilih label terlebih dahulu")),
//                   );
//                   return;
//                 }

//                 if (_selectedDeadline == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Pilih deadline terlebih dahulu")),
//                   );
//                   return;
//                 }

//                 String formattedDeadline = DateFormat(
//                   'yyyy-MM-dd',
//                 ).format(_selectedDeadline!);

//                 Provider.of<TodoProvider>(context, listen: false).addTodo({
//                   "title": title,
//                   "description": description,
//                   "category_id": _selectedCategory,
//                   "label_id": _selectedLabel,
//                   "status": _selectedStatus,
//                   "deadline": formattedDeadline,
//                 });

//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ==============================
//   // MODAL TAMBAH CATEGORY
//   // ==============================
//   void _showAddCategoryDialog() {
//     final TextEditingController _controller = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Tambah Category"),
//           content: TextField(
//             controller: _controller,
//             decoration: InputDecoration(
//               labelText: "Nama Category",
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: Text("Batal"),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             ElevatedButton(
//               child: Text("Tambah"),
//               onPressed: () {
//                 final String title = _controller.text.trim();
//                 if (title.isNotEmpty) {
//                   Provider.of<CategoryProvider>(
//                     context,
//                     listen: false,
//                   ).addCategory({"title": title});
//                   Navigator.of(context).pop();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Nama kategori tidak boleh kosong")),
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // ==============================
//   // MODAL TAMBAH LABEL
//   // ==============================
//   void _showAddLabelDialog() {
//     final TextEditingController _controller = TextEditingController();

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text("Tambah Label"),
//           content: TextField(
//             controller: _controller,
//             decoration: InputDecoration(
//               labelText: "Nama Label",
//               border: OutlineInputBorder(),
//             ),
//           ),
//           actions: [
//             TextButton(
//               child: Text("Batal"),
//               onPressed: () => Navigator.of(context).pop(),
//             ),
//             ElevatedButton(
//               child: Text("Tambah"),
//               onPressed: () {
//                 final String title = _controller.text.trim();
//                 if (title.isNotEmpty) {
//                   Provider.of<LabelProvider>(
//                     context,
//                     listen: false,
//                   ).addLabel({"title": title});
//                   Navigator.of(context).pop();
//                 } else {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     SnackBar(content: Text("Nama label tidak boleh kosong")),
//                   );
//                 }
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
