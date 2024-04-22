import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todolist/firebase_options.dart';
import 'package:todolist/providers/fonts_provider.dart';
import 'package:todolist/views/authentication/login_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:todolist/views/navigations_screens/navigation_screen.dart';
import 'package:todolist/views/navigations_screens/offline_navigation_screen.dart';

FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize local notifications
  AndroidInitializationSettings androidInitializationSettings =
      const AndroidInitializationSettings('@mipmap/ic_launcher');
  InitializationSettings initializeSettings =
      InitializationSettings(android: androidInitializationSettings);
  await notificationsPlugin.initialize(
    initializeSettings,
  );

  // Check network connectivity
  var connectivityResult = await Connectivity().checkConnectivity();
  bool isWifiOff = (connectivityResult == ConnectivityResult.none);

  // Check if the user has signed out
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isSignedOut = prefs.getBool('is_signed_out') ?? false;

  // Check last login time from SharedPreferences
  DateTime? lastLoginTime = await getLastLoginTime();

  // Determine whether to show SqfliteScreen or NavigationScreen
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => FontSettingsProvider(),
        ),
      ],
      child: Builder(builder: (context) {
        final provider = Provider.of<FontSettingsProvider>(context);
        return MaterialApp(
          theme: ThemeData(
            primaryColor: Color(provider.selectedColor),
            textTheme: TextTheme(
              labelLarge: TextStyle(
                fontSize: provider.heading,
                fontWeight: provider.fontWeight,
              ),
              bodyMedium: TextStyle(
                fontSize: provider.paragraph,
                fontWeight: provider.fontWeightParagraph,
              ),
              // Add more text styles as needed
            ),
          ),
          debugShowCheckedModeBanner: false,
          title: 'AI Todo List',
          home: isWifiOff
              ? OfflineNavigationScreen() //OfflineTasks() // Show SqfliteScreen if no network connectivity
              : isSignedOut
                  ? LoginScreen() // Show LoginScreen if signed out
                  : lastLoginTime != null &&
                          DateTime.now().difference(lastLoginTime) <
                              Duration(hours: 1)
                      ? NavigationScreen() // Show NavigationScreen if within one hour and network is available
                      : LoginScreen(), // Show LoginScreen otherwise
        );
      }),
    ),
  );
}

Future<DateTime?> getLastLoginTime() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? lastLoginTimeString = prefs.getString('last_login_time');
  return lastLoginTimeString != null
      ? DateTime.parse(lastLoginTimeString)
      : null;
}
