import 'package:flutter/material.dart';
import 'views/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Handai Coffee',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green[700]!),
      ),
      home: const WelcomePage(),
      // ini di enabled kalau mau tes api, tapi yg startpage di comment!
      // home: TestApiPage(),
    );
  }
}
