import 'package:design_app/ble_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:design_app/connect_screen.dart';
import 'package:rxdart/rxdart.dart';
import 'package:get/get.dart';

class ProductDetails extends StatefulWidget {
  final String uuid;
  final String productName;
  final String imageLink;
  final String price;
  final String rating;
  final int quantity;
  final BluetoothDevice device; // Add BluetoothDevice as a parameter

  const ProductDetails({
    Key? key,
    required this.uuid,
    required this.productName,
    required this.imageLink,
    required this.price,
    required this.rating,
    required this.quantity,
    required this.device, // Make sure to pass the BluetoothDevice when initializing ProductDetails
  }) : super(key: key);

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  int quantity = 1;

  void increaseQty() {
    setState(() {
      quantity++;
    });
  }

  void decreaseQty() {
    if (quantity > 1) {
      setState(() {
        quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double unitPrice = double.tryParse(widget.price) ?? 0;
    double totalPrice = unitPrice * quantity;

    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Product Image
          Image.network(
            widget.imageLink,
            height: 350,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),

          // Product Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.productName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // Price and Quantity Selector Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                child: Text(
                  "₱${widget.price}",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              _qtyButton("-", decreaseQty),
              // Changed container: removed border and just show quantity text with some margin.
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Text(
                  '$quantity',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              _qtyButton("+", increaseQty),
            ],
          ),
          const Spacer(),

          // Checkout Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Ordered $quantity x ${widget.productName}')),
                );

                final bleController = Get.find<BleController>();
                bleController.resetBarcodeMemory();

                Future.delayed(const Duration(milliseconds: 500), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConnectedScreen(
                        device: widget.device, // Pass the BluetoothDevice here
                      ),
                    ),
                  );
                });
              },
              child: Text(
                "Checkout ₱${totalPrice.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(String symbol, VoidCallback onPressed) {
    // Check for plus button customization.
    final bool isPlus = symbol == "+";
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isPlus ? Colors.blue.shade900 : Colors.blue.shade900,
        foregroundColor: isPlus ? Colors.white : Colors.white,
        minimumSize: const Size(40, 40),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        symbol,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
