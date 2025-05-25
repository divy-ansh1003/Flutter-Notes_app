import 'package:flutter/material.dart';
import '../db/notes_database.dart';
import '../model/note.dart';
import 'note_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notes = [];
  List<Note> filteredNotes = [];
  String searchQuery = '';
  String selectedCategory = 'All';

  final categories = ['All', 'Personal', 'Work', 'Other'];

  @override
  void initState() {
    super.initState();
    refreshNotes();
  }

  Future refreshNotes() async {
    final data = await NotesDatabase.instance.readAllNotes();
    setState(() {
      notes = data;
      applyFilters();
    });
  }

  void applyFilters() {
    filteredNotes = notes.where((note) {
      final matchesSearch = note.title.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedCategory == 'All' || note.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      applyFilters();
    });
  }

  void onCategoryChanged(String? category) {
    if (category != null) {
      setState(() {
        selectedCategory = category;
        applyFilters();
      });
    }
  }

  void openForm([Note? note]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteForm(note: note)),
    );
    if (result == true) refreshNotes();
  }

  Future deleteNote(int id) async {
    await NotesDatabase.instance.delete(id);
    refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes App')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: onCategoryChanged,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: filteredNotes.isEmpty
                  ? const Center(child: Text('No notes'))
                  : ListView.builder(
                      itemCount: filteredNotes.length,
                      itemBuilder: (_, index) {
                        final note = filteredNotes[index];
                        return Card(
                          child: ListTile(
                            title: Text(note.title),
                            subtitle: Text(note.category),
                            onTap: () => openForm(note),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => deleteNote(note.id!),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
