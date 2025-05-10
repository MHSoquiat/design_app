import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:design_app/home_page.dart'; // Import the homepage

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Image.asset(
              'assets/images/logo.png', // Ensure this path matches your asset
              height: 40,
            ),
            const Text(
              "BAZAAR",
              style: TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(2, 0, 102, 1),
        foregroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: 210,
      ),
      backgroundColor: Colors.lightBlue.shade50,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hellow!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(0, 153, 224, 1),
                  ),
                ),
                const SizedBox(height: 20),
                const TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 20),
                const TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.off(() => const MyHomePage()); // Navigate to homepage
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(0, 153, 224, 1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero)),
                    child: const Text(
                      'Login',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
