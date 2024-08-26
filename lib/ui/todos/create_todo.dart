import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:one/services/database_helper.dart';
import 'dart:convert';

class CreateTodoPage extends StatefulWidget {
  @override
  _CreateTodoPageState createState() => _CreateTodoPageState();
}

class _CreateTodoPageState extends State<CreateTodoPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  String _selectedTimeframe = 'No timeframe';
  String _title = '';
  String _description = '';
  int _selectedWeek = 1;
  String _selectedMonth = 'January';
  Map<String, String> _weeklyTasks = {};
  Map<String, String> _dailyTasks = {};
  Map<String, String> _monthlyTasks = {};
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: SafeArea(
          child: Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Create Todo',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                        ),
                        onChanged: (value) => _title = value,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.white70),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white70),
                          ),
                        ),
                        onChanged: (value) => _description = value,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Select Timeframe',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        children: [
                          _buildTimeframeChip('Day'),
                          _buildTimeframeChip('Week'),
                          _buildTimeframeChip('Month'),
                          _buildTimeframeChip('Custom'),
                          _buildTimeframeChip('No timeframe'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (_selectedTimeframe == 'Week')
                        _buildWeekSelector(),
                      if (_selectedTimeframe == 'Day')
                        _buildDaySelector(),
                      if (_selectedTimeframe == 'Month')
                        _buildMonthSelector(),
                      if (_selectedTimeframe == 'Custom')
                        _buildCustomDateTimePicker(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  child: const Text('Create Todo'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.purple.shade800,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _createTodo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeChip(String timeframe) {
    return ChoiceChip(
      label: Text(timeframe),
      selected: _selectedTimeframe == timeframe,
      onSelected: (selected) {
        setState(() {
          _selectedTimeframe = timeframe;
        });
      },
    );
  }

  Widget _buildWeekSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Week',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        DropdownButton<int>(
          value: _selectedWeek,
          dropdownColor: Colors.green[100],
          items: List.generate(52, (index) => DropdownMenuItem(
            value: index + 1,
            child: Text('Week ${index + 1}', style: TextStyle(color: Colors.grey[800])),
          )),
          onChanged: (value) {
            setState(() {
              _selectedWeek = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        ..._buildWeekDayInputs(),
      ],
    );
  }

  List<Widget> _buildWeekDayInputs() {
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
      .map((day) => Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: day,
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
          ),
          onChanged: (value) => _weeklyTasks[day] = value,
        ),
      )).toList();
  }

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Daily Schedule',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 16),
        ...List.generate(24, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: '${index.toString().padLeft(2, '0')}:00',
              labelStyle: const TextStyle(color: Colors.white70),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white70),
              ),
            ),
            onChanged: (value) => _dailyTasks['${index.toString().padLeft(2, '0')}:00'] = value,
          ),
        )),
      ],
    );
  }

  Widget _buildMonthSelector() {
    List<String> months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Month',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        DropdownButton<String>(
          value: _selectedMonth,
          dropdownColor: Colors.purple.shade800,
          items: months.map((month) => DropdownMenuItem(
            value: month,
            child: Text(month, style: const TextStyle(color: Colors.white)),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _selectedMonth = value!;
            });
          },
        ),
        const SizedBox(height: 16),
        ..._buildMonthDayInputs(),
      ],
    );
  }

  List<Widget> _buildMonthDayInputs() {
    return List.generate(31, (index) => Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: 'Day ${index + 1}',
          labelStyle: const TextStyle(color: Colors.white70),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
          ),
        ),
        onChanged: (value) => _monthlyTasks['${index + 1}'] = value,
      ),
    ));
  }

  Widget _buildCustomDateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date and Time',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != _selectedDate) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Text(_selectedDate == null
                  ? 'Select Date'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _selectedTime ?? TimeOfDay.now(),
                );
                if (picked != null && picked != _selectedTime) {
                  setState(() {
                    _selectedTime = picked;
                  });
                }
              },
              child: Text(_selectedTime == null
                  ? 'Select Time'
                  : '${_selectedTime!.format(context)}'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _createTodo() async {
    if (_title.isNotEmpty) {
      Map<String, dynamic> todoData = {
        'title': _title,
        'description': _description,
        'timeframe': _selectedTimeframe,
      };

      if (_selectedTimeframe == 'Week') {
        todoData['week'] = _selectedWeek;
        todoData['weeklyTasks'] = jsonEncode(_weeklyTasks);
      } else if (_selectedTimeframe == 'Day') {
        todoData['dailyTasks'] = jsonEncode(_dailyTasks);
      } else if (_selectedTimeframe == 'Month') {
        todoData['month'] = _selectedMonth;
        todoData['monthlyTasks'] = jsonEncode(_monthlyTasks);
      } else if (_selectedTimeframe == 'Custom') {
        if (_selectedDate != null && _selectedTime != null) {
          DateTime customDateTime = DateTime(
            _selectedDate!.year,
            _selectedDate!.month,
            _selectedDate!.day,
            _selectedTime!.hour,
            _selectedTime!.minute,
          );
          todoData['customDateTime'] = customDateTime.toIso8601String();
        } else {
          Fluttertoast.showToast(
            msg: "Please select both date and time for custom todo",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
          );
          return;
        }
      }

      try {
        int result = await _dbHelper.insertTodo(todoData);
        if (result != -1) {
          print('Todo created successfully with id: $result');
          Fluttertoast.showToast(
            msg: "Todo created successfully!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.green,
            textColor: Colors.white,
            fontSize: 16.0
          );
          Navigator.pop(context);
        } else {
          throw Exception('Failed to insert todo');
        }
      } catch (e) {
        print('Error creating todo: $e');
        Fluttertoast.showToast(
          msg: "Error creating todo. Please try again.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: "Please enter a title for your todo",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
  }
}