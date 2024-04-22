import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/constants/colors.dart';
import 'package:todolist/local_database/db_helper.dart';
import 'package:http/http.dart' as http;
import 'package:todolist/views/calender_page_view.dart';

class NewTaskAddedScreen extends StatefulWidget {
  const NewTaskAddedScreen({Key? key});

  @override
  State<NewTaskAddedScreen> createState() => _NewTaskAddedScreenState();
}

// Random generator for unique IDs (datetime shared preferences)
String generateUniqueId() {
  var now = DateTime.now();
  return "${now.millisecondsSinceEpoch}_${Random().nextInt(999999)}";
}

// Saving task details to shared preferences (no overwriting)
Future<void> saveTaskDetails(
    String taskId, String taskTitle, DateTime selectedDateTime) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String? tasksJson = prefs.getString('tasks');

  List<dynamic> tasks = tasksJson != null ? jsonDecode(tasksJson) : [];

  tasks.add({
    'id': taskId,
    'title': taskTitle,
    'dateTime': selectedDateTime.toIso8601String(),
  });

  prefs.setString('tasks', jsonEncode(tasks));
}

class _NewTaskAddedScreenState extends State<NewTaskAddedScreen> {
  bool isWifiOn = false;
  FirebaseFirestore fb_instance = FirebaseFirestore.instance;
  late String auth = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    checkWifi();

