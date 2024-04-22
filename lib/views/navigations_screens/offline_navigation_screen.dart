import 'package:flutter/material.dart';
import 'package:todolist/constants/colors.dart';
import 'package:todolist/views/offline_tasks_list.dart';
import 'package:todolist/views/tasks/new_task_add_screen.dart';
import 'package:todolist/views/notifications_view.dart';

// import 'package:upgrader/upgrader.dart';

class OfflineNavigationScreen extends StatefulWidget {
  @override
  _OfflineNavigationScreenState createState() =>
      _OfflineNavigationScreenState();
}

class _OfflineNavigationScreenState extends State<OfflineNavigationScreen> {
  int _currentIndex = 0;

  final _offScreens = [
    OfflineTasks(),
    NewTaskAddedScreen(),
    NotificationsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    _currentIndex;
  }

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        selectedItemColor: whiteColor,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        unselectedIconTheme: const IconThemeData(color: Colors.grey, size: 25),
        onTap: _onItemTapped,
        currentIndex: _currentIndex,
        selectedIconTheme: const IconThemeData(
          color: whiteColor,
          size: 30,
        ),
        selectedLabelStyle: const TextStyle(
          color: appContainerColor, // Set the selected label color here
        ),
        items: [
          BottomNavigationBarItem(
            backgroundColor: Theme.of(context).primaryColor,
            label: 'Home',
            icon: const Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            label: 'Add Task',
            icon: const Icon(Icons.calendar_month),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            label: 'Notifications',
            icon: const Icon(Icons.settings),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
      body: _offScreens[_currentIndex],
    );
  }
}
