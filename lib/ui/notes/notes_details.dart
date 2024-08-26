import 'package:flutter/material.dart';
import 'package:one/services/database_helper.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class NoteDetailPage extends StatefulWidget {
  final Map<String, dynamic>? note;

  NoteDetailPage({this.note});

  @override
  _NoteDetailPageState createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Color _backgroundColor = Colors.white;
  Color _titleColor = Colors.black;
  Color _contentColor = Colors.black;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!['title'] ?? '';
      _contentController.text = widget.note!['content'] ?? '';
      _backgroundColor = Color(widget.note!['backgroundColor'] ?? Colors.white.value);
      _titleColor = Color(widget.note!['titleColor'] ?? Colors.black.value);
      _contentColor = Color(widget.note!['contentColor'] ?? Colors.black.value);
    }
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isNotEmpty && content.isNotEmpty) {
      final note = {
        'title': title,
        'content': content,
        'timestamp': DateTime.now().toIso8601String(),
        'backgroundColor': _backgroundColor.value,
        'titleColor': _titleColor.value,
        'contentColor': _contentColor.value,
      };

      if (widget.note == null) {
        var uuid = Uuid();
        note['id'] = uuid.v4();
        await _dbHelper.addNote(note);
      } else {
        note['id'] = widget.note!['id'];
        await _dbHelper.updateNote(note);
      }

      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteNote() async {
    if (widget.note != null) {
      await _dbHelper.deleteNote(widget.note!['id']);
      Navigator.pop(context, true);
    }
  }

  void _pickBackgroundColor() {
    _showColorPicker('Pick a background color', _backgroundColor, (color) {
      setState(() {
        _backgroundColor = color;
      });
    });
  }

  void _pickTitleColor() {
    _showColorPicker('Pick a title color', _titleColor, (color) {
      setState(() {
        _titleColor = color;
      });
    });
  }

  void _pickContentColor() {
    _showColorPicker('Pick a content color', _contentColor, (color) {
      setState(() {
        _contentColor = color;
      });
    });
  }

  void _showColorPicker(String title, Color initialColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: onColorChanged,
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: Icon(Icons.color_lens),
            onPressed: _pickBackgroundColor,
          ),
          IconButton(
            icon: Icon(Icons.text_fields),
            onPressed: _pickTitleColor,
          ),
          IconButton(
            icon: Icon(Icons.text_format),
            onPressed: _pickContentColor,
          ),
          IconButton(
            icon: Icon(Icons.save_sharp),
            onPressed: _saveNote,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteNote,
          ),
        ],
      ),
      body: Container(
        color: _backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.4),
                ),
                style: TextStyle(
                  color: _titleColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.7),
                  ),
                  style: TextStyle(color: _contentColor),
                  maxLines: null,
                  expands: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}