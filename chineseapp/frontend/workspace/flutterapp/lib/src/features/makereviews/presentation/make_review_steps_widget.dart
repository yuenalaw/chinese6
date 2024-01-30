import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_params.dart';
import 'package:flutterapp/src/features/makereviews/domain/task.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/simple_review_card_widget.dart';
import 'package:timelines/timelines.dart';


class ReviewStepsList extends StatefulWidget {
  final ReviewParams reviewParams;
  const ReviewStepsList({Key? key, required this.reviewParams}) : super(key: key);

  @override
  _ReviewStepsListState createState() => _ReviewStepsListState();
}

class _ReviewStepsListState extends State<ReviewStepsList> {
  List<Task> tasks = [
    Task('Listen'),
    Task('Translate'),
    Task('Choose image'),
    Task('Add note'),
  ];

  @override 
  void didUpdateWidget(covariant ReviewStepsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    tasks = [ 
      Task('Listen'),
      Task('Translate'),
      Task('Choose image'),
      Task('Add note'), 
    ];
  }

  Future<void> handleSpeech() async {
    await flutterTts.setLanguage("zh-CN");
    await flutterTts.speak(widget.reviewParams.entry.pinyin);
  }

  void handleTaskTap(int index) async {
    setState(() {
      tasks[index].isExpanded = !tasks[index].isExpanded;
      if (index == 0) {
        handleSpeech();
        
        final listenWidget = Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(widget.reviewParams.entry.pinyin),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.volume_up), // Volume icon
                  onPressed: handleSpeech, // handleSpeech method is called when the button is pressed
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4.0, // gap between adjacent chips
                  runSpacing: 4.0, // gap between lines
                  children: widget.reviewParams.entry.similarSounds!.map((s) => 
                  Chip(
                    label: Text(
                      s, 
                      style: const TextStyle(
                        fontSize: 12,
                         color: Colors.black
                      )
                    ), 
                    backgroundColor: Theme.of(context).colorScheme.surface,
                  )).toList(),
                ),
              ],
            ),
          ),
        );

        tasks[index].expandedValue = listenWidget;

        tasks[index].isDone = true;
      } else if (index == 1) {
        final translationWidget = Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.reviewParams.entry.getTranslationAsListOfLists().map((t) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      children: const LineSplitter().convert(t.join(', ')).map((line) =>
                        Text(
                          line,
                          style: const TextStyle( 
                            color: Colors.black,
                            fontSize: 16.0,
                          ),
                        ),
                      ).toList(),
                    ),
                  ),
                ),
              ).toList(),
            ),
          ),
        );
        tasks[index].expandedValue = translationWidget;
        tasks[index].isDone = true;
      } else if (index == 2) {
        tasks[index].expandedValue = Text('Choose image');
      } else if (index == 3) {
        tasks[index].expandedValue = TextField( 
          controller: TextEditingController(),
          decoration: const InputDecoration( 
            labelText: 'Add note',
          )
        );
      }
    });
  }

  
  @override 
  Widget build(BuildContext context) {
    return Container( 
      height: MediaQuery.of(context).size.height,
      child: timelineBuilder()
    );
  }


  Widget timelineBuilder() {
    return Timeline.tileBuilder( 
      theme: TimelineThemeData( 
        nodePosition: 0,
        connectorTheme: const ConnectorThemeData( 
          thickness: 3.0,
        )
      ),
      builder: TimelineTileBuilder.connected( 
        connectionDirection: ConnectionDirection.before,
        itemCount: tasks.length,
        contentsBuilder: (_, index) => 
          GestureDetector( 
            onTap: () => handleTaskTap(index),
            child: 
              Padding( 
                padding: const EdgeInsets.all(24.0),
                child: Card(
                  shape: RoundedRectangleBorder( 
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  color: Theme.of(context).colorScheme.primary,
                  child: Container( 
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: ExpansionPanelList( 
                        expansionCallback: (int index, bool isExpanded) {
                          setState(( ) {
                            tasks[index].isExpanded = !isExpanded;
                            handleTaskTap(index);
                          });
                        },
                        children: [ 
                          ExpansionPanel( 
                            headerBuilder: (BuildContext context, bool isExpanded) {
                              return ListTile( 
                                title: Text(
                                  tasks[index].headerValue,
                                  style: const TextStyle( 
                                    color: Colors.black,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w500,
                                  )
                                
                                ),
                              );  
                            },
                            body: Padding( 
                              padding: const EdgeInsets.all(8.0),
                              child: tasks[index].isExpanded ? Column( 
                                children: <Widget>[ 
                                  tasks[index].expandedValue,
                                ],
                              ) : Container(),
                            ),
                            isExpanded: tasks[index].isExpanded,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ),
        indicatorBuilder: (_, index) {
          if (tasks[index].isDone) {
            return const DotIndicator(
              size: 20.0,
              color: Color(0xff7349FE),
              child: Icon(Icons.check, color: Colors.white, size: 12.0),
            );
          } else {
            return const OutlinedDotIndicator(
              size: 20.0,
              borderWidth: 2.5,
            );
          }
        },
        connectorBuilder: (_, index, ___) =>
          SolidLineConnector(
            color: tasks[index].isDone ? Theme.of(context).colorScheme.primary : Colors.grey,
          ),
        ),
      );
  }
}