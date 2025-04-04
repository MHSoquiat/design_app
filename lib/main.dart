import 'package:design_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // GetX package for navigation
import 'package:permission_handler/permission_handler.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:design_app/amplifyconfiguration.dart';
import 'package:design_app/sign_in_screen.dart';

Future<void> requestPermissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location,
  ].request();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  requestPermissions();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    try {
      final auth = AmplifyAuthCognito();
      await Amplify.addPlugin(auth);
      await Amplify.configure(amplifyconfig);
      safePrint('Successfully configured');
    } on Exception catch (e) {
      safePrint('Error configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Authenticator(
      // Use the authenticatorBuilder to customize the UI for each authentication step.
      authenticatorBuilder: (BuildContext context, AuthenticatorState state) {
        switch (state.currentStep) {
          case AuthenticatorStep.signIn:
            return CustomScaffold(
              state: state,
              body: SignInScreen(state: state), // Use the custom sign-in screen
            );

          case AuthenticatorStep.signUp:
            return CustomScaffold(
              state: state,
              body: SignUpForm(),
              footer: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => state.changeStep(AuthenticatorStep.signIn),
                    child: const Text("Sign In"),
                  ),
                ],
              ),
            );
          case AuthenticatorStep.confirmSignUp:
            return CustomScaffold(
              state: state,
              body: ConfirmSignUpForm(),
            );
          case AuthenticatorStep.resetPassword:
            return CustomScaffold(
              state: state,
              body: ResetPasswordForm(),
            );
          case AuthenticatorStep.confirmResetPassword:
            return CustomScaffold(
              state: state,
              body: const ConfirmResetPasswordForm(),
            );
          default:
            // Returning null defaults to the prebuilt Authenticator UI for any other steps.
            return null;
        }
      },
      // The child below is wrapped by the Authenticator and will be shown when the user is authenticated.
      child: GetMaterialApp(
        navigatorKey: Get.key, // Ensures GetX navigation works.
        builder: Authenticator
            .builder(), // Provides default widget wrappers for Authenticator.
        title: 'Design App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.from(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.red,
            backgroundColor: Colors.white,
          ),
        ).copyWith(
          indicatorColor: const Color.fromRGBO(2, 0, 102, 1),
        ),
        themeMode: ThemeMode.system,
        home: const MyHomePage(),
      ),
    );
  }
}

/// A widget that displays a title bar with a logo, a body, and an optional footer.
class CustomScaffold extends StatelessWidget {
  const CustomScaffold({
    super.key,
    required this.state,
    required this.body,
    this.footer,
  });

  final AuthenticatorState state;
  final Widget body;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Replace the title with your own logo image
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                child: body,
              ),
            ],
          ),
        ),
      ),
      persistentFooterButtons: footer != null ? [footer!] : null,
    );
  }
}
