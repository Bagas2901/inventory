import 'package:flutter/material.dart';
import 'package:inventory/widget/login.dart';
import 'package:inventory/widget/splashscreen.dart';

void main() {
  runApp(InventoryApp());
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
