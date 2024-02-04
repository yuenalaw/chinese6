import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/lessonoverview/presentation/libraries_display.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:anim_search_bar/anim_search_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: <Widget>[ 
          Consumer(builder: (context, watch, child) {
            return Padding( 
              padding: const EdgeInsets.only(right: 8.0),
              child: AnimSearchBar(
                width: 350, 
                textController: _searchController, 
                onSuffixTap: () {
                  setState(() {
                    _searchController.clear();
                  });
                }, 
                rtl: true,
                helpText: "Search for a new video",
                onSubmitted: (value) {
                  print("value is $value");
                  return;
                },
              )
            );
          })
        ]
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: AnimatedTextKit( 
                  animatedTexts: [ 
                    TyperAnimatedText("What shall we study today?",
                    textStyle: const TextStyle( 
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ))
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Padding( 
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: LibraryDisplay(),
            ),
          ),
        ],
      ),
    );
  }
}

