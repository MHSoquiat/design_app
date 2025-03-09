import 'package:design_app/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final BleController controller =
      Get.put(BleController()); // Persistent controller
  bool isScanning = false; // Track scanning state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLUETOOTH SCANNER'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ScanResult>>(
              stream: FlutterBlue.instance.scanResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No Devices Found'));
                }

                // Filter devices with empty names and remove duplicates by name
                Set<String> uniqueDeviceNames = {}; // Store unique names
                final filteredDevices = snapshot.data!
                    .where((result) =>
                        result.device.name.isNotEmpty && // Remove empty names
                        uniqueDeviceNames.add(
                            result.device.name)) // Keep only first occurrence
                    .toList();

                if (filteredDevices.isEmpty) {
                  return const Center(child: Text('No Devices Found'));
                }

                return ListView.builder(
                  itemCount: filteredDevices.length,
                  itemBuilder: (context, index) {
                    final data = filteredDevices[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      elevation: 2,
                      child: ListTile(
                        title: Text(data.device.name),
                        subtitle: Text(
                            data.device.id.id), // Still showing MAC address
                        onTap: () => controller.connectDevices(data.device),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: isScanning
                  ? null
                  : () async {
                      setState(() => isScanning = true);
                      await controller.scanDevices();
                      setState(() => isScanning = false);
                    },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: isScanning
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Scanning...'),
                      ],
                    )
                  : const Text('Scan for Devices'),
            ),
          ),
        ],
      ),
    );
  }
}
