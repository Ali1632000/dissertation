// ignore_for_file: unused_local_variable

import 'dart:async';

import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todolist/constants/colors.dart';
import 'package:todolist/providers/fonts_provider.dart';
import 'package:todolist/views/account_screens/account_screen.dart';
import 'package:todolist/views/account_screens/settings_screen.dart';
import 'package:todolist/views/tasks/edit_task_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todolist/views/notifications_view.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// task scheduler when the user logs in.
Future<void> scheduleNotifications() async {
  List<Map<String, dynamic>> tasks = await getTasksFromSharedPreferences();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  tz.initializeTimeZones();

  final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
  final DateTime today =
      DateTime(now.year, now.month, now.day); // Today's date without time

  for (var task in tasks) {
    DateTime taskDateTime = DateTime.parse(task['dateTime']);

    if (!taskDateTime.isUtc) {
      taskDateTime = DateTime(taskDateTime.year, taskDateTime.month,
          taskDateTime.day, taskDateTime.hour, taskDateTime.minute);
    }

    // Check if the task's date is today
    if (DateTime(taskDateTime.year, taskDateTime.month, taskDateTime.day) ==
        today) {
      final tz.TZDateTime scheduledDateTime =
          tz.TZDateTime.from(taskDateTime, tz.local);
      tz.TZDateTime notificationDateTime = scheduledDateTime;

      // If the time is in the past, schedule it for a few seconds from now
      if (scheduledDateTime.isBefore(now)) {
        notificationDateTime = now.add(Duration(seconds: 5));
      }

      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'task_channel_id', 'task_channel_name',
          importance: Importance.max, priority: Priority.high, showWhen: true);

      NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        task['id'].hashCode,
        'Task Reminder',
        task['title'],
        notificationDateTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      // If task is reminded then delete it from shared preferences
      deleteTask(task['id']);
      print("Task time: ${notificationDateTime}");
    }
  }
}

class _HomeScreenState extends State<HomeScreen> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore fb_instance = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance.currentUser!.uid;

  DateTime selectedDate = DateTime.now();

  void showTodayTasksDialogOnButtonPress(BuildContext context) {
    showTodayTasksDialog(context);
  }

// List of Months
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];

  // List of Days
  List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

