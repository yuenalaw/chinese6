import 'package:flutter/material.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/lesson_games.dart';
import 'package:flutterapp/src/features/useroverview/presentation/progress_widget.dart';
import 'package:flutterapp/src/features/useroverview/presentation/streak_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int totalLessons = 0;

  void lessonCountToday(int count) {
    if (count > totalLessons) {
      setState(() {
        totalLessons = count;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Stack( 
              alignment: Alignment.center,
              children: <Widget>[ 
                const StreakWidget(),
                ProgressWidget(totalLessons: totalLessons),
              ]
            )
          ),
          Padding( 
            padding: const EdgeInsets.only(left: 32),
            child: AnimatedDefaultTextStyle(
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.primary,
            ),
            duration: const Duration(milliseconds: 300),
            child: const Text('Let\'s work it!'), 
            )
          ),
          Padding( 
            padding: EdgeInsets.all(8.0),
            child: LessonGames(onLoadLessons: lessonCountToday),
          ),
        ],
      ),
    );
  }
}

