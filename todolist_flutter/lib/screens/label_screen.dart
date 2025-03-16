import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/label_provider.dart';
import '../../models/label.dart';

class LabelScreen extends StatefulWidget {
  @override
  _LabelScreenState createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  final TextEditingController _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LabelProvider>(context, listen: false).fetchLabels();
    });
  }

  void _showAddLabelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Tambah Label"),
          content: TextField(
            controller: _labelController,
            decoration: InputDecoration(hintText: "Masukkan nama label"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                if (_labelController.text.isNotEmpty) {
                  Provider.of<LabelProvider>(
                    context,
                    listen: false,
                  ).addLabel({"title": _labelController.text});
                  _labelController.clear();
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
      appBar: AppBar(title: Text("Labels")),
      body: Consumer<LabelProvider>(
        builder: (context, labelProvider, child) {
          if (labelProvider.labels.isEmpty) {
            return Center(child: Text("Belum ada label"));
          }
          return ListView.builder(
            itemCount: labelProvider.labels.length,
            itemBuilder: (context, index) {
              Label label = labelProvider.labels[index];
              return ListTile(
                title: Text(label.title),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    Provider.of<LabelProvider>(
                      context,
                      listen: false,
                    ).deleteLabel(label.id);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLabelDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