// Get the Tasks by Date
  Stream<QuerySnapshot> getTasksByDate(DateTime date) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);
    debugPrint('Formatted Date: $formattedDate');
    return fb_instance
        .collection('users')
        .doc(auth)
        .collection('tasks')
        .doc(formattedDate)
        .collection('todos')
        .snapshots();
  }

  List<DocumentSnapshot> sortTasksByPriority(List<DocumentSnapshot> tasks) {
    return tasks
      ..sort((a, b) {
        String priorityA = (a.data() as Map<String, dynamic>)['priority'] ?? '';
        String priorityB = (b.data() as Map<String, dynamic>)['priority'] ?? '';

        if (priorityA == 'high') return -1;
        if (priorityB == 'high') return 1;
        if (priorityA == 'medium') return -1;
        if (priorityB == 'medium') return 1;
        return 0;
      });
  }

  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();

  showNotificationsForSelectedTasks() async {
    final DateTime now = DateTime.now();
    final DateFormat formatter = DateFormat('dd-MM-yyyy');
    final String formattedNow = formatter.format(now);

    FirebaseFirestore fb_instance = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance.currentUser!.uid;

    var query = fb_instance
        .collection('users')
        .doc(auth)
        .collection('tasks')
        .doc(formattedNow)
        .collection('todos')
        .snapshots();
  }

  String formatDate(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  Future<QuerySnapshot> getTodayTasks() async {
    String formattedDate = formatDate(DateTime
        .now()); // Get today's date in the same format as stored in Firestore
    CollectionReference tasks = fb_instance
        .collection('users')
        .doc(auth)
        .collection('tasks')
        .doc(formattedDate)
        .collection('todos');

    return await tasks.get();
  }

  @override
  void initState() {
    print("Init State");
    // TODO: implement initState
    super.initState();

    selectedDate;
    // NotificationService().initNotification();
    showNotificationsForSelectedTasks();
    // NotificationService().showNotification();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    scheduleNotifications(); // Call the function to schedule notifications
    loadFontSettings();
  }

  Future<void> loadFontSettings() async {
    try {
      print("Inside loadFontSettings");
      final provider =
          Provider.of<FontSettingsProvider>(context, listen: false);
      await provider.loadFontSettings();
    } catch (e) {
      print('Error loading font settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    int daysInMonth =
        DateTime(selectedDate.year, selectedDate.month + 1, 0).day;

    return DefaultTabController(
      length: daysInMonth,
      child: Scaffold(
        appBar: AppBar(),
        drawer: Drawer(
          backgroundColor: Theme.of(context).primaryColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Text(
                  'Menu',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              ListTile(
                title: const Text('Account Screen'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AccountScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text('Settings Screen'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor),
          child: const Text(
            "Today's Task",
            style: TextStyle(color: whiteColor),
          ),
          onPressed: () => showTodayTasksDialogOnButtonPress(context),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: height * 0.06),
                Center(
                  child: Text(
                    "AI Todo List",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 35,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: height * 0.03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DropdownButton<int>(
                      value: selectedDate.year,
                      items: List.generate(50, (index) => 2023 + index)
                          .map((int year) {
                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text('$year'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedDate = DateTime(
                              newValue!, selectedDate.month, selectedDate.day);
                        });
                      },
                    ),
                    DropdownButton<int>(
                      value: selectedDate.month,
                      items: List.generate(12, (index) => index + 1)
                          .map((int month) {
                        return DropdownMenuItem<int>(
                          value: month,
                          child: Text(months[month - 1]),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedDate = DateTime(
                              selectedDate.year, newValue!, selectedDate.day);
                        });
                      },
                    ),
                  ],
                ),
                Container(
                  height: height * 0.1,
                  width: double.infinity,
                  child: ButtonsTabBar(
                    duration: 200,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: width * 0.08,
                    ),
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.95),
                    unselectedBackgroundColor: Colors.white,
                    labelStyle: const TextStyle(color: Colors.white),
                    unselectedLabelStyle: const TextStyle(color: Colors.grey),
                    tabs: List.generate(daysInMonth, (index) {
                      DateTime date = DateTime(
                          selectedDate.year, selectedDate.month, index + 1);

                      return Tab(
                          text: '${days[date.weekday - 1]} \n${index + 1}');
                    }),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: width * 0.1),
                  margin: EdgeInsets.only(top: height * 0.02),
                  width: width * 0.9,
                  height: height * 0.04,
                  child: const Text('Task',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  height: height * 0.5,
                  child: TabBarView(
                    children: List.generate(daysInMonth, (index) {
                      DateTime date = DateTime(
                          selectedDate.year, selectedDate.month, index + 1);

                      return StreamBuilder<QuerySnapshot>(
                        stream: getTasksByDate(date),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            debugPrint(snapshot.error.toString());
                            return const Center(
                                child: Text('Something went wrong'));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            // debugPrint('Selected data no task Date: $date');
                            return const Center(
                                child: Text(
                              'No tasks for this date',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.grey),
                            ));
                          }
                          selectedDate = date;
                          List<DocumentSnapshot> sortedTasks =
                              sortTasksByPriority(snapshot.data!.docs);

                          return SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StreamBuilder<QuerySnapshot>(
                                  stream: fb_instance
                                      .collection('users')
                                      .doc(auth)
                                      .collection('tasks')
                                      .doc(formatDate(selectedDate))
                                      .collection('todos')
                                      .where('isCompleted',
                                          isEqualTo:
                                              false) // Filter tasks where isCompleted is false
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CircularProgressIndicator();
                                    }

                                    if (snapshot.data == null ||
                                        snapshot.data!.docs.isEmpty) {
                                      return const Center(
                                          child: Text('No pending tasks.'));
                                    }

                                    List<DocumentSnapshot> pendingTasks =
                                        snapshot.data!.docs;

                                    return Container(
                                      height: height * 0.35,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.03),
                                      width: width * 0.9,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: pendingTasks.length,
                                        itemBuilder: (context, index) {
                                          DocumentSnapshot task =
                                              pendingTasks[index];
                                          Map<String, dynamic> taskData = task
                                              .data() as Map<String, dynamic>;
                                          bool isCompleted =
                                              taskData['isCompleted'] ?? false;
                                          String taskId =
                                              task.id; // Get the task ID

                                          List<String> steps =
                                              taskData['steps'] != null
                                                  ? List<String>.from(
                                                      taskData['steps'])
                                                  : ['no steps to show'];

                                          return _buildTaskItem(
                                            taskData['title'],
                                            taskData['description'],
                                            taskData['priority'],
                                            taskId,
                                            taskData['color'],
                                            steps,
                                            // Pass the task ID
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: width * 0.1, top: height * 0.04),
                                  child: const Text(
                                    "Completed",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                StreamBuilder<QuerySnapshot>(
                                  stream: fb_instance
                                      .collection('users')
                                      .doc(auth)
                                      .collection('tasks')
                                      .doc(formatDate(selectedDate))
                                      .collection('todos')
                                      .where('isCompleted',
                                          isEqualTo:
                                              true) // Filter tasks where isCompleted is true
                                      .snapshots(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }

                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }

                                    List<DocumentSnapshot> completedTasks =
                                        snapshot.data!.docs;

                                    return Container(
                                      height: height * 0.35,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.03),
                                      width: width * 0.9,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: completedTasks.length,
                                        itemBuilder: (context, index) {
                                          DocumentSnapshot task =
                                              completedTasks[index];
                                          var taskData = task.data()
                                              as Map<String, dynamic>;
                                          debugPrint('Task: $taskData');
                                          String taskId = task.id;
                                          String title = 'No Title';
                                          try {
                                            title = task['title'];
                                          } catch (e) {}

                                          String description = 'No description';
                                          try {
                                            description = task['description'];
                                          } catch (e) {}
                                          return ListTile(
                                            leading: Checkbox.adaptive(
                                                fillColor:
                                                    const MaterialStatePropertyAll(
                                                        appContainerColor),
                                                value: true,
                                                onChanged: (value) {
                                                  setState(() {
                                                    value = true;
                                                  });
                                                }),
                                            title: Text(title),

                                            subtitle: Text(description),
                                            trailing: IconButton(
                                                onPressed: () {
                                                  showDeleteConfirmationDialog(
                                                      context, taskId);
                                                },
                                                icon: Icon(Icons.delete)),
                                            // Add more details as needed
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Task"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Call the function to delete the task from Firebase
                deleteTask(taskId);
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteTask(String taskId) async {
    try {
      FirebaseFirestore fb_instance = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance.currentUser!.uid;

      await fb_instance
          .collection('users')
          .doc(auth)
          .collection('tasks')
          .doc(formatDate(selectedDate))
          .collection('todos')
          .doc(taskId)
          .delete();

      // You can also update the UI to reflect the deletion if needed
      // For example, you can remove the task from a local list of tasks

      // Refresh the UI or perform any other necessary actions
      // ...
    } catch (e) {
      // Handle any errors that might occur during deletion
      print("Error deleting task: $e");
    }
  }

  Future<void> showTodayTasksDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(16),
            child: StreamBuilder<QuerySnapshot>(
              stream: getTodayTasks()
                  .asStream(), // Use snapshots() to listen for updates
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No tasks for today.');
                }

                return ListView(
                  shrinkWrap: true,
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['title']),
                      subtitle: Text(data['description']),
                      // Add more details as needed
                    );
                  }).toList(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> updatePendingtoCompleted(String taskId, bool isCompleted) async {
    FirebaseFirestore fb_instance = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance.currentUser!.uid;

    await fb_instance
        .collection('users')
        .doc(auth)
        .collection('tasks')
        .doc(formatDate(selectedDate))
        .collection('todos')
        .doc(taskId)
        .update({
      'isCompleted': true,
    });
  }

  Widget _buildTaskItem(String title, String description, String priority,
      String taskId, int? colorValue, List<String> tasksSteps) {
    String truncatedDescription = (description.length > 20)
        ? description.substring(0, 20) + '...'
        : description;

    bool isTaskCompleted =
        false; // You can set the initial value of the checkbox here

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      title: Wrap(children: [
        Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      ]),
      subtitle: Text(
        truncatedDescription,
        style: TextStyle(color: Colors.grey),
      ),
      leading: Checkbox(
        value: isTaskCompleted,
        onChanged: (newValue) {
          setState(() {
            isTaskCompleted = newValue ?? false;
          });
          updatePendingtoCompleted(taskId, newValue!);
        },
      ),
      trailing: Wrap(
        spacing: 1,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditTaskScreen(
                  taskID: taskId,
                  title: title,
                  description: truncatedDescription,
                  priority: priority,
                  colorValue: colorValue,
                  tasksSteps: tasksSteps,
                ),
              ));
            },
            icon: const Icon(
              Icons.edit,
              color: appContainerColor,
            ),
          ),
          IconButton(
            onPressed: () {
              showDeleteConfirmationDialog(context, taskId);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
          Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(
                color: Color(colorValue!), shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }

// Previouly Did the Changing by using this now doing it using DB

  // Widget _buildPriorityIndicator(String priority) {
  //   Color priorityColor;
  //   if (priority == 'high' || priority == 'High') {
  //     priorityColor = Colors.red;
  //   } else if (priority == 'medium' || priority == 'Medium') {
  //     priorityColor = Colors
  //         .orange; // changed from yellow to make it more visually discernible
  //   } else {
  //     priorityColor = Colors.green;
  //   }
  //   return CircleAvatar(
  //     backgroundColor: priorityColor,
  //     radius: 5,
  //   );
  // }
}

// Update Task Completion Status
