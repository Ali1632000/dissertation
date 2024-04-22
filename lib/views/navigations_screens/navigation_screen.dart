import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:todolist/constants/colors.dart';
import 'package:todolist/views/home_screen.dart';
import 'package:todolist/views/tasks/new_task_add_screen.dart';
import 'package:todolist/views/notifications_view.dart';
import 'package:todolist/views/previous_month_data.dart';
import 'package:todolist/views/todays_tasks_screen.dart';

class NavigationScreen extends StatefulWidget {
  @override
  _NavigationScreenState createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _currentIndex = 0;

  Future<bool> checkWifi() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    bool isWifiOff = (connectivityResult == ConnectivityResult.none);
    return isWifiOff;
  }

  final _screens = [
    HomeScreen(),
    NewTaskAddedScreen(),
    NotificationsPage(),
    TodayTasksScreen(),
    PreviousMonthDataScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    checkWifi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        unselectedItemColor: Colors.grey,
        selectedItemColor: Colors.white,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        unselectedIconTheme: const IconThemeData(color: Colors.grey, size: 25),
        onTap: _onItemTapped,
        currentIndex: _currentIndex,
        // backgroundColor: Colors.green.shade300, // Set background color here
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 30,
        ),
        selectedLabelStyle: const TextStyle(
          color: appContainerColor,
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
            icon: const Icon(Icons.notification_add),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            label: 'Today Tasks',
            icon: const Icon(Icons.today),
            backgroundColor: Theme.of(context).primaryColor,
          ),
          BottomNavigationBarItem(
            label: 'Account',
            icon: const Icon(Icons.thirty_fps),
            backgroundColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
      body: _screens[_currentIndex],
    );
  }
}
