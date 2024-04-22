// Assume you have a Task model and a DatabaseHelper class

import 'package:flutter/material.dart';
import 'package:todolist/local_database/db_helper.dart';
import 'package:todolist/models/task_model.dart'; // Import your Task model

class OfflineTasks extends StatefulWidget {
  @override
  _OfflineTasksState createState() => _OfflineTasksState();
}

class _OfflineTasksState extends State<OfflineTasks> {
  final TaskDatabaseHelper dbHelper = TaskDatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Center(
                child: Text(
                  "AI Todo List",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: EdgeInsets.only(left: 30, top: 10),
                margin: EdgeInsets.only(top: 20, bottom: 10),
                width: MediaQuery.of(context).size.width * 0.8,
                height: 60,
                child: const Text(
                  'All Tasks',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 600,
                child: FutureBuilder<List<Task>>(
                  future: dbHelper.getTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return const Center(
                        child: Text('Error loading tasks'),
                      );
                    } else {
                      List<Task> tasks = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          Task task = tasks[index];
                          return _buildTaskItem(task, index);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        title: Wrap(children: [
          Text(task.title, style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        subtitle: Text(task.description, style: TextStyle(color: Colors.grey)),
        trailing: _buildPriorityIndicator(task.priority!),
      ),
    );
  }
}

Widget _buildPriorityIndicator(String priority) {
  Color priorityColor;
  if (priority == 'high' || priority == 'High') {
    priorityColor = Colors.red;
  } else if (priority == 'medium' || priority == 'Medium') {
    priorityColor = Colors.orange;
  } else {
    priorityColor = Colors.green;
  }
  return CircleAvatar(
    backgroundColor: priorityColor,
    radius: 5,
  );
}
