import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/available_videos_widget.dart';
import 'package:flutterapp/src/features/useroverview/presentation/streak_widget.dart';
import 'package:flutterapp/src/features/youtubeintegration/presentation/search_bar.dart';
import 'package:flutterapp/src/screens/game_path_screen.dart';

class HomeScreen2 extends ConsumerWidget {
  const HomeScreen2({Key? key}) : super(key: key);

  @override 
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold( 
      appBar: AppBar( 
        title: const Text('Home page'),
      ),
      body: SingleChildScrollView( 
        child: Column (
          children: <Widget>[
            const SearchBarWidget(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: StreakWidget(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                elevation: 5.0, // Add shadow
                borderRadius: BorderRadius.circular(30.0), // Round corners
                // child: InkWell(
                //   onTap: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(builder: (context) => GamePathScreen()),
                //     );
                //   },
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0), // Add padding
                        child: Image.asset('assets/quakkityintro.gif'), // Replace with your actual GIF path
                      )
                    ],
                  ),
                ),
              ),
            //),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: AvailableVideos(),
            ),
          ],
        ),
      ),
    );
  }
}
