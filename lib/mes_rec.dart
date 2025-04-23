import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DisplayUuidScreen extends StatelessWidget {
  final String uuid;

  const DisplayUuidScreen({Key? key, required this.uuid}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UUID Details'),
        backgroundColor: const Color.fromRGBO(2, 0, 102, 1),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Received UUID: $uuid',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
