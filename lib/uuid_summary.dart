import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ble_controller.dart'; // Import controller
import "package:design_app/home_page.dart";

class UuidSummaryPage extends StatelessWidget {
  final BleController controller = Get.find<BleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Shopping Cart (1)"),
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
          return const Center(child: Text("No products received yet."));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: controller.productDetailsMap.entries.map((entry) {
            final uuid = entry.key;
            final details = entry.value;
            final count = controller.receivedUuids[uuid] ?? 1;
            return ListTile(
              leading:
                  details['image_link'] != null && details['image_link'] != ''
                      ? Image.network(
                          details['image_link'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey,
                        ),
              title: Text(details['product_name'] ?? 'No Name'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Price: ${details['price'] ?? 'N/A'}"),
                  Text("Received: $count times")
                ],
              ),
            );
          }).toList(),
        );
      }),
      // Add the "Confirm Order" button at the bottom.
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
            height: 50,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 114, 191, 226)),
                onPressed: () {
                  // Clear all stored UUID counts and any other tracking data.
                  controller.receivedUuids.clear();
                  controller.currentActiveUuid.value = '';
                  // Optionally, clear any additional navigation state if needed.
                  // For example, navigate to the home page and clear the stack:
                  Get.offAll(() => const MyHomePage());
                },
                child: const Text("Confirm Order"))),
      ),
    );
  }
}
