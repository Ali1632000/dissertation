import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class PreviousMonthDataScreen extends StatefulWidget {
  @override
  _PreviousMonthDataScreenState createState() =>
      _PreviousMonthDataScreenState();
}

class _PreviousMonthDataScreenState extends State<PreviousMonthDataScreen> {
  final FirebaseFirestore fb_instance = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task History'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: getLast30DaysData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          List<Map<String, dynamic>> data = snapshot.data ?? [];

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> dayData = data[index];
              String date = dayData['date'];
              List<Map<String, dynamic>> tasks = dayData['tasks'];

              // Only display dates with tasks
              if (tasks.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Date: $date',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, taskIndex) {
                          Map<String, dynamic> taskData = tasks[taskIndex];
                          return ListTile(
                            title: Text(taskData['title']),

                            subtitle: Text(taskData['description']),
                            // Add more details as needed
                          );
                        },
                      ),
                    ),
                  ],
                );
              } else {
                // If no tasks for the date, return an empty container
                return Container();
              }
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getLast30DaysData() async {
    DateTime currentDate = DateTime.now();
    DateTime startDate = currentDate.subtract(Duration(days: 29));

    List<Map<String, dynamic>> result = [];

    for (int i = 0; i < 30; i++) {
      DateTime currentDate = startDate.add(Duration(days: i));
      String formattedDate = DateFormat('dd-MM-yyyy').format(currentDate);

      QuerySnapshot snapshot = await fb_instance
          .collection('users')
          .doc(auth)
          .collection('tasks')
          .doc(formattedDate)
          .collection('todos')
          .get();

      List<Map<String, dynamic>> tasks = snapshot.docs
          .map((doc) => {
                'title': doc['title'],
                'description': doc['description'],
                // Add more fields as needed
              })
          .toList();

      result.add({'date': formattedDate, 'tasks': tasks});
    }

    return result;
  }
}
