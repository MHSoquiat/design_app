import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MesRec extends StatelessWidget {
  final String message;

  const MesRec({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Message Received: $message'),
          ],
        ),
      ),
    );
  }
}
