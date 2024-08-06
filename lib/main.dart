import 'package:flutter/material.dart';
import 'task.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Habitica Clone'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Habits'),
                Tab(text: 'Dailies'),
                Tab(text: 'To-Dos'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              // Replace these with your actual widgets for each tab
              Center(child: TaskCreationForm(taskType: 'Habits')),
              Center(child: TaskCreationForm(taskType: "Dailies")),
              Center(child: TaskCreationForm(taskType: "To-Dos")),
            ],
          ),
        ),
      ),
    );
  }
}

// Separate widget for the task creation form
class TaskCreationForm extends StatefulWidget {
  final String taskType;
  const TaskCreationForm({Key? key, required this.taskType}) : super(key: key);
  @override
  _TaskCreationFormState createState() => _TaskCreationFormState();
}

class _TaskCreationFormState extends State<TaskCreationForm> {
  String? _selectedTaskType;
  final List<Task> _tasks = [];
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  void removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: const Text('Task removed!')),
    );
  }
  @override
  void initState() {
    super.initState();
    _selectedTaskType = widget.taskType;
    _loadSavedTasks();
  }
  void _loadSavedTasks() {
    List<Task> loadedTasks = _loadTasksFromCSV();
    setState(() {
      _tasks.addAll(loadedTasks);
    });
  }

  void _saveTasksToCSV(List<Task> tasks)  {
    try {
      final appDataDir = Directory.systemTemp;
      final file = File('${appDataDir.path}\\habitica_clone_tasks.csv');
      final sink = file.openWrite();
      sink.writeln('Title,Description,Type');
      for (var task in tasks){
        sink.writeln('${task.title},${task.description},${task.type}');
      }
      sink.close();
      print('Tasks saved to CSV successfully!');
    }
    catch(e) {
      print('Error saving tasks to CSV: $e');
    }
  }
  void _createTask() {
    if (_titleController.text.isNotEmpty && _descriptionController.text.isNotEmpty) {
      setState(() {
        _tasks.add(
          Task(
            title: _titleController.text,
            description: _descriptionController.text,
            type: widget.taskType,
          )
        );
      });
      _titleController.clear();
      _descriptionController.clear();
      _saveTasksToCSV(_tasks);
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: const Text('Please enter a title and description and a type')),
      );
    }
  }
  List<Task> _loadTasksFromCSV() {
    final List<Task> loadedTasks = [];
    try {
      // 1. Get the app data directory
      final appDataDir = Directory.systemTemp;

      // 2. Create a File object for the CSV file
      final file = File('${appDataDir.path}\\habitica_clone_tasks.csv');

      // 3. Check if the file exists
      if (!file.existsSync()) {
        print('No saved tasks found.');
        return loadedTasks;
      }

      // 4. Read the contents of the file
      final contents = file.readAsStringSync();

      // 5. Split the contents into lines
      var rows = contents.split('\n');

      // 6. Iterate through the lines (skipping the header)
      for (var i = 1; i < rows.length; i++) {
        var row = rows[i].trim();
        if (row.isNotEmpty) {
          var contents = row.split(',');
          if (contents.length == 3) {
            var task = Task(
                title: contents[0],
                description: contents[1],
                type: contents[2]
            );
            if (task.type == widget.taskType) {
              loadedTasks.add(task);
            }
          }
        }
      }
    } catch (e) {
      print('Error loading tasks from CSV: $e');
    }
    return loadedTasks;
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text("Habitica clone"),
           TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              hintText: 'Enter task title',
            ),
          ),
           TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              hintText: 'Enter task description',
            ),
          ),
          ElevatedButton(
              onPressed: _createTask,
              child: const Text('Create Task')),
          ElevatedButton(
              onPressed: () => _saveTasksToCSV(_tasks),
              child: const Text('Save tasks to CSV')),
          Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                      key: Key(_tasks[index].title),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white,),
                      ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                        removeTask(index);
                    },
                    child: ListTile(
                      title: Text(_tasks[index].title),
                      subtitle: Text(_tasks[index].description),
                    ),
                  );
                },
              )
          )
        ],
      ),
    );
  }
}