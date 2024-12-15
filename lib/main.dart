import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/reset_passord_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/add_expense_screen.dart';
import 'screens/expense_list_screen.dart';
import 'models/user.dart';
import 'models/expense_model.dart';

// Declare a global instance for the notifications plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with options if on the web

  // Initialize Hive for web or mobile
  if (!kIsWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
  } else {
    await Hive.initFlutter();
  }

  // Register Hive adapters
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ExpenseAdapter());

  // Open the necessary Hive boxes
  await Hive.openBox<User>('userBox');
  await Hive.openBox<Expense>('expenseBox');

  // Initialize the local notifications plugin
  await _initializeNotifications();

  runApp(MyApp());
}

Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher'); // Use your app icon

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Expenses Tracker',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignupScreen(),
        '/reset_password': (context) => ResetPasswordScreen(),
        '/dashboard': (context) => Dashboard(toggleTheme: _toggleTheme),
        '/add_expense': (context) => AddExpenseScreen(),
        '/expense_list': (context) => ExpenseListScreen(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
    );
  }
}
