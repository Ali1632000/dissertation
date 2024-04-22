import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:todolist/constants/colors.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

Future<List<Map<String, dynamic>>> getTasksFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? tasksJson = prefs.getString('tasks');

  if (tasksJson == null) {
    return [];
  }

  List<Map<String, dynamic>> tasks =
      List<Map<String, dynamic>>.from(jsonDecode(tasksJson));
  return tasks;
}

Future<void> deleteTask(String taskId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? tasksJson = prefs.getString('tasks');
  if (tasksJson != null) {
    List<Map<String, dynamic>> tasks =
        List<Map<String, dynamic>>.from(jsonDecode(tasksJson));
    tasks.removeWhere((task) => task['id'] == taskId);
    await prefs.setString('tasks', jsonEncode(tasks));
  }
}

class _NotificationsPageState extends State<NotificationsPage> {
  late Future<List<Map<String, dynamic>>> tasks;

  @override
  void initState() {
    super.initState();
    tasks = getTasksFromSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: tasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text('No Notifications found'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var task = snapshot.data![index];
                DateTime taskDateTime = DateTime.parse(task['dateTime']);
                String formattedDateTime =
                    DateFormat('yyyy-MM-dd – kk:mm').format(taskDateTime);

                return Container(
                  child: ListTile(
                    leading: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: appContainerColor),
                      ),
                      padding: EdgeInsets.all(5),
                      child: const Icon(
                        Icons.notifications,
                        color: appContainerColor,
                      ),
                    ),
                    title: Text(task['title'] ?? 'No Title'),
                    subtitle: Text('Due on: $formattedDateTime'),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.red.shade400,
                      ),
                      onPressed: () async {
                        await deleteTask(task['id']);
                        setState(() {
                          tasks = getTasksFromSharedPreferences();
                        });
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
