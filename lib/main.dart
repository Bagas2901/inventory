import 'package:flutter/material.dart';
// import 'package:inventory/widget/login.dart';
import 'package:inventory/widget/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await init();
  runApp(const InventoryApp());
}

Future init() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Splashscreen(),
      // home: Login(),
    );
  }
}
