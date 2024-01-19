import 'package:flutter/material.dart';
import 'package:flutterapp/src/screens/home_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key:key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chinese Learning App',
      theme: ThemeData(
        fontFamily: 'Poppins',
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        // colorScheme: ColorScheme(

        // ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
