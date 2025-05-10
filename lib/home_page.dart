import 'package:design_app/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get/get.dart';
import 'package:design_app/connect_screen.dart';

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
          title: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ENSTACK BLUETOOTH',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Text(
                'SCANNER',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: const Color.fromRGBO(2, 0, 102, 1),
          foregroundColor: Colors.white,
          toolbarHeight: 161,
          centerTitle: true,
        ),
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextButton(
              onPressed: isScanning
                  ? null
                  : () async {
                      setState(() => isScanning = true);
                      await controller.scanDevices();
                      setState(() => isScanning = false);
                    },
              style: TextButton.styleFrom(
                foregroundColor:
                    const Color.fromRGBO(2, 0, 102, 1), // Text color
                backgroundColor: Colors.transparent, // Transparent background
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                            color: Color.fromRGBO(2, 0, 102, 1),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Scanning...',
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(2, 0, 102, 1)),
                        ),
                      ],
                    )
                  : const Text(
                      'Scan for Devices',
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ScanResult>>(
              stream: FlutterBlue.instance.scanResults,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text(
                    'No Devices Found',
                    style: TextStyle(
                        color: Color.fromRGBO(2, 0, 66, 1), fontSize: 18),
                  ));
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
                      color: const Color.fromRGBO(0, 153, 224, 1),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      elevation: 2,
                      child: ListTile(
                        title: Text(
                          data.device.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(data.device.id.id),
                        trailing: TextButton(
                          onPressed: () async {
                            await controller.connectDevices(data.device);
                            Get.to(() => ConnectedScreen(device: data.device));
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 16),
                          ),
                          child: const Text(
                            'Connect',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 25),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton.icon(
              onPressed: () {
                Get.offAllNamed('/'); // OR: Get.off(() => const LoginPage());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ]));
  }
}
