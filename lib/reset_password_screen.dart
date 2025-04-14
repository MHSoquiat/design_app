import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:design_app/confirm_reset_password.dart';

class ResetPasswordScreen extends StatefulWidget {
  final AuthenticatorState state;

  const ResetPasswordScreen({super.key, required this.state});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';
  String successMessage = '';

  Future<void> _resetPassword() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Request the password reset via AWS Cognito
      await Amplify.Auth.resetPassword(username: emailController.text.trim());

      // Once the code is sent, navigate to the ConfirmResetPasswordScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ConfirmResetPasswordScreen(username: emailController.text.trim()),
        ),
      );
    } on AuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle any errors if the password reset failed
      safePrint("❌ Error: ${e.message}");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            "Forgot Password",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(0, 153, 224, 1),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Email Input
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Enter your email",
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromRGBO(0, 153, 224, 1)),
              borderRadius: BorderRadius.zero,
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue, width: 2),
              borderRadius: BorderRadius.zero,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Color.fromRGBO(0, 153, 224, 1), width: 1.5),
              borderRadius: BorderRadius.zero,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Show error or success message
        if (errorMessage.isNotEmpty)
          Text(errorMessage, style: const TextStyle(color: Colors.red)),
        if (successMessage.isNotEmpty)
          Text(successMessage, style: const TextStyle(color: Colors.green)),

        const SizedBox(height: 20),

        // Submit Button
        ElevatedButton(
          onPressed: isLoading ? null : _resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(0, 153, 224, 1),
            foregroundColor: Colors.white,
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Send Code"),
        ),

        const SizedBox(height: 20),

        // Back to Sign In
        TextButton(
          onPressed: () => widget.state.changeStep(AuthenticatorStep.signIn),
          child: const Text(
            "Back to Login",
            style: TextStyle(color: Color.fromRGBO(0, 153, 224, 1)),
          ),
        ),
      ],
    );
  }
}
