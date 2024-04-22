import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/constants/colors.dart';
import 'package:todolist/views/authentication/signup_screen.dart';
import 'package:todolist/views/navigations_screens/navigation_screen.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

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
            const Icon(
              Icons.login,
              color: whiteColor,
              size: 50,
            ),
            SizedBox(
              height: height * 0.1,
            ),
            Container(
              padding: EdgeInsets.only(left: width * 0.07, right: width * 0.07),
              height: height * 0.7,
              width: width,
              decoration: const BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(fontSize: 15),
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
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelStyle: TextStyle(fontSize: 15),
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                              30.0), // Adjust the radius as needed
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your password';
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
                      ),
                      onPressed: () {
                        if (_emailController.text.isEmpty ||
                            _passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Please enter the info to login"),
                            ),
                          );
                        }
                        if (_formKey.currentState!.validate()) {
                          _signInWithEmailAndPassword();
                          saveLoginTime();
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignUpScreen()),
                        );
                      },
                      child: const Text(
                        'Don\'t have an account? Sign up',
                        style:
                            TextStyle(color: appContainerColor, fontSize: 20),
                      ),
                    ),
                    _googleSignInButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _googleSignInButton() {
    return SizedBox(
      height: 50,
      child: SignInButton(
        Buttons.google,
        text: "Sign up with Google",
        onPressed: _handleGoogleSignIn,
      ),
    );
  }

  void _handleGoogleSignIn() async {
    try {
      // Show a loading indicator
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent accidental dismissal
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await _auth.signInWithProvider(googleProvider);

      // Check if the sign-in was successful
      User? user = _auth.currentUser;
      if (user != null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => NavigationScreen(),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign-in failed. Please try again.')));
      }
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('An error occurred: $error')));
    } finally {
      Navigator.pop(context);
    }
  }

  Future<void> _signInWithEmailAndPassword() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Save the user ID in SharedPreferences

      saveUserId(_auth.currentUser?.uid);

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => NavigationScreen(),
      ));
      // Navigate to the home screen after successful login
    } catch (e) {
      print('Error during login: $e');
      // Handle login errors
    }
  }

  Future<void> saveUserId(String? userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user_id', userId ?? '');
  }

  Future<void> saveLoginTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('last_login_time', DateTime.now().toString());
  }
}
