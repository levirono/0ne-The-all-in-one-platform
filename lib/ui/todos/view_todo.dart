import 'package:flutter/material.dart';
import 'dart:convert';

class ViewTodoPage extends StatelessWidget {
  final Map<String, dynamic> todo;

  ViewTodoPage({required this.todo});

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
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    todo['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.purple.shade800.withOpacity(0.7),
                          Colors.blue.shade600.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ),
                backgroundColor: Colors.transparent,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Description',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade800,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                todo['description'],
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Timeframe: ${todo['timeframe']}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade800,
                                ),
                              ),
                              SizedBox(height: 16),
                              _buildTimeframeDetails(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeframeDetails() {
    switch (todo['timeframe']) {
      case 'Week':
        return _buildWeeklyDetails();
      case 'Day':
        return _buildDailyDetails();
      case 'Month':
        return _buildMonthlyDetails();
      case 'Custom':
        return _buildCustomDetails();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildWeeklyDetails() {
    Map<String, dynamic> weeklyTasks = jsonDecode(todo['weeklyTasks']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Week: ${todo['week']}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade600,
          ),
        ),
        SizedBox(height: 8),
        ...weeklyTasks.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text(
                '${entry.key}:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.value,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDailyDetails() {
    Map<String, dynamic> dailyTasks = jsonDecode(todo['dailyTasks']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Schedule',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade600,
          ),
        ),
        SizedBox(height: 8),
        ...dailyTasks.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text(
                '${entry.key}:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.value,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildMonthlyDetails() {
    Map<String, dynamic> monthlyTasks = jsonDecode(todo['monthlyTasks']);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Month: ${todo['month']}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade600,
          ),
        ),
        SizedBox(height: 8),
        ...monthlyTasks.entries.map((entry) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Text(
                'Day ${entry.key}:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple.shade800,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.value,
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildCustomDetails() {
    if (todo['customDateTime'] != null) {
      DateTime customDate = DateTime.parse(todo['customDateTime']);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Date and Time',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '${customDate.toLocal().toString().split('.')[0]}',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      );
    } else {
      return Text(
        'No custom date and time set',
        style: TextStyle(fontSize: 16, color: Colors.black87),
      );
    }
  }
}