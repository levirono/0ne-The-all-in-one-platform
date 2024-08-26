import 'package:flutter/material.dart';
import 'package:one/services/auth.dart';
import 'package:one/services/database_helper.dart';
import 'package:one/services/firestore_service.dart';
import 'package:one/ui/todos/create_todo.dart';
import 'package:one/ui/todos/view_todo.dart';

class TodosPage extends StatefulWidget {
  @override
  _TodosPageState createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  List<Map<String, dynamic>> _todos = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  String _selectedFilter = 'All';
  final List<String> _filterOptions = ['All', 'Day', 'Week', 'Month', 'Custom', 'No timeframe'];

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await _dbHelper.getTodos();
    setState(() {
      _todos = todos;
    });
  }

  Future<void> _syncTodosFromFirestore() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        final todos = await _firestoreService.fetchTodos(user.uid);
        for (var todo in todos) {
          await _dbHelper.insertTodo(todo);
        }
        await _loadTodos();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Todos synced successfully from Firestore')),
        );
      }
    } catch (e) {
      print('Error syncing todos from Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to sync todos from Firestore')),
      );
    }
  }

  Widget _buildTodoItem(Map<String, dynamic> todo, BuildContext context) {
    String subtitle = todo['description'] ?? '';
    if (todo['timeframe'] == 'Custom' && todo['customDateTime'] != null) {
      DateTime customDate = DateTime.parse(todo['customDateTime']);
      subtitle += '\n${customDate.toLocal().toString().split('.')[0]}';
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              todo['title'],
              style: TextStyle(
                color: Colors.green[800],
                fontWeight: FontWeight.bold,
                decoration: todo['completed'] == 1
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            Checkbox(
              value: todo['completed'] == 1,
              onChanged: (value) async {
                await _dbHelper.updateTodo(
                  todo['id'],
                  {
                    'title': todo['title'],
                    'description': todo['description'],
                    'timeframe': todo['timeframe'],
                    'customDateTime': todo['customDateTime'],
                    'completed': value == true ? 1 : 0,
                  },
                );
                _loadTodos();
              },
            ),
          ],
        ),
        subtitle: Text(
          (todo['completed'] == 1 ? 'Completed - ' : '') + subtitle,
          style: TextStyle(
            color: Colors.black54,
            decoration: todo['completed'] == 1
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        trailing: Text(
          todo['timeframe'] ?? '',
          style: TextStyle(
            color: Colors.black87,
            decoration: todo['completed'] == 1
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ViewTodoPage(todo: todo),
            ),
          );
          if (result == true) {
            _loadTodos();
          }
        },
      ),
    );
  }

  List<Map<String, dynamic>> _filterTodos(List<Map<String, dynamic>> todos) {
    if (_selectedFilter == 'All') return todos;
    return todos.where((todo) => todo['timeframe'] == _selectedFilter).toList();
  }

  Widget _buildFilterChip(String filter) {
    return ChoiceChip(
      label: Text(filter),
      selected: _selectedFilter == filter,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = selected ? filter : 'All';
        });
      },
      backgroundColor: Colors.white.withOpacity(0.2),
      selectedColor: Colors.white,
      labelStyle: TextStyle(
        color: _selectedFilter == filter ? Colors.purple.shade800 : Colors.black,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos'),
        backgroundColor: Colors.green[100],
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () async {
              final user = await AuthService().getCurrentUser();
              if (user != null) {
                await FirestoreService().syncTodos(user.uid, _todos);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync_alt),
            onPressed: _syncTodosFromFirestore,
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                children: _filterOptions.map((filter) => _buildFilterChip(filter)).toList(),
              ),
            ),
            Expanded(
              child: _todos.isEmpty
                  ? const Center(child: Text('No todos yet. Create one!', style: TextStyle(color: Colors.white)))
                  : ListView.builder(
                      itemCount: _filterTodos(_todos).length,
                      itemBuilder: (context, index) {
                        return _buildTodoItem(_filterTodos(_todos)[index], context);
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateTodoPage(),
            ),
          );
          if (result == true) {
            _loadTodos();
          }
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.white,
        foregroundColor: Colors.purple.shade800,
      ),
    );
  }
}