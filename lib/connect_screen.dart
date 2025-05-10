// connected_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:design_app/ble_controller.dart';
import 'package:design_app/prod_deets.dart';

class ConnectedScreen extends StatefulWidget {
  final BluetoothDevice device;

  const ConnectedScreen({super.key, required this.device});

  @override
  State<ConnectedScreen> createState() => _ConnectedScreenState();
}

class _ConnectedScreenState extends State<ConnectedScreen> {
  final BleController controller = Get.find();
  bool hasNavigated = false;

  @override
  void initState() {
    super.initState();
    controller.enableNotifications(widget.device);

    // Listen for changes in the currentActiveUuid
    ever(controller.currentActiveUuid, (uuid) async {
      if (uuid.length == 12 && !hasNavigated) {
        hasNavigated = true;

        final productData = controller.productDetailsMap[uuid];
        if (productData != null) {
          Get.to(() => ProductDetails(
                uuid: uuid,
                productName: productData['product_name'] ?? 'No Name',
                imageLink: productData['image_link'] ?? '',
                price: productData['price'] ?? '',
                rating: productData['rating'] ?? '',
                quantity: controller.receivedUuids[uuid] ?? 1,
                device: widget.device,
              ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          children: [
            const SizedBox(height: 50),
            Image.asset('assets/images/logo.png', height: 40),
            const Text(
              "BAZAAR",
              style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(2, 0, 102, 1),
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 165,
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'START',
              style: TextStyle(
                  color: Color.fromRGBO(0, 56, 168, 1),
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            Text(
              'SCANNING!',
              style: TextStyle(
                  color: Color.fromRGBO(0, 56, 168, 1),
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Color.fromRGBO(2, 153, 224, 1)),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }
}
