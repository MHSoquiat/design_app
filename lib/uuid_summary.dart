import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ble_controller.dart'; // Import controller

class UuidSummaryPage extends StatelessWidget {
  final BleController controller = Get.find<BleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Received UUIDs Summary"),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Get.back();
                }
              })),
      body: Obx(() {
        if (controller.receivedUuids.isEmpty) {
          return Center(child: Text("No UUIDs received yet."));
        }

        return ListView(
          padding: EdgeInsets.all(16),
          children: controller.receivedUuids.entries.map((entry) {
            return ListTile(
              title: Text("UUID: ${entry.key}"),
              subtitle: Text("Received: ${entry.value} times"),
            );
          }).toList(),
        );
      }),
    );
  }
}
