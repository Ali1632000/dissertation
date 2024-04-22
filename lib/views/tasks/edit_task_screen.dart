// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todolist/constants/colors.dart';

class EditTaskScreen extends StatefulWidget {
  String? taskID;
  String? title;
  String? description;
  String? priority;
  int? colorValue;
  List<String>? tasksSteps;
  EditTaskScreen(
      {this.taskID,
      this.title,
      this.description,
      this.priority,
      this.colorValue,
      this.tasksSteps});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final TextEditingController titleController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController priorityController = TextEditingController();

  final selectedDate = DateTime.now();

  String formatDate(DateTime dateTime) {
    return DateFormat('dd-MM-yyyy').format(dateTime);
  }

  String selectedPriority = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedPriority = widget.priority!;
  }

  List<DropdownMenuItem<int>> getColorDropdownItems() {
    List<int> colorValues = [
      Colors.blue.value,
      Colors.brown.value,
      Colors.red.value,
      Colors.green.value,
      Colors.yellow.value,
      Colors.purple.value,
      Colors.cyan.value,
    ];

    return colorValues.map((int value) {
      return DropdownMenuItem<int>(
        value: value,
        child: Container(
          width: 80,
          decoration: BoxDecoration(
            color: Color(value),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
          ),
        ),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> getDropdownItems() {
    List<String> priorityOptions;

    // Conditionally set priority options based on initial widget.priority
    if (widget.priority == 'low' ||
        widget.priority == 'medium' ||
        widget.priority == 'high') {
      priorityOptions = ['low', 'medium', 'high'];
    } else if (widget.priority == 'Low' ||
        widget.priority == 'Medium' ||
        widget.priority == 'High') {
      priorityOptions = ['Low', 'Medium', 'High'];
    } else {
      // Default to showing all options if widget.priority is not recognized
      priorityOptions = ['Low', 'Medium', 'High'];
    }

    return priorityOptions.map((String value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
    }).toList();
  }

  int? selectedColor;
  @override
  Widget build(BuildContext context) {
    final FirebaseFirestore fb_instance = FirebaseFirestore.instance;
    final auth = FirebaseAuth.instance.currentUser!.uid;
    final completedTasksQuery = fb_instance
        .collection('users')
        .doc(auth)
        .collection('tasks')
        .doc(formatDate(selectedDate))
        .collection('todos')
        .doc(widget.taskID);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 100),
          child: SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.8,
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Title'),
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: appContainerColor),
                      ),
                      hintText: widget.title ?? 'title',
                      hintStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: appContainerColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text('Description'),
                  TextField(
                    controller: descriptionController,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: appContainerColor),
                      ),
                      hintText: widget.description ?? 'description',
                      hintStyle: const TextStyle(color: Colors.grey),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: appContainerColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Priority',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: selectedPriority.isEmpty ? 'Low' : selectedPriority,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedPriority = newValue!;
                      });
                    },
                    items: getDropdownItems(),
                  ),
                  Text(
                    "Steps:",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  widget.tasksSteps!.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          itemCount: widget.tasksSteps!.length,
                          itemBuilder: (context, index) {
                            return Text(
                                "- " + widget.tasksSteps![index] + "\n");
                          })
                      : Container(
                          height: 10,
                        ),
                  const SizedBox(height: 16.0),
                  const Text('Color'),
                  DropdownButton<int>(
                    value: selectedColor == null
                        ? widget.colorValue
                        : selectedColor,
                    onChanged: (int? newValue) {
                      setState(() {
                        selectedColor = newValue!;
                      });
                    },
                    items: getColorDropdownItems(),
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: appContainerColor),
                    onPressed: () async {
                      String title = titleController.text.isEmpty
                          ? widget.title!
                          : titleController.text;
                      String description = descriptionController.text.isEmpty
                          ? widget.description!
                          : descriptionController.text;
                      String priority =
                          handlePrioritySelection(selectedPriority);
                      var date = formatDate(selectedDate);

                      await completedTasksQuery.update({
                        'title': title,
                        'description': description,
                        'priority': priority,
                        'DateTime': date,
                        'color': selectedColor,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Task Added"),
                        ),
                      );
                    },
                    child: const Text(
                      'Save Task',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String handlePrioritySelection(String selectedPriority) {
    // If the user didn't select a priority, use the initial priority
    String finalPriority = selectedPriority.isEmpty
        ? widget.priority!
        : selectedPriority.toLowerCase();

    return finalPriority;
  }
}
