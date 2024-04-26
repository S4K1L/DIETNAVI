import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // Replace with actual values
    options: const FirebaseOptions(
      apiKey: "AIzaSyD_LTqJmhpfJn0C-HgNX-4k9inMR1fI640",
      appId: "1:894982810977:android:654730ae55615116eda920",
      messagingSenderId: "894982810977",
      projectId: "fypdatabase-c8728",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: WillPopScope(
        onWillPop: () async => Future.value(false),
        child: AnimatedSplashScreen.withScreenFunction(
          splash: 'assets/logo.png',
          splashIconSize: 150,

          screenFunction: () async{
            return LoginPage();
          },
          splashTransition: SplashTransition.sizeTransition,
        ),
      ),
    );
  }
}
