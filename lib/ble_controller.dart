import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:design_app/prod_deets.dart';
import 'package:design_app/uuid_summary.dart';

class BleController extends GetxController {
  RxString currentActiveUuid = ''.obs;
  FlutterBluePlus ble = FlutterBluePlus();

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
    if (FlutterBluePlus.isScanningNow) return; // Ensures no duplicate scans

    if (await requestPermissions()) {
      // Check Bluetooth state before scanning
      BluetoothAdapterState adapterState =
          await FlutterBluePlus.adapterState.first;

      if (adapterState != BluetoothAdapterState.on) {
        Get.defaultDialog(
          title: "Bluetooth Disabled",
          middleText: "Please turn on Bluetooth to scan for devices.",
          textConfirm: "OK",
          confirmTextColor: Colors.white,
          onConfirm: () => Get.back(), // Close dialog
        );
        return; // Stop execution if Bluetooth is off
      }

      // Start scanning if Bluetooth is on
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

      await Future.delayed(const Duration(seconds: 5));

      FlutterBluePlus.stopScan();
    }
  }

  Future<void> connectDevices(BluetoothDevice device) async {
    try {
      BluetoothConnectionState state = await device.connectionState.first;
      if (state == BluetoothConnectionState.connected) {
        await device.disconnect();
      }

      await device.connect(); // Connect after ensuring disconnection

      device.connectionState.listen((BluetoothConnectionState newState) {
        if (newState == BluetoothConnectionState.connected) {
          print("Device connected to: ${device.advName}");
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
  RxMap<String, int> receivedUuids = <String, int>{}.obs;

  Future<void> enableNotifications(BluetoothDevice device) async {
    try {
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() ==
              '0000ffe1-0000-1000-8000-00805f9b34fb') {
            await characteristic.setNotifyValue(true);

            characteristic.onValueReceived.listen((value) async {
              if (value.isNotEmpty) {
                String uuid = String.fromCharCodes(value).trim();
                print("Received UUID: $uuid");

                if (uuid.length != 12) {
                  print(
                      "Incomplete barcode received. Waiting for full data...");
                  return;
                }

                if (currentActiveUuid.value == '' ||
                    currentActiveUuid.value != uuid) {
                  print("New barcode received. Clearing previous data.");
                  currentActiveUuid.value = uuid;
                  receivedUuids.clear();
                }

                receivedUuids.update(uuid, (count) => count + 1,
                    ifAbsent: () => 1);

                if (receivedUuids[uuid] == 1) {
                  final productData = await fetchProductDetails(uuid);
                  if (productData != null) {
                    Get.to(() => ProductDetails(
                          uuid: uuid,
                          productName: productData['product_name'] ?? 'No Name',
                          imageLink: productData['image_link'] ?? '',
                          price: productData['price'] ?? '',
                          rating: productData['rating'] ?? '',
                          quantity: receivedUuids[uuid] ?? 1,
                        ));
                  }
                } else {
                  print(
                      "Barcode already processed. Count: ${receivedUuids[uuid]}");
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
      FlutterBluePlus.scanResults.map((results) =>
          results.where((result) => result.device.advName.isNotEmpty).toList());
}
