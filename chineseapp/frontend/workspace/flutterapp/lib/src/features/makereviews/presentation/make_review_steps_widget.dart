import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutterapp/src/features/makereviews/application/make_review_controller.dart';
import 'package:flutterapp/src/features/makereviews/domain/review_params.dart';
import 'package:flutterapp/src/features/makereviews/domain/task.dart';
import 'package:flutterapp/src/features/makereviews/domain/user_word_sentence.dart';
import 'package:flutterapp/src/features/makereviews/presentation/image_popup_widget.dart';
import 'package:flutterapp/src/features/spacedrepetition/presentation/simple_review_card_widget.dart';
import 'package:timelines/timelines.dart';


class ReviewStepsList extends ConsumerStatefulWidget {
  final ReviewParams reviewParams;
  const ReviewStepsList({Key? key, required this.reviewParams}) : super(key: key);

  @override
  _ReviewStepsListState createState() => _ReviewStepsListState();
}

class _ReviewStepsListState extends ConsumerState<ReviewStepsList> {
  final textController = TextEditingController();
  List<Task> tasks = [
    Task('Listen'),
    Task('Translate'),
    Task('Choose image'),
    Task('Add note'),
  ];

  String _personalNote = '';
  String _imageLink = '';
  bool showNoteEditor = false;
  bool showImagePopup = false;

  @override 
  void didUpdateWidget(covariant ReviewStepsList oldWidget) {
    super.didUpdateWidget(oldWidget);

    tasks = [ 
      Task('Listen'),
      Task('Translate'),
      Task('Choose image'),
      Task('Add note'), 
    ];

    _personalNote = '';
    _imageLink = '';
  }

  Future<void> handleSpeech(word) async {
    await flutterTts.setLanguage("zh-CN");
    await flutterTts.speak(word);
  }

  void updateImage(String imageLink) {
    setState(() {
      _imageLink = imageLink;
    });
  }

  void handleTaskTap(int index) async {
    setState(() {
      tasks[index].isExpanded = !tasks[index].isExpanded;
      if (index == 0) {
        handleSpeech(widget.reviewParams.entry.pinyin);
        
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
                  icon: const Icon(Icons.volume_up), // Volume icon
                  onPressed: () async { await handleSpeech(widget.reviewParams.entry.pinyin); }, // handleSpeech method is called when the button is pressed
                ),
                const Align( 
                  alignment: Alignment.centerRight,
                  child: Padding( 
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text( 
                      'Listen to the pronunciation of simila sounds',
                      style: TextStyle( 
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      )
                    )
                  )
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 4.0, 
                  runSpacing: 4.0, 
                  children: widget.reviewParams.entry.similarSounds!.map((s) => 
                  InkWell( 
                    onTap: () async {
                      await handleSpeech(s);
                    },
                    child: Chip(
                      label: Text(
                        s, 
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black
                        )
                      ), 
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ),
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
        setState(() {
          showImagePopup = true;
        });
        
        if (_imageLink != '') {
          tasks[index].isDone = true;
        }
      } else if (index == 3) {
        setState(() {
          showNoteEditor = true;
        });
      }
    });
  }

  Widget buildAddNote(int index) {
    return Column( 
      children: [
        Padding( 
          padding: const EdgeInsets.all(8.0),
          child: Column( 
            children: [ 
              Text( 
                _personalNote,
                style: const TextStyle( 
                  fontSize: 16.0,
                )
              ),
              TextField( 
                controller: textController,
                decoration: const InputDecoration( 
                  labelText: 'Add note',
                ),
                onChanged: (value) {
                  if (value.length > 3) {
                    tasks[index].isDone = true;
                  } else {
                    tasks[index].isDone = false;
                  }
                  setState(() {
                    _personalNote = value;
                  });
                }
              ),
            ]
          )
        ),
      ],
    );
  }

  Widget buildAddImage(String query) {
    return Builder(
      builder: (BuildContext context) {
        return Column( 
          children: [
            Padding( 
              padding: const EdgeInsets.all(8.0),
              child: Column( 
                children: [ 
                  _imageLink != '' ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.network(
                        _imageLink, 
                        fit: BoxFit.cover, 
                        errorBuilder: (
                          BuildContext context, Object exception, StackTrace? stackTrace) {
                            return const SizedBox(height:0);
                        }
                      )
                    )) : Container(),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ImagePopUp(query: query, onImageSelected: updateImage);
                        },
                      );
                    },
                    child: Icon(Icons.add_a_photo), // replace with your desired widget
                  ),
                ]
              )
            ),
          ],
        );
      },
    );
  }

  @override 
  Widget build(BuildContext context) {
    return Container( 
      child: ref.watch(makeReviewProvider(widget.reviewParams)).when( 
        data: (userWordSentence) {
          if (userWordSentence.note != null && _personalNote == '') {
            _personalNote = userWordSentence.note!;
          }
          if (userWordSentence.imagePath != null && _imageLink == '') {

            _imageLink = userWordSentence.imagePath!;
          }
          if (_personalNote.length > 3 && showNoteEditor){
            tasks[3].expandedValue = buildAddNote(3);
          }

          if (showImagePopup) {
            tasks[2].expandedValue = buildAddImage(widget.reviewParams.entry.word);
          }

          bool allTasksDone = tasks.every((task) => task.isDone);

          return Container( 
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: <Widget> [
                Padding( 
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton( 
                    onPressed: allTasksDone ? () {
                      if (userWordSentence.note != '' || userWordSentence.imagePath != '') {
                        ref.read(makeReviewProvider(widget.reviewParams).notifier).updateExistingReview(
                          prevReview: userWordSentence, 
                          note: _personalNote, 
                          imagePath: _imageLink
                        );
                      } else {
                        ref.read(makeReviewProvider(widget.reviewParams).notifier).createNewReview(
                          prevReview: userWordSentence, 
                          note: _personalNote, 
                          imagePath: _imageLink
                        );
                      }
                    } : null,
                    style: ButtonStyle( 
                      backgroundColor: MaterialStateProperty.resolveWith<Color>( 
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.disabled)) {
                            return Colors.grey;
                          }
                          return Theme.of(context).colorScheme.shadow;
                        }
                      )
                    ),
                    child: Text( 
                      userWordSentence.note != null || userWordSentence.imagePath != null ? 'Update!' : 'Create!',
                      style: const TextStyle( 
                        fontSize: 16.0,
                      )
                    )
                  )
                ),
                Expanded( 
                  child: timelineBuilder(userWordSentence)
                ),
                
              ]
            ),
          );
        },
        loading: () => const CircularProgressIndicator(),
        error: (err, stack) => Text('Error: $err'),
      )
    );
  }


  Widget timelineBuilder(UserWordSentence userWordSentence) {
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