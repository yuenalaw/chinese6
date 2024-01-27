import 'package:flutter/material.dart';
import 'package:flutterapp/src/constants/colours.dart';
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
        textTheme: Theme.of(context).textTheme.apply( 
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        scaffoldBackgroundColor: customColourMap['BG']!,
        appBarTheme: AppBarTheme( 
          color: Colors.grey.shade900,
          foregroundColor: Colors.white,
          titleTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 24.0,
          ),
        ),
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightGreen),
        colorScheme: ColorScheme(
          primary: customColourMap['HOTPINK']!,
          onPrimary: Colors.black,
          secondary: customColourMap['PINK']!,
          onSecondary: Colors.black,
          background: customColourMap['BG']!,
          onBackground: Colors.white,
          surface: customColourMap['LIGHTPURPLE']!,
          onSurface: Colors.black,
          error: customColourMap['RED']!,
          onError: Colors.black,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
