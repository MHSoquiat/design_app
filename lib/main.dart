import 'package:design_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX package
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location
  ].request();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  requestPermissions();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // Use GetMaterialApp instead of MaterialApp
      title: 'Design App',
      debugShowCheckedModeBanner: false, // Optional: Removes debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}
