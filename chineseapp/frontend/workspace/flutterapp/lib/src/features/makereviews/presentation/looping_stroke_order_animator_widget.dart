import 'package:flutter/material.dart';
import 'package:stroke_order_animator/stroke_order_animator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class LoopingStrokeOrderAnimator extends StatefulWidget {
  final String character;
  final double animationSpeedFactor;

  const LoopingStrokeOrderAnimator({
    Key? key,
    required this.character,
    this.animationSpeedFactor = 1.0,
  }) : super(key: key);

  @override 
  _LoopingStrokeOrderAnimatorState createState() => _LoopingStrokeOrderAnimatorState();
}

class _LoopingStrokeOrderAnimatorState extends State<LoopingStrokeOrderAnimator> with TickerProviderStateMixin {
  final _httpClient = http.Client();
  late Future<StrokeOrderAnimationController> _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = _loadStrokeOrder(widget.character);
  }

  @override 
  void didUpdateWidget(covariant LoopingStrokeOrderAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.character != oldWidget.character) {
      _animationController = _loadStrokeOrder(widget.character);
    }
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

          setState(() {});
        },
      );
      controller.startAnimation();
      return controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      child: SingleChildScrollView( 
        child: SizedBox( 
          width: 350,
          child: Column( 
            children: [ 
              const SizedBox(height: 50),
              _buildStrokeOrderAnimationAndControls(),
            ]
          )
        ) 
      )
    );
  }

  FutureBuilder<StrokeOrderAnimationController>
      _buildStrokeOrderAnimationAndControls() {
    return FutureBuilder(
      future: _animationController,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          return Container( 
            height: 350,
            width: 350,
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
      dimension: 250,
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
        builder: (context, controller, child) => Column(
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
                onPressed: controller.reset,
                child: const Text('Reset'),
              ),
            ],
          ),
        ),
    );
  }
}