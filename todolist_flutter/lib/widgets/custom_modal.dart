import 'package:flutter/material.dart';

class CustomModal extends StatefulWidget {
  final String title;
  final List<CustomModalField> fields;
  final void Function(Map<String, dynamic>) onSubmit;

  CustomModal({
    required this.title,
    required this.fields,
    required this.onSubmit,
  });

  @override
  _CustomModalState createState() => _CustomModalState();
}

class _CustomModalState extends State<CustomModal> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};

  @override
  void initState() {
    super.initState();
    for (var field in widget.fields) {
      _formData[field.name] = field.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.fields.map((field) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: _buildField(field),
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Batal"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSubmit(_formData);
              Navigator.pop(context);
            }
          },
          child: Text("Simpan"),
        ),
      ],
    );
  }

  Widget _buildField(CustomModalField field) {
    if (field.type == FieldType.dropdown) {
      return DropdownButtonFormField<int>(
        value: _formData[field.name],
        decoration: InputDecoration(labelText: field.label),
        items: field.options!.map((option) {
          return DropdownMenuItem(value: option.id, child: Text(option.name));
        }).toList(),
        onChanged: (value) => setState(() => _formData[field.name] = value),
        validator: (value) => value == null ? "${field.label} wajib dipilih" : null,
      );
    }

    if (field.type == FieldType.date) {
      return TextFormField(
        decoration: InputDecoration(
          labelText: field.label,
          suffixIcon: Icon(Icons.calendar_today),
        ),
        readOnly: true,
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              _formData[field.name] = pickedDate.toIso8601String().split('T')[0];
            });
          }
        },
        controller: TextEditingController(text: _formData[field.name] ?? ""),
      );
    }

    return TextFormField(
      decoration: InputDecoration(labelText: field.label),
      initialValue: field.initialValue,
      validator: (value) => value!.isEmpty ? "${field.label} wajib diisi" : null,
      onSaved: (value) => _formData[field.name] = value!,
    );
  }
}

class CustomModalField {
  final String name;
  final String label;
  final FieldType type;
  final String? initialValue;
  final List<DropdownOption>? options;

  CustomModalField({
    required this.name,
    required this.label,
    this.type = FieldType.text,
    this.initialValue,
    this.options,
  });
}

enum FieldType { text, dropdown, date }

class DropdownOption {
  final int id;
  final String name;

  DropdownOption(this.id, this.name);
}
