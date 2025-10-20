// -----------------------------------------------------------
// Filename: lib/main.dart
// CSC 4360/6370 - Mobile App Development CW-03
// -----------------------------------------------------------

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// -----------------------------------------------------------
// 1. Task Data Model (Extended for Graduate Students)
// -----------------------------------------------------------

// Enum for Task Priority (Graduate Student Requirement) [cite: 37, 38]
enum Priority { Low, Medium, High }

class Task {
  String name;
  bool isCompleted; // Completion Status [cite: 21, 15]
  Priority priority; // Task Priority (Graduate Student Requirement) [cite: 49]

  Task({
    required this.name,
    this.isCompleted = false,
    this.priority = Priority.Low,
  });

  // Serialization to JSON for Persistence [cite: 45]
  Map<String, dynamic> toJson() => {
    'name': name,
    'isCompleted': isCompleted,
    'priority': priority.index,
  };

  // Deserialization from JSON for Persistence [cite: 45]
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    name: json['name'],
    isCompleted: json['isCompleted'],
    priority: Priority.values[json['priority'] ?? 0],
  );
}

// -----------------------------------------------------------
// 2. Main Application Widget
// -----------------------------------------------------------

void main() {
  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({super.key});

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> {
  // State for Theming (All Must Do) [cite: 46]
  bool _isDarkMode = false;

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Task Manager',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light, // Apply theme based on state [cite: 46]
      home: TaskListScreen(toggleTheme: _toggleTheme, isDarkMode: _isDarkMode),
    );
  }
}

// -----------------------------------------------------------
// 3. Task List Screen (Stateful Widget)
// -----------------------------------------------------------

class TaskListScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const TaskListScreen({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  // Create a Stateful Widget [cite: 18]
  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // List of tasks as an instance variable [cite: 21]
  List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  // State for new task priority selection (Graduate Student Requirement) [cite: 40]
  Priority _selectedPriority = Priority.Low;

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks on startup [cite: 45]
  }

  // Helper to convert Priority Enum to a readable string
  String _priorityToString(Priority priority) {
    return priority.toString().split('.').last;
  }

  // -----------------------------------------------------------
  // Persistence (All Must Do) [cite: 45]
  // -----------------------------------------------------------

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getStringList('tasks') ?? [];
    setState(() {
      _tasks = tasksJson
          .map((jsonString) => Task.fromJson(json.decode(jsonString)))
          .toList();
      _sortTasks(); // Sort after loading [cite: 51]
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson =
    _tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  // -----------------------------------------------------------
  // Task Management Logic (CRUD) [cite: 5, 17, 23, 24]
  // -----------------------------------------------------------

  // Function to sort tasks by priority (High > Medium > Low)
  void _sortTasks() {
    _tasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
  }

  // Create/Add Task [cite: 5, 30, 34]
  void _addTask() {
    final name = _taskController.text.trim();
    if (name.isNotEmpty) {
      // Use setState to update the state of the task list [cite: 25]
      setState(() {
        _tasks.add(Task(name: name, priority: _selectedPriority));
        _taskController.clear();
        _selectedPriority = Priority.Low; // Reset priority
        _sortTasks();
        _saveTasks();
      });
    }
  }

  // Update/Complete Task [cite: 5, 30, 35]
  void _toggleTaskCompletion(Task task) {
    // Use setState to update the state of the task list and UI [cite: 25, 29]
    setState(() {
      task.isCompleted = !task.isCompleted;
      _saveTasks();
    });
  }

  // Delete/Remove Task [cite: 5, 30, 36]
  void _deleteTask(Task task) {
    // Use setState to update the state of the task list and UI [cite: 25, 29]
    setState(() {
      _tasks.remove(task);
      _saveTasks();
    });
  }

  // Update Priority (Graduate Student Requirement) [cite: 43]
  void _updatePriority(Task task, Priority newPriority) {
    setState(() {
      task.priority = newPriority;
      _sortTasks();
      _saveTasks();
    });
  }

  // -----------------------------------------------------------
  // UI Implementation [cite: 7, 28]
  // -----------------------------------------------------------

  // UI for Task Input and Controls [cite: 8, 11]
  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _taskController,
                  decoration: const InputDecoration(
                    hintText: 'Enter new task name', // Text input field [cite: 8]
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Add Button [cite: 11, 34]
              IconButton(
                icon: const Icon(Icons.add, size: 30),
                onPressed: _addTask,
                tooltip: 'Add Task',
              ),
            ],
          ),
          // Priority Selector (Graduate Student Requirement) [cite: 40]
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Priority:', style: TextStyle(fontSize: 16)),
                DropdownButton<Priority>(
                  value: _selectedPriority,
                  onChanged: (Priority? newValue) {
                    setState(() {
                      _selectedPriority = newValue ?? Priority.Low;
                    });
                  },
                  items: Priority.values.map((Priority priority) {
                    return DropdownMenuItem<Priority>(
                      value: priority,
                      child: Text(_priorityToString(priority)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Task List Item UI [cite: 13, 14]
  Widget _buildTaskItem(Task task) {
    return ListTile(
      leading: Checkbox(
        value: task.isCompleted, // Checkbox to mark task as completed [cite: 15]
        onChanged: (bool? newValue) {
          _toggleTaskCompletion(task); // Implement completion functionality [cite: 35]
        },
      ),
      title: Text(
        task.name,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          color: task.isCompleted ? Colors.grey : null,
        ),
      ),
      subtitle: Text(
        'Priority: ${_priorityToString(task.priority)}', // Display priority [cite: 41, 50]
        style: TextStyle(
            color: task.priority == Priority.High
                ? Colors.red
                : task.priority == Priority.Medium
                ? Colors.orange
                : Colors.blueGrey),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Button for changing priority (Graduate Student Requirement) [cite: 43]
          PopupMenuButton<Priority>(
            onSelected: (Priority result) {
              _updatePriority(task, result);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Priority>>[
              ...Priority.values.map((p) => PopupMenuItem<Priority>(
                value: p,
                child: Text('Set to ${_priorityToString(p)}'),
              )),
            ],
            icon: const Icon(Icons.edit_note, size: 20),
          ),
          // Delete Button [cite: 16, 36]
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteTask(task), // Implement removal functionality [cite: 36]
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager (CW-03)'),
        actions: [
          // Light/Dark mode toggle (All Must Do) [cite: 46]
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
            tooltip: widget.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          _buildInputArea(),
          const Divider(),
          // List View to display the task list [cite: 13]
          Expanded(
            child: _tasks.isEmpty
                ? const Center(child: Text('No tasks yet! Add one above.'))
                : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return _buildTaskItem(_tasks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}