import 'package:flutter/material.dart';
import '../db/notes_database.dart';
import '../model/note.dart';

class NoteForm extends StatefulWidget {
  final Note? note;

  const NoteForm({super.key, this.note});

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final _formKey = GlobalKey<FormState>();
  late String title;
  late String content;
  late String category;

  final categories = ['Personal', 'Work', 'Other'];

  @override
  void initState() {
    super.initState();
    title = widget.note?.title ?? '';
    content = widget.note?.content ?? '';
    category = widget.note?.category ?? categories[0];
  }

  Future<void> saveNote() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newNote = Note(
        id: widget.note?.id,
        title: title,
        content: content,
        category: category,
      );

      try {
        if (widget.note == null) {
          await NotesDatabase.instance.create(newNote);
        } else {
          await NotesDatabase.instance.update(newNote);
        }

        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.note == null ? 'Add Note' : 'Edit Note')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
                onSaved: (val) => title = val!,
              ),
              const SizedBox(height: 10),
              TextFormField(
                initialValue: content,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 3,
                onSaved: (val) => content = val ?? '',
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => category = val);
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveNote,
                child: Text(widget.note == null ? 'Save Note' : 'Update Note'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
