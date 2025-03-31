import 'package:design_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Import GetX package
import 'package:permission_handler/permission_handler.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_authenticator/amplify_authenticator.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:design_app/amplifyconfiguration.dart';

Future<void> requestPermissions() async {
  await [
    Permission.bluetooth,
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.location
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

      // call Amplify.configure to use the initialized categories in your app
      await Amplify.configure(amplifyconfig);
    } on Exception catch (e) {
      safePrint('An error occurred configuring Amplify: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Authenticator(
        signUpForm: SignUpForm.custom(fields: [
          SignUpFormField.name(required: true),
          SignUpFormField.email(required: true),
          SignUpFormField.password(),
          SignUpFormField.passwordConfirmation()
        ]),
        child: GetMaterialApp(
          builder: Authenticator.builder(),
          // Use GetMaterialApp instead of MaterialApp
          title: 'Design App',
          debugShowCheckedModeBanner: false, // Optional: Removes debug banner
          theme: ThemeData(
            colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
            useMaterial3: true,
          ),
          home: const MyHomePage(),
        ));
  }
}


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       // Use GetMaterialApp instead of MaterialApp
//       title: 'Design App',
//       debugShowCheckedModeBanner: false, // Optional: Removes debug banner
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
//         useMaterial3: true,
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }
