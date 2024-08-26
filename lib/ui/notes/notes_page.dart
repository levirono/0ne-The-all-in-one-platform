import 'package:flutter/material.dart';
import 'package:one/services/auth.dart';
import 'package:one/services/database_helper.dart';
import 'package:one/services/firestore_service.dart';
import 'package:one/ui/notes/notes_details.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, dynamic>> _notes = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadViewPreference();
  }

  Future<void> _loadNotes() async {
    final notes = await _dbHelper.getNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _loadViewPreference() async {
    final viewPref = await _dbHelper.getAppSetting('isGridView');
    setState(() {
      _isGridView = (viewPref == 'true') ? true : false;
    });
  }

  Future<void> _saveViewPreference(bool isGrid) async {
    await _dbHelper.setAppSetting('isGridView', isGrid.toString());
  }

  Future<void> _syncNotesFromFirestore() async {
    try {
      final user = await AuthService().getCurrentUser();
      if (user != null) {
        final notes = await FirestoreService().fetchNotes(user.uid);
        for (var note in notes) {
          await _dbHelper.addNote(note);
        }
        await _loadNotes();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Notes synced successfully')),
        );
      }
    } catch (e) {
      print('Error syncing notes: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sync notes')),
      );
    }
  }

  Widget _buildNoteItem(Map<String, dynamic> note, BuildContext context) {
    Color backgroundColor = Color(note['backgroundColor'] ?? Colors.white.value);
    Color titleColor = Color(note['titleColor'] ?? Colors.black.value);
    Color contentColor = Color(note['contentColor'] ?? Colors.black.value);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NoteDetailPage(note: note),
          ),
        );
        if (result == true) {
          _loadNotes();
        }
      },
      child: Card(
        elevation: 4,
        margin: EdgeInsets.all(8),
        color: backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                note['content'],
                style: TextStyle(
                  color: contentColor,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () async {
              setState(() {
                _isGridView = !_isGridView;
              });
              await _saveViewPreference(_isGridView);
            },
          ),
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: () async {
              final user = await AuthService().getCurrentUser();
              if (user != null) {
                await FirestoreService().syncNotes(user.uid, _notes);
              }
            },
          ),
          IconButton(
            icon: Icon(Icons.sync_alt),
            onPressed: _syncNotesFromFirestore,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade800,
              Colors.blue.shade600,
              Colors.green.shade500,
            ],
          ),
        ),
        child: _isGridView
            ? GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return _buildNoteItem(_notes[index], context);
                },
              )
            : ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return _buildNoteItem(_notes[index], context);
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NoteDetailPage(),
            ),
          );
          if (result == true) {
            _loadNotes();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}