import 'package:flutter/material.dart';
import 'package:design_app/prod_deets.dart';
import 'package:get/get.dart';
import 'package:design_app/ble_controller.dart'; // if your fetch is in a service file

class ConnectedScreen extends StatefulWidget {
  final String? uuid;
  const ConnectedScreen({super.key, this.uuid});

  @override
  State<ConnectedScreen> createState() => _ConnectedScreenState();
}

class _ConnectedScreenState extends State<ConnectedScreen> {
  final controller = Get.find<BleController>();
  bool hasNavigated = false;

  // @override
  // void initState() {
  //   super.initState();

  //   // Watch UUID updates and act once it's updated
  //   ever(controller.currentActiveUuid, (uuid) async {
  //     print("UUID updated: $uuid");
  //     if (uuid != null && uuid.isNotEmpty && !hasNavigated) {
  //       hasNavigated = true;

  //       final product = await BleController.fetchProductDetails(uuid);
  //       Get.off(() => ProductDetails(
  //             uuid: product.uuid,
  //             productName: product.name,
  //             imageLink: product.imageUrl,
  //             price: product.price,
  //             rating: product.rating,
  //             quantity: product.quantity,
  //           ));
  //     }
  //   });
  // }

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
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("START",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(2, 0, 102, 1))),
            Text("SCANNING",
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(2, 0, 102, 1))),
          ],
        ),
      ),
    );
  }
}
