import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';

class SignUpScreen extends StatefulWidget {
  final AuthenticatorState state;

  const SignUpScreen({super.key, required this.state});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class AuthDataHolder {
  static String username = "";
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String errorMessage = '';
  bool isLoading = false;

  Future<void> _signUp() async {
    final String email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      setState(() => errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    try {
      await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(userAttributes: {
          CognitoUserAttributeKey.email: email,
          CognitoUserAttributeKey.name: nameController.text.trim()
        }),
      );
      AuthDataHolder.username = email;
      widget.state.changeStep(AuthenticatorStep.confirmSignUp);
    } on AuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign Up Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(
          child: Text(
            "Create Account",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(0, 153, 224, 1),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: nameController,
          decoration: _inputDecoration("Enter your name"),
        ),
        const SizedBox(
          height: 16,
        ),
        TextFormField(
          controller: emailController,
          decoration: _inputDecoration("Enter your email"),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          obscureText: true,
          decoration: _inputDecoration("Enter your password"),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: confirmPasswordController,
          obscureText: true,
          decoration: _inputDecoration("Confirm your password"),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: isLoading ? null : _signUp,
          style: ElevatedButton.styleFrom(
            shape:
                const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Sign Up"),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => widget.state.changeStep(AuthenticatorStep.signIn),
          child: const Text(
            "Already have an account? Sign In",
            style: TextStyle(
              color: Color.fromRGBO(0, 153, 224, 1),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color.fromRGBO(2, 0, 102, 1)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Color.fromRGBO(2, 0, 102, 1)),
      ),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 16,
      ),
    );
  }
}
