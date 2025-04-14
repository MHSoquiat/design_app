import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';

class ConfirmResetPasswordScreen extends StatefulWidget {
  final String username;

  const ConfirmResetPasswordScreen({super.key, required this.username});

  @override
  State<ConfirmResetPasswordScreen> createState() =>
      _ConfirmResetPasswordScreenState();
}

class _ConfirmResetPasswordScreenState
    extends State<ConfirmResetPasswordScreen> {
  final TextEditingController confirmationCodeController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';
  String successMessage = ''; // Add a success message variable

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      successMessage = ''; // Reset success message
    });

    try {
      // Confirm the reset password
      await Amplify.Auth.confirmResetPassword(
        username: widget.username,
        newPassword: newPasswordController.text.trim(),
        confirmationCode: confirmationCodeController.text.trim(),
      );

      // On success, show a success message and navigate back to sign-in
      setState(() {
        successMessage = 'Password reset successfully!';
      });

      // Navigate back to sign-in after a delay to show the success message
      await Future.delayed(const Duration(seconds: 2));

      // Instead of pushReplacementNamed, use pop to return to the previous screen
      Navigator.pop(
          context); // This will return to the sign-in page or previous screen
    } on AuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "Reset Password",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(0, 153, 224, 1),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Confirmation Code
              TextFormField(
                controller: confirmationCodeController,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Enter confirmation code",
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(0, 153, 224, 1)),
                    borderRadius: BorderRadius.zero,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(0, 153, 224, 1)),
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.zero,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),

              const SizedBox(height: 16),

              // New Password
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Enter new password",
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(0, 153, 224, 1)),
                    borderRadius: BorderRadius.zero,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(0, 153, 224, 1)),
                    borderRadius: BorderRadius.zero,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2.0),
                    borderRadius: BorderRadius.zero,
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                ),
              ),

              const SizedBox(height: 20),

              // Error Message
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),

              // Success Message
              if (successMessage.isNotEmpty)
                Text(
                  successMessage,
                  style: const TextStyle(color: Colors.green),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Submit",
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
