import 'package:flutter/material.dart';
import 'package:gym_app_flutter/src/providers/user_provider.dart';
import 'package:gym_app_flutter/src/screens/dashboard.dart';
import 'package:gym_app_flutter/src/screens/mobile_scanner.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => MobileScannerScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
