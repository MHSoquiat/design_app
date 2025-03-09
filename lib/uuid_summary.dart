import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'ble_controller.dart';
import 'package:design_app/home_page.dart';

class UuidSummaryPage extends StatelessWidget {
  final BleController controller = Get.find<BleController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Received Products Summary"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: Obx(() {
        // If no product details stored, show message.
        if (controller.productDetailsMap.isEmpty) {
          return const Center(child: Text("No products received yet."));
        }
        // Build a list using product details.
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
                      : Container(width: 50, height: 50, color: Colors.grey),
              title: Text(details['product_name'] ?? 'No Name'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Price: Php. ${details['price'] ?? 'N/A'}"),
                  Text("Received: $count times"),
                ],
              ),
            );
          }).toList(),
        );
      }),
      bottomNavigationBar: Obx(() {
        // Calculate the total price.
        double totalPrice = 0;
        controller.productDetailsMap.forEach((uuid, details) {
          double price =
              double.tryParse(details['price']?.toString() ?? "0") ?? 0;
          int count = controller.receivedUuids[uuid] ?? 1;
          totalPrice += price * count;
        });
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total Price row.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Total Price:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    "\Php. ${totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Confirm Order button.
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Clear stored data.
                    controller.receivedUuids.clear();
                    controller.productDetailsMap.clear();
                    controller.currentActiveUuid.value = '';
                    // Navigate to Home (clearing the navigation stack).
                    Get.offAll(() => const MyHomePage());
                  },
                  child: const Text("Confirm Order"),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
