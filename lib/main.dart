import 'package:flutter/material.dart';
<<<<<<< HEAD
// import 'views/start.dart'; // Import halaman StartPage

// import 'views/test_api_page.dart'; // Import halaman untuk tes API
// import 'views/store_selection_page.dart';
imporimport 'views/welcome_page.dart';
=======
import 'views/welcome_page.dart';
>>>>>>> 58ceadf954fc90f6d8e6b22b302981ff679e8d42

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Handai Payment Test',
      home: const WelcomePage(),
<<<<<<< HEAD
      // ini di enabled kalau mau tes api, tapi yg startpage di comment!
      // home: TestApiPage(),
=======
    );
  }
}
>>>>>>> 58ceadf954fc90f6d8e6b22b302981ff679e8d42
