import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/constants/colors.dart';

class TodayTasksScreen extends StatelessWidget {
  TodayTasksScreen({super.key});

  final FirebaseFirestore fb_instance = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance.currentUser!.uid;
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
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today Screen'),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: StreamBuilder<QuerySnapshot>(
          stream: getTodayTasks().asStream(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(child: Text('No tasks for today.'));
            }

            List<Map<String, dynamic>> completedTasks = [];
            List<Map<String, dynamic>> notCompletedTasks = [];

            snapshot.data!.docs.forEach((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              if (data['isCompleted'] == true) {
                completedTasks.add(data);
              } else {
                notCompletedTasks.add(data);
              }
            });

            int totalTasks = completedTasks.length + notCompletedTasks.length;
            double completionPercentage =
                (completedTasks.length / totalTasks) * 100;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total tasks for today: $totalTasks',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                  Text(
                    'Completed tasks: ${completedTasks.length}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: appContainerColor),
                  ),
                  Text(
                    'Not completed tasks: ${notCompletedTasks.length}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  Text(
                    'Completion Percentage: ${completionPercentage.toStringAsFixed(2)}%',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Completed Tasks List:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ListView(
                    shrinkWrap: true,
                    children: completedTasks.map((task) {
                      return Container(
                        height: height * 0.08,
                        width: width * 0.85,
                        decoration: BoxDecoration(
                          color: appContainerColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          title: Text(
                            task['title'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.normal),
                          ),
                          subtitle: Text(task['description']),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Not Completed Tasks List:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ListView(
                    shrinkWrap: true,
                    children: notCompletedTasks.map((task) {
                      return Container(
                        height: height * 0.08,
                        width: width * 0.85,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListTile(
                          title: Text(
                            task['title'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.normal),
                          ),
                          subtitle: Text(task['description']),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
