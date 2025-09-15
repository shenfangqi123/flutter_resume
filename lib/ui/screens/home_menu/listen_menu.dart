import 'package:flutter/cupertino.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/ui/common/app_backdrop.dart';
import 'dart:async'; // Import the Timer class

//SpeechToText part
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:wonders/ui/wonder_illustrations/common/wonder_title_text.dart';

class ListenMenu extends StatefulWidget {
  const ListenMenu({Key? key, required this.onMenuClosed}) : super(key: key);
  final Function(String?) onMenuClosed; // Callback function

  @override
  _ListenMenuState createState() => _ListenMenuState();
}

class _ListenMenuState extends State<ListenMenu> {
  double progress = 0.0;
  bool isPressed = false;
  Timer? progressTimer;
  //SpeechToText part
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String? _lastWords;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _handleSendTap() {
    isPressed = false;
    if(_lastWords == null) {
      return;
    }
    widget.onMenuClosed(_lastWords);
    _closeDialog();
  }

  void _handleClearTap() {
    _lastWords = null;
    finishListening();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      if(result.finalResult) {
        setState(() {
          isPressed = false;
          finishListening();
        });
      }
    });
  }

  @override
  void dispose() {
    progressTimer?.cancel();
    super.dispose();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }


  void finishListening() {
    progressTimer?.cancel();
    progress = 0.0;
    _stopListening();
  }

  void _handleTapDown() {
    setState(() {
      isPressed = true;
      progressTimer = Timer.periodic(Duration(milliseconds: 50), (_) {
        _incrementProgress();
        _startListening();
      });
    });
  }

  void _handleTapUp() {
    setState(() {
      isPressed = false;
      finishListening();
    });

  }

  void _incrementProgress() {
    setState(() {
      progress += 0.01;
      if(progress >= 1.0) {
        finishListening();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        /// Backdrop / Underlay
        AppBackdrop(
          strength: .5,
          child: Container(
            color: $styles.colors.greyStrong.withOpacity(.7),
          ),
        ),

        /*
        SafeArea(
          child: PaddedRow(
            padding: EdgeInsets.symmetric(
              horizontal: $styles.insets.md,
              vertical: $styles.insets.sm,
            ),

            children: [
              /// Back btn
              BackBtn.close(
                bgColor: Colors.transparent,
                iconColor: $styles.colors.offWhite,
              ),
            ],

          ),
        ),
         */

        /// Content
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: $styles.insets.lg),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Semantics(
                    // Hide the title when the menu is open for visual polish
                    child: AnimatedOpacity(
                      opacity: 1,
                      duration: $styles.times.fast,
                      child: WonderTitleText(_lastWords ?? 'お話してください。', enableShadows: true)
                          .animate(onPlay: (controller) => controller.repeat())
                          .shimmer(delay: 4000.ms, duration: $styles.times.med * 3)
                          .shake(curve: Curves.easeInOutCubic, hz: 4)
                          //.scale(begin: 1.0, end: 1.1, duration: $styles.times.med)
                          .then(delay: $styles.times.med)
                          //.scale(begin: 1.0, end: 1 / 1.1),
                    ),
                  ),

                  Gap($styles.insets.xl),

                  Spacer(flex: 1),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          child:  _lastWords==null ? CupertinoButton(
                              child: Icon(
                              Icons.layers_clear_outlined,
                              color: Colors.white,
                              size: 30
                            ),
                            onPressed: _closeDialog,
                          ) :
                          CupertinoButton(
                            child: Icon(
                                Icons.replay_circle_filled,
                                color: Colors.white,
                                size: 30
                            ),
                              onPressed: _handleClearTap,
                          ),
                        )
                      ),

                      Expanded(
                        flex: 5,
                        child: _buildIconGrid(context)
                            .animate()
                            .fade(duration: $styles.times.fast),
                            //.scale(begin: .8, curve: Curves.easeOut),
                      ),

                      Expanded(
                        flex:2,
                        child: _lastWords==null ?
                        Container() :
                        Container(
                          child:CupertinoButton(
                            child: Icon(
                                Icons.skip_next_outlined,
                                color: Colors.white,
                                size: 38
                            ),
                            onPressed: _handleSendTap,
                          ),
                        )

                      ),
                    ],
                  ),

                  Gap($styles.insets.xl),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }



  Widget _buildIconGrid(BuildContext context) {
    return GestureDetector(
      onLongPressStart:(LongPressStartDetails details) async {
        _handleTapDown();
      },

      onLongPressEnd:(LongPressEndDetails details) async {
        _handleTapUp();
      },

      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100, // Set the desired width
            height: 100, // Set the desired height
            child: CircularProgressIndicator(
              value: progress, // Set the progress to 50%
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue), // Set the color to blue
              backgroundColor: Colors.transparent, // Make the background transparent
              strokeWidth: 4.0, // Adjust the strokeWidth as needed
            ),
          ),

          ClipRRect(
            borderRadius:
            BorderRadius.circular(90 / 2),
            child: Container(
                  height: 90,
                  width: 90,
                  color: Colors.green,
                  child: Icon(
                      Icons.keyboard_voice,
                      color: Colors.white,
                      size: 50,
                  )
              ),
          )

          //Icon(
          //  Icons.keyboard_voice,
          //  color: Colors.indigo,
          //  size: 50,
          //),

          //Transform.scale(
          //    scale: 2.0, // Adjust the scale factor as needed
          //    child: SvgPicture.asset(SvgPaths.compassFull, color: $styles.colors.offWhite),
          //),
        ],
      ),
    );
  }
}
