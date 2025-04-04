import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:flutter/widgets.dart';

class SignInScreen extends StatefulWidget {
  final AuthenticatorState state;

  const SignInScreen({super.key, required this.state});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  Future<void> _signIn() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      SignInResult result = await Amplify.Auth.signIn(
        username: emailController.text.trim(),
        password: passwordController.text,
      );

      if (result.isSignedIn) {
        safePrint("✅ Signed in successfully!");
        return; // No need to change the step manually
      } else {
        safePrint("⚠️ Sign-in unsuccessful!");
        setState(() {
          errorMessage = "Sign-in failed. Please try again.";
        });
      }
    } on AuthException catch (e) {
      safePrint("❌ Error: ${e.message}");
      setState(() {
        errorMessage = e.message;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _forgotPassword() async {
    // Navigate to the Forgot Password step in Amplify Authenticator
    widget.state.changeStep(AuthenticatorStep.resetPassword);
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      // Trigger the dialog only once
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              title: const Text(
                'Invalid Account',
                style: TextStyle(
                    color: Color.fromRGBO(2, 0, 102, 1),
                    fontWeight: FontWeight.bold),
              ),
              content: Text(errorMessage),
              actions: <Widget>[
                // Center and stretch the button
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: double.infinity, // Make the button stretch
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.zero, // Remove border radius
                        ),
                        backgroundColor: const Color.fromRGBO(0, 153, 224, 1),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text(
                        'Continue',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            "Hello!", // Custom text above the field
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(0, 153, 224, 1),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Custom Email Text Box
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(
            filled: true,
            fillColor: Colors.white, // Light grey background
            hintText: "Enter your email",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                    color: Color.fromRGBO(2, 0, 102, 1)) // Rounded corners
                ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color.fromRGBO(2, 0, 102, 1))),
            contentPadding: EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),

        const SizedBox(height: 16),

        // Password Text Box
        // Password Text Box
        TextFormField(
          controller: passwordController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "Enter your password",
            border: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(
                    color: Color.fromRGBO(2, 0, 102, 1)) // Rounded corners
                ),
            enabledBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.zero,
                borderSide: BorderSide(color: Color.fromRGBO(2, 0, 102, 1))),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            suffixIcon: TextButton(
              onPressed: _forgotPassword, // Call function when tapped
              child: const Text(
                "Forgot?",
                style: TextStyle(
                  color: Color.fromRGBO(0, 153, 224, 1),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          obscureText: true,
        ),
// Error Message

        const SizedBox(height: 40),
        // Sign-In Button
        ElevatedButton(
          onPressed: isLoading ? null : _signIn, // Disable button if loading
          style: ElevatedButton.styleFrom(
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "Log In",
                  style: TextStyle(fontSize: 16),
                ),
        ),

        const SizedBox(height: 16),

        // Sign-Up Navigation
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color.fromRGBO(0, 153, 224, 1)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
          onPressed: () => widget.state.changeStep(AuthenticatorStep.signUp),
          child: const Text(
            "Sign Up",
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(0, 153, 224, 1)),
          ),
        ),
      ],
    );
  }
}
