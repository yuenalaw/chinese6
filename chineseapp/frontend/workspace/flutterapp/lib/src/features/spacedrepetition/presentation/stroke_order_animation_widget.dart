import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stroke_order_animator/stroke_order_animator.dart';
import 'package:provider/provider.dart';

class StrokeOrderAnimatorWidget extends StatefulWidget {
  final String character;
  const StrokeOrderAnimatorWidget({Key? key, required this.character}) : super(key: key);

  @override 
  _StrokeOrderAnimatorWidgetState createState() => _StrokeOrderAnimatorWidgetState();
}

class _StrokeOrderAnimatorWidgetState extends State<StrokeOrderAnimatorWidget> with TickerProviderStateMixin {
  final _httpClient = http.Client();
  late Future<StrokeOrderAnimationController> _animationController;

  @override 
  void initState() {
    super.initState();
    _animationController = _loadStrokeOrder(widget.character);
  }

  @override 
  void dispose() {
    _httpClient.close();
    super.dispose();
  }

  Future<StrokeOrderAnimationController> _loadStrokeOrder(
    String character,
  ) async {
    return downloadStrokeOrder(character, _httpClient).then((value) {
      final controller = StrokeOrderAnimationController(
        StrokeOrder(value),
        this,
        onQuizCompleteCallback: (summary) {
          // Fluttertoast.showToast(
          //   msg: 'Quiz finished. ${summary.nTotalMistakes} mistakes',
          // );

          setState(() {});
        },
      );

      return controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox( 
        width: 500,
        child: Column( 
          children: [ 
            const SizedBox(height:50),
            _buildStrokeOrderAnimationAndControls(),
          ],
        )
      )
    );
  }

  FutureBuilder<StrokeOrderAnimationController> _buildStrokeOrderAnimationAndControls() {
    return FutureBuilder(
      future: _animationController,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          return Expanded(
            child: Column(
              children: [
                _buildStrokeOrderAnimation(snapshot.data!),
                _buildAnimationControls(snapshot.data!),
              ],
            ),
          );
        }
        if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStrokeOrderAnimation(StrokeOrderAnimationController controller) {
    return SizedBox.square(
      dimension: 350,
      child: ChangeNotifierProvider<StrokeOrderAnimationController>.value(
        value: controller,
        child: Consumer<StrokeOrderAnimationController>(
          builder: (context, controller, child) {
            return FittedBox(
              child: StrokeOrderAnimator(controller, key: UniqueKey()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimationControls(StrokeOrderAnimationController controller) {
    return ChangeNotifierProvider.value(
      value: controller,
      builder: (context, child) => Consumer<StrokeOrderAnimationController>(
        builder: (context, controller, child) => Flexible(
          child: GridView(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 3,
              crossAxisCount: 2,
              mainAxisSpacing: 10,
            ),
            primary: false,
            children: <Widget>[
              MaterialButton(
                onPressed: controller.isQuizzing
                    ? null
                    : (controller.isAnimating
                        ? controller.stopAnimation
                        : controller.startAnimation),
                child: controller.isAnimating
                    ? const Text('Stop animation')
                    : const Text('Start animation'),
              ),
              MaterialButton(
                onPressed: controller.isQuizzing
                    ? controller.stopQuiz
                    : controller.startQuiz,
                child: controller.isQuizzing
                    ? const Text('Stop quiz')
                    : const Text('Start quiz'),
              ),
              MaterialButton(
                onPressed: controller.reset,
                child: const Text('Reset'),
              ),
              MaterialButton(
                onPressed: () {
                  controller.setHighlightRadical(!controller.highlightRadical);
                },
                child: controller.highlightRadical
                    ? const Text('Unhighlight radical')
                    : const Text('Highlight radical'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}