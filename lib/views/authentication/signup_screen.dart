import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todolist/constants/colors.dart';
import 'package:todolist/views/navigations_screens/navigation_screen.dart';

// ignore: must_be_immutable
class SignUpScreen extends StatelessWidget {
  TextEditingController nameControl = TextEditingController();
  TextEditingController emailControl = TextEditingController();
  TextEditingController passControl = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: appContainerColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: height * 0.15,
            ),
            Icon(
              Icons.login,
              color: whiteColor,
              size: height * 0.1,
            ),
            SizedBox(
              height: height * 0.1,
            ),
            Container(
              padding: EdgeInsets.only(left: width * 0.07, right: width * 0.07),
              height: height * 0.65,
              width: width,
              decoration: const BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  TextFormField(
                    controller: emailControl,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            30.0), // Adjust the radius as needed
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  TextFormField(
                    controller: nameControl,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            30.0), // Adjust the radius as needed
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  TextFormField(
                    controller: passControl,
                    decoration: InputDecoration(
                      labelText: 'password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            30.0), // Adjust the radius as needed
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appContainerColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            30.0), // Adjust the radius as needed
                      ),
                      minimumSize: Size(200, 50),
                    ),
                    onPressed: () {
                      if (emailControl.text.isEmpty ||
                          nameControl.text.isEmpty ||
                          passControl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please enter the info to login"),
                          ),
                        );
                      }
                      _signUpWithEmailAndPassword(context);
                    },
                    child: const Text(
                      'Create an Account',
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: appContainerColor, fontSize: 20),
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

  Future<void> _signUpWithEmailAndPassword(BuildContext context) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: emailControl.text,
        password: passControl.text,
      );
      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('personalInfo')
          .add({
        'name': nameControl.text,
        'email': emailControl.text,
        'password': passControl.text
      });

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => NavigationScreen(),
      ));
      // Navigate to the home screen after successful login
    } catch (e) {
      print('Error during login: $e');
      // Handle login errors
    }
  }
}
