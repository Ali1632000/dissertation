import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/constants/colors.dart';
import 'package:todolist/views/authentication/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: height * 0.2,
              ),
              Container(
                height: height * 0.5,
                width: width,
                padding: EdgeInsets.only(
                    top: height * 0.02,
                    bottom: height * 0.02,
                    left: width * 0.05,
                    right: width * 0.05),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Introducing \"AI To-DoList,\" a cutting-edge Flutter application designed to streamline your task management experience. This innovative app harnesses the power of artificial intelligence to enhance your productivity. With a simple and intuitive user interface, it allows you to create and manage your to-do list seamlessly. But what sets it apart is its AI-powered priority prediction feature.\n\nUsing the AI To-DoList app is as straightforward as typing in your task title. Once you enter the task title in the text widget and hit \"Add,\" the application works behind the scenes to analyze your task and determine its priority. It takes into account various factors such as deadlines, importance, and complexity, to provide you with an accurate assessment of the task's priority level.",
                  style: TextStyle(
                      fontSize: 16.0, color: Theme.of(context).primaryColor),
                ),
              ),
              SizedBox(
                height: height * 0.03,
              ),
              ElevatedButton(
                onPressed: () async {
                  // Set the sign-out status in SharedPreferences to true
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setBool('is_signed_out', true);

                  await auth.signOut();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: whiteColor),
                child: Text(
                  'SignOut',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}
