import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:design_app/prod_deets.dart'; // import the new screen
import 'package:design_app/uuid_summary.dart';

class BleController extends GetxController {
  RxString currentActiveUuid = ''.obs;
  FlutterBlue ble = FlutterBlue.instance;
  Future<bool> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    return statuses[Permission.location]?.isGranted == true &&
        statuses[Permission.bluetoothScan]?.isGranted == true &&
        statuses[Permission.bluetoothConnect]?.isGranted == true;
  }

  Future<void> scanDevices() async {
    if (await ble.isScanning.first) return; // Prevent multiple scan calls
    if (await requestPermissions()) {
      ble.startScan(timeout: const Duration(seconds: 5));
      await Future.delayed(const Duration(seconds: 5));
      ble.stopScan();
    }
  }

  Future<void> connectDevices(BluetoothDevice device) async {
    try {
      await device.disconnect();
      await device.connect(timeout: const Duration(seconds: 5));

      device.state.listen((BluetoothDeviceState state) {
        if (state == BluetoothDeviceState.connected) {
          print("Device connected to: ${device.name}");
          enableNotifications(device);
        }
      });
    } catch (e) {
      print("Connection error: $e");
    }
  }

  Future<Map<String, dynamic>?> fetchProductDetails(String uuid) async {
    try {
      final response = await http.post(
        Uri.parse(
            "https://hkpmxfz4wyvhz2jtxx4ayk7z3m0tdjaz.lambda-url.us-east-1.on.aws/"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'uuid': uuid}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        Get.snackbar("Error", "Failed to fetch product details.");
        return null;
      }
    } catch (e) {
      Get.snackbar("Network Error", "Please check your internet connection.");
      return null;
    }
  }

  RxString message = ''.obs;
  bool isReading = false;
  RxMap<String, int> receivedUuids =
      <String, int>{}.obs; // Stores UUIDs and their count
  RxMap<String, Map<String, dynamic>> productDetailsMap =
      <String, Map<String, dynamic>>{}.obs;

  Future<void> enableNotifications(BluetoothDevice device) async {
    try {
      // A new RxString to track the currently active complete barcode.
      // (Add this variable at the top of your BleController class along with your other Rx variables)
      // RxString currentActiveUuid = ''.obs; // <-- declare this as a class-level variable

      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() ==
              '0000ffe1-0000-1000-8000-00805f9b34fb') {
            List<int> value = await characteristic.read();
            await characteristic.setNotifyValue(true); // Enable notifications

            characteristic.value.listen((value) async {
              if (value.isNotEmpty) {
                String uuid = String.fromCharCodes(value).trim();
                print("Received UUID: $uuid");

                // Only process complete barcodes of exactly 12 characters.
                if (uuid.length != 12) {
                  print(
                      "Incomplete barcode received. Waiting for full data...");
                  return;
                }

                // Check if this is a new barcode.
                // (If currentActiveUuid is empty or different, clear the stored count.)
                if (currentActiveUuid.value == '' ||
                    currentActiveUuid.value != uuid) {
                  print("New barcode received. Clearing previous data.");
                  currentActiveUuid.value = uuid;
                  receivedUuids.clear();
                  productDetailsMap.clear();
                  // Optionally, if you want to clear any previous pages in the navigation stack,
                  // you can perform a navigation reset here (for example, using Get.offAll).
                }

                // Increment count for the received (complete) barcode.
                receivedUuids.update(uuid, (count) => count + 1,
                    ifAbsent: () => 1);

                // Only call the API (and navigate) when it's the first time this barcode is received.
                if (receivedUuids[uuid] == 1) {
                  final productData = await fetchProductDetails(uuid);
                  if (productData != null) {
                    productDetailsMap[uuid] = productData;
                    // Navigate to ProductDetails page.
                    // You can also add any condition here to avoid multiple navigations if needed.
                    Get.to(() => ProductDetails(
                          uuid: uuid,
                          productName: productData['product_name'] ?? 'No Name',
                          imageLink: productData['image_link'] ?? '',
                          price: productData['price'] ?? '',
                          rating: productData['rating'] ?? '',
                          quantity: receivedUuids[uuid] ?? 1, // Pass quantity
                        ));
                  }
                } else {
                  print(
                      "Barcode already processed. Incremented count to ${receivedUuids[uuid]}");
                }
              }
            });
          }
        }
      }
    } catch (e) {
      print("Error enabling notifications: $e");
    }
  }

  Stream<List<ScanResult>> get scanResults =>
      ble.scanResults.map((results) => results
          .where((result) =>
              result.device.name.isNotEmpty) // Filter devices with names
          .toList());
}
