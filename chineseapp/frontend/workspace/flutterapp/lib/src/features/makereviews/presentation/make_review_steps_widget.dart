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
    await flutterTts.setLanguage("zh-hans");
    await flutterTts.speak(widget.reviewParams.entry.pinyin);
  }

  void handleTaskTap(int index) async {
    setState(() {
      tasks[index].isDone = true;
      tasks[index].isExpanded = !tasks[index].isExpanded;
      if (index == 0) {
        handleSpeech();
        tasks[index].expandedValue = Text(widget.reviewParams.entry.pinyin);
      } else if (index == 1) {
        tasks[index].expandedValue = Text(widget.reviewParams.entry.getTranslationAsListOfLists().map((list) => list.join('')).join('\n'));
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
                                title: Text(tasks[index].headerValue),
                              );  
                            },
                            body: tasks[index].isExpanded ? Column( 
                              children: <Widget>[ 
                                tasks[index].expandedValue,
                                Checkbox( 
                                  value: tasks[index].isDone,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      tasks[index].isDone = value!;
                                    });
                                  }
                                )
                              ],
                            ) : Container(),
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
              child: Icon(Icons.check, color: Colors.white),
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