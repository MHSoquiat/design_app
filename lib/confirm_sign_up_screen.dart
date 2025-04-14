import 'package:flutter/material.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:design_app/sign_up_screen.dart';

class ConfirmSignUpScreen extends StatefulWidget {
  final AuthenticatorState state;

  const ConfirmSignUpScreen({super.key, required this.state});

  @override
  State<ConfirmSignUpScreen> createState() => _ConfirmSignUpScreenState();
}

class _ConfirmSignUpScreenState extends State<ConfirmSignUpScreen> {
  final TextEditingController confirmationCodeController =
      TextEditingController();
  String errorMessage = '';
  bool isLoading = false;

  Future<void> _confirmSignUp() async {
    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    debugPrint("Username value: '${widget.state.username}'");

    final String username = AuthDataHolder.username;
    final code = confirmationCodeController.text.trim();

    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: username,
        confirmationCode: code,
      );

      if (result.isSignUpComplete) {
        widget.state.changeStep(AuthenticatorStep.signIn);
      } else {
        setState(() => errorMessage = 'Confirmation incomplete.');
      }
    } on AuthException catch (e) {
      setState(() => errorMessage = e.message);
    } finally {
      setState(() => isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmation Error'),
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

    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: IntrinsicHeight(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: Text(
                    "Confirm Your Email",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 153, 224, 1),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: confirmationCodeController,
                  decoration: _inputDecoration("Enter confirmation code"),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _confirmSignUp,
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Confirm"),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () =>
                      widget.state.changeStep(AuthenticatorStep.signIn),
                  child: const Text(
                    "Back to Sign In",
                    style: TextStyle(
                      color: Color.fromRGBO(0, 153, 224, 1),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
