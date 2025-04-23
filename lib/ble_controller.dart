import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:design_app/prod_deets.dart';
import 'package:design_app/models/prod_model.dart';
import 'package:design_app/connected_screen.dart';

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

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      print("Connected to ${device.localName}");

      List<BluetoothService> services = await device.discoverServices();
      print("Discovered ${services.length} services");

      for (var service in services) {
        print("Service: ${service.uuid}");
        for (var characteristic in service.characteristics) {
          print("  Characteristic: ${characteristic.uuid}");
        }
      }

      // Optional: still try to navigate for now
      // Get.to(() => ConnectedScreen());
    } catch (e) {
      print("Error during connection: $e");
    }
  }

  Stream<List<ScanResult>> get scanResults =>
      FlutterBluePlus.scanResults.map((results) =>
          results.where((result) => result.device.advName.isNotEmpty).toList());
}