    // Initialize auth only if WiFi is on
    if (isWifiOn) {
      auth = FirebaseAuth.instance.currentUser!.uid;
    }
  }

  Future<void> checkWifi() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isWifiOn = connectivityResult == ConnectivityResult.wifi;
    });
  }

  TextEditingController titleCtrl = TextEditingController();
  TextEditingController descriptionCtrl = TextEditingController();
  DateTime selectedDate = DateTime.now();
  int selectedHour = 1;
  int selectedMinute = 1;

  List<int> hours = List.generate(24, (index) => index);
  List<int> minutes = List.generate(60, (index) => index);
  int count = 0;

  // Initialize Firebase Cloud Messaging

  final TaskDatabaseHelper _dbHelper = TaskDatabaseHelper();
  String formatDate(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final heigth = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    Future<void> _selectDate(BuildContext context) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2000),
        lastDate: DateTime(2101),
      );
      if (pickedDate != null && pickedDate != selectedDate)
        setState(() {
          selectedDate = pickedDate;
        });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.only(top: heigth * 0.08)),
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.1,
                right: width * 0.1,
              ),
              child: Container(
                height: heigth * 0.4,
                // color: whiteColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Add New Task",
                          style: TextStyle(
                              color: whiteColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.add_task,
                            color: whiteColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: heigth * 0.05,
                    ),
                    const Text(
                      "Title",
                      style: TextStyle(color: whiteColor, fontSize: 20),
                    ),
                    SizedBox(
                      height: heigth * 0.02,
                    ),
                    TextField(
                      controller: titleCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        hintText: 'Title here',
                        hintStyle: TextStyle(color: whiteColor),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: heigth * 0.05,
                    ),
                    const Text(
                      "Description",
                      style: TextStyle(color: whiteColor, fontSize: 20),
                    ),
                    SizedBox(
                      height: heigth * 0.02,
                    ),
                    TextField(
                      controller: descriptionCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        hintText: 'Description here',
                        hintStyle: TextStyle(color: whiteColor),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: heigth * 0.1,
            ),
            Container(
              width: width,
              height: heigth * 0.45,
              decoration: const BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              padding: EdgeInsets.only(
                  left: width * 0.11, right: width * 0.11, top: heigth * 0.04),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        count == 0 ? "Pick a Date" : formatDate(selectedDate),
                        style: TextStyle(
                            fontSize: 25,
                            color: Theme.of(context).primaryColor),
                      ),
                      IconButton(
                        onPressed: () {
                          count++;
                          debugPrint(count.toString());
                          _selectDate(context);

                          debugPrint("Pressed");
                        },
                        icon: Icon(
                          Icons.calendar_month_outlined,
                          color: Theme.of(context).primaryColor,
                          size: 30,
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: heigth * 0.02,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<int>(
                        value: selectedHour,
                        onChanged: (newValue) {
                          setState(() {
                            selectedHour = newValue!;
                          });
                        },
                        items: hours.map((int hour) {
                          return hour <= 12
                              ? DropdownMenuItem<int>(
                                  value: hour,
                                  child: Text('$hour am'),
                                )
                              : DropdownMenuItem<int>(
                                  value: hour,
                                  child: Text('$hour pm'),
                                );
                        }).toList(),
                      ),
                      DropdownButton<int>(
                        value: selectedMinute,
                        onChanged: (newValue) {
                          setState(() {
                            selectedMinute = newValue!;
                          });
                        },
                        items: minutes.map((int minute) {
                          return DropdownMenuItem<int>(
                            value: minute,
                            child: Text('$minute'),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: heigth * 0.05,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (isWifiOn) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CalenderViewPage()),
                        );
                      } else {
                        // Handle case where Wi-Fi is off
                        // You can show a message or take appropriate action
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Wi-Fi is off. Please connect to Wi-Fi."),
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Add a Task in Calendar',
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.2,
                        vertical: heigth * 0.03,
                      ),
                    ),
                    onPressed: () async {
                      print(titleCtrl.text);

                      // Check if the network is available
                      bool isWifiOff = isWifiOn;

                      if (!isWifiOff) {
                        // Save only in the local database

                        String formattedDate = formatDate(selectedDate);

                        final DateTime selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedHour,
                          selectedMinute,
                        );

                        String taskId = generateUniqueId();

                        await saveTaskDetails(
                          taskId,
                          titleCtrl.text,
                          selectedDateTime,
                        );

                        await _dbHelper.insertTask({
                          'title': titleCtrl.text,
                          'description': descriptionCtrl.text,
                          'priority': 'Low',
                          'dateTime': formattedDate,
                          'color': Colors.green.value
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Task Added"),
                          ),
                        );
                      } else {
                        // Save in both Firebase and local database

                        showResponseDialog(
                            context: context, title: titleCtrl.text);
                      }
                    },
                    child: const Text(
                      "AddTask",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: whiteColor, fontSize: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showResponseDialog({BuildContext? context, String? title}) {
    final String apiUrl = "https://shark-app-iq6nu.ondigitalocean.app/predict";
    final Map<String, String> requestBody = {
      "text": title!,
    };
    print("Task is in the dialog box");
    showDialog(
      context: context!,
      builder: (BuildContext context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: fetchData(apiUrl, requestBody),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else {
              Map<String, dynamic> data = snapshot.data!;
              return Center(
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.2,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey.shade600),
                    child: GestureDetector(
                      onTap: () async {
                        String formattedDate = formatDate(selectedDate);

                        final DateTime selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedHour,
                          selectedMinute,
                        );

                        CollectionReference tasks = fb_instance
                            .collection('users')
                            .doc(auth)
                            .collection('tasks')
                            .doc(formattedDate)
                            .collection('todos');

                        await tasks.add({
                          'title': titleCtrl.text,
                          'description': descriptionCtrl.text,
                          'priority':
                              data['priority'] == 'Error: Server error 500'
                                  ? 'Low'
                                  : data['priority'],
                          //: priority,
                          'DateTime': formattedDate,
                          'isCompleted': false,
                          'color': data['priority'] == "High" ||
                                  data['priority'] == "high"
                              ? Colors.red.value
                              : data['priority'] == "Medium" ||
                                      data['priority'] == "medium"
                                  ? Colors.orange.value
                                  : Colors.green.value,
                        });

                        String taskId = generateUniqueId();

                        await saveTaskDetails(
                          taskId,
                          titleCtrl.text,
                          selectedDateTime,
                        );

                        await _dbHelper.insertTask({
                          'title': titleCtrl.text,
                          'description': descriptionCtrl.text,
                          'priority':
                              data['priority'] == 'Error: Server error 500'
                                  ? 'Low'
                                  : data['priority'],
                          'dateTime': formattedDate.toString(),
                          'color': data['priority'] == "High" ||
                                  data['priority'] == "high"
                              ? Colors.red.value
                              : data['priority'] == "Medium" ||
                                      data['priority'] == "medium"
                                  ? Colors.orange.value
                                  : Colors.green.value,
                        });
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Task Added "),
                          ),
                        );
                      },
                      child: Text(
                        data['priority'],
                        style: const TextStyle(
                          color: whiteColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.2,
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[200],
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        String formattedDate = formatDate(selectedDate);

                        final DateTime selectedDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedHour,
                          selectedMinute,
                        );

                        CollectionReference tasks = fb_instance
                            .collection('users')
                            .doc(auth)
                            .collection('tasks')
                            .doc(formattedDate)
                            .collection('todos');

                        await tasks.add({
                          'title': titleCtrl.text,
                          'description': descriptionCtrl.text,
                          'priority':
                              data['priority'] == 'Error: Server error 500'
                                  ? 'Low'
                                  : data['priority'],
                          //: priority,
                          'DateTime': formattedDate,
                          'isCompleted': false,
                          'steps': data['steps'],
                          'color': data['priority'] == "High" ||
                                  data['priority'] == "high"
                              ? Colors.red.value
                              : data['priority'] == "Medium" ||
                                      data['priority'] == "medium"
                                  ? Colors.orange.value
                                  : Colors.green.value,
                        });

                        String taskId = generateUniqueId();

                        await saveTaskDetails(
                          taskId,
                          titleCtrl.text,
                          selectedDateTime,
                        );

                        await _dbHelper.insertTask({
                          'title': titleCtrl.text,
                          'description': descriptionCtrl.text,
                          'priority':
                              data['priority'] == 'Error: Server error 500'
                                  ? 'Low'
                                  : data['priority'],
                          'dateTime': formattedDate.toString(),
                          'color': data['priority'] == "High" ||
                                  data['priority'] == "high"
                              ? Colors.red.value
                              : data['priority'] == "Medium" ||
                                      data['priority'] == "medium"
                                  ? Colors.orange.value
                                  : Colors.green.value,
                        });

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Task Added "),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Priority: ${data['priority']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Steps:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ListView.builder(
                              shrinkWrap: true,
                              itemCount: data['steps'].length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 16.0),
                                  child: Text('- ${data['steps'][index]}'),
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ]),
              );
            }
          },
        );
      },
    );
  }
}

Future<Map<String, dynamic>> fetchData(
    String apiUrl, Map<String, String> requestBody) async {
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: jsonEncode(requestBody),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Error: ${response.statusCode}");
      throw Exception("Failed to load data");
    }
  } catch (e) {
    print("Error: $e");
    throw Exception("Failed to load data");
  }
}

/// Unused data
///
///  // Future<List<NotificationsModel>> getNotifications() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String? notificationsJson = prefs.getString('notifications');

//   if (notificationsJson != null) {
//     // Convert the JSON string back to a list of NotificationsModel
//     List<dynamic> decodedJson = jsonDecode(notificationsJson);
//     List<NotificationsModel> notifications =
//         decodedJson.map((json) => NotificationsModel.fromJson(json)).toList();

//     return notifications;
//   } else {
//     return [];
//   }
// }
