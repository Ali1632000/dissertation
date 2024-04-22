import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todolist/views/account_screens/addtional_settings_screen.dart';

class AccountScreen extends StatefulWidget {
  AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final FirebaseFirestore fb_instance = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance.currentUser!.uid;

  Future<Map<String, dynamic>> getPersonalInfo() async {
    CollectionReference personalInfoCollection =
        fb_instance.collection('users').doc(auth).collection('personalInfo');

    QuerySnapshot personalInfoSnapshot =
        await personalInfoCollection.limit(1).get();

    if (personalInfoSnapshot.docs.isNotEmpty) {
      DocumentSnapshot firstDocument = personalInfoSnapshot.docs.first;
      return firstDocument.data() as Map<String, dynamic>;
    } else {
      return {}; // Return an empty map if no data is available
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            height: height * 0.4,
            width: width * 0.9,
            margin: EdgeInsets.symmetric(
                vertical: height * 0.1, horizontal: width * 0.05),
            decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20)),
            padding: EdgeInsets.symmetric(
                vertical: height * 0.1, horizontal: width * 0.03),
            child: FutureBuilder<Map<String, dynamic>>(
              future: getPersonalInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.data == null) {
                  return Center(
                      child: Text('No personal information available.'));
                }

                String name = snapshot.data!['name'] ?? 'N/A';
                String email = snapshot.data!['email'] ?? 'N/A';
                String password = snapshot.data!['password'] ?? 'N/A';

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Text(
                        'Name: $name',
                        style: TextStyle(fontSize: 25),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Email: $email',
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Password: $password',
                        style: const TextStyle(fontSize: 15),
                      ),
                      //
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => AdditionalSettingsScreen(),
                  ),
                );
              },
              child: const Text("Additional Settings"))
        ],
      ),
    );
  }
}
