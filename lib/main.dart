import 'package:aims/screens/loginscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    Get.testMode = true;
    runApp(WebApp());
  } else {
    runApp(MyApp());
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AIMS Inventory',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(), // Start with the Login Screen
    );
  }
}

class WebApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 600,
        height: 800,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AIMS Inventory',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: LoginScreen(),
        ),
      ),
    );
  }
}
