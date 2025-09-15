import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/string_utils.dart';
import 'dart:io';
import 'package:camera/camera.dart' as cam;
import 'package:wonders/ui/common/modals/video_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wonders/ui/common/controls/simple_header.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/cupertino.dart';

import 'package:wonders/ui/common/pop_router_on_over_scroll.dart';
import 'package:wonders/ui/common/app_backdrop.dart';
import 'package:wonders/ui/common/compass_divider.dart';
import 'package:wonders/ui/common/timeline_event_card.dart';
import 'package:wonders/ui/screens/home_menu/listen_menu.dart';
import 'package:eventsource/eventsource.dart';

import '../../common/curved_clippers.dart';
import '../../common/list_gradient.dart';
import '../../common/themed_text.dart';
import '../../wonder_illustrations/common/wonder_title_text.dart';

part '_vertical_swipe_controller.dart';
part 'widgets/_animated_arrow_button.dart';
part 'widgets/_entry_input.dart';
part 'widgets/_events_list.dart';
part 'widgets/_top_content.dart';

GlobalKey<_EventsListState> _eventsListKey = GlobalKey<_EventsListState>();

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

// Create a custom WidgetsBinding observer to track keyboard height changes
class KeyboardHeightObserver extends WidgetsBindingObserver {
  final void Function(double keyboardHeight) onKeyboardHeightChanged;

  //to get the input keyboard height
  KeyboardHeightObserver({required this.onKeyboardHeightChanged});

  //to call function inside _eventList

  @override
  void dispose() {
    print("----dispose observer.");
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    final keyboardHeight = WidgetsBinding.instance.window.viewInsets.bottom;
    onKeyboardHeightChanged(keyboardHeight);
  }
}

class _ChatScreenState extends State<ChatScreen> {
  static const double _topHeight = 450;
  static const String _loading = 'Loading...';
  late final Future<Map<int, String>> _dataResume = resumeLogic.getResumeEventData();
  final EventSourceManager eventSourceManager = EventSourceManager();
  final TextEditingController _textFieldController = TextEditingController();
  bool eventEnd = false;
  final Map<int, String> eventMap = {};
  int eventMapPoint = 1;
  bool _isMenuOpen = false;
  // Create a FocusNode instance
  //final FocusNode _focusNode = FocusNode();
  double keyboardHeight = 0.0;
  late KeyboardHeightObserver keyOb;

  @override
  void initState() {
    super.initState();

    keyOb = KeyboardHeightObserver(
      onKeyboardHeightChanged: (double height) {
        setState(() {
          keyboardHeight = height;
          eventListScrollToBottom();
        });
      },
    );

    WidgetsBinding.instance.addObserver(keyOb);
    eventMap[0] = '初めまして。何についてのご相談でしょうか？';
  }

  void eventListScrollToBottom() {
    if (_eventsListKey.currentState != null) {
      _eventsListKey.currentState!.scrollToBottom();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(keyOb);
    _textFieldController.dispose();
    super.dispose();
  }

  void _handleOpenMenuPressed() async {
    setState(() => _isMenuOpen = true);
    String? listenText;

    listenText = await appLogic.showHalfscreenDialogRoute<String>(
      context,
      ListenMenu(
        onMenuClosed: (retText) {
          setState(() {
            listenText = retText;
            _textFieldController.text = listenText ?? ''; // Set the text to the TextField's controller
            handleSendButtonPress();
          });
        },
      ),
    );
    setState(() => _isMenuOpen = false);
  }

  void onBack() {
    print("-----");
    Navigator.of(context).pop();
  }

  Future<void> _connectToEventSource() async {
    await eventSourceManager.connectToEventSource(_textFieldController.text);
    eventListScrollToBottom();

    eventSourceManager.eventSource.listen((Event event) async {
      setState(() {
        if (event.data != null) {
          if (eventMap[eventMapPoint] == _loading) {
            eventMap[eventMapPoint] = 'Ａ：';
          }
          eventMap[eventMapPoint] = (eventMap[eventMapPoint] ?? '') + event.data!;
        }
      });
    });

    eventSourceManager.eventSource.listen(
      (Event event) async {
        setState(() {
          if (event.data != null) {
            if (eventMap[eventMapPoint] == _loading) {
              eventMap[eventMapPoint] = 'Ａ：';
            }
            eventMap[eventMapPoint] = (eventMap[eventMapPoint] ?? '') + event.data!;
          }
        });
      },
      onDone: () {
        setState(() {
          eventMapPoint++;
          eventEnd = true;
        });
      },
    );
  }

  Future<void> handleSendButtonPress() async {
    setState(() {
      String message = _textFieldController.text;
      eventMap[eventMapPoint] = message;
      eventMapPoint++;

      eventMap[eventMapPoint] = _loading;

      _connectToEventSource();

      eventEnd = false;
    });

    //await Future.delayed(Duration(seconds: 2));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return Container(
        color: $styles.colors.black,
        child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: BackBtn(
                    onPressed: onBack,
                  ).safe(),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, snapshot) {
                      return Stack(
                        children: [
                          _TopContent(),
                          _EventsList(key: _eventsListKey, data: eventMap),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  height: keyboardHeight / 2 + 65, // or 312 Adjust the height according to your needs
                  color: Colors.grey, // Adjust the color according to your needs
                  padding: EdgeInsets.symmetric(horizontal: 16),

                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: CupertinoTextField(
                            //focusNode: _focusNode,
                            onEditingComplete: () {
                              // Handle the editing complete event here
                              print('Editing complete');
                              SystemChannels.textInput.invokeMethod('TextInput.hide');
                            },
                            controller: _textFieldController,
                            placeholder: 'Type your message...',
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: CupertinoButton(
                            child: Icon(Icons.send),
                            onPressed: () async {
                              handleSendButtonPress();
                            },
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: Align(
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: Icon(Icons.keyboard_voice),
                                onPressed: () {
                                  _handleOpenMenuPressed();
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      );
    });
  }
}

class EventSourceManager {
  late EventSource eventSource;
  List<String> eventLog = [];

  Future<bool> connectToEventSource(String question) async {
    final String url = 'https://ailawyer.hokuto.io/api/openai-stream?question=' + question + '&chatModel=3.5';
    eventSource = await EventSource.connect(url);

    return true;
  }
}
