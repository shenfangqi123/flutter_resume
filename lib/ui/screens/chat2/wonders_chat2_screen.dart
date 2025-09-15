import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/string_utils.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'package:camera/camera.dart' as cam;
import 'package:wonders/ui/common/modals/video_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wonders/ui/common/controls/simple_header.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import 'package:flutter/cupertino.dart';

import 'package:wonders/ui/common/pop_router_on_over_scroll.dart';
import 'package:wonders/ui/common/app_backdrop.dart';
import 'package:wonders/ui/common/compass_divider.dart';
import 'package:wonders/ui/common/timeline_event_card.dart';
import 'package:wonders/ui/screens/home_menu/listen_menu.dart';
import 'package:eventsource/eventsource.dart';
import 'package:video_player/video_player.dart';

import 'package:wonders/logic/common/TTSUtil.dart';

import 'package:wonders/ui/common/curved_clippers.dart';
import 'package:wonders/ui/common/list_gradient.dart';
import 'package:wonders/ui/common/themed_text.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_title_text.dart';
import 'package:wonders/logic/data/lawyer_data.dart';

part '_vertical_swipe_controller.dart';
part 'widgets/_animated_arrow_button.dart';
part 'widgets/_entry_input.dart';
part 'widgets/_events_list.dart';
part 'widgets/_top_content.dart';

GlobalKey<_EventsListState> _eventsListKey = GlobalKey<_EventsListState>();

class Chat2Screen extends StatefulWidget {
  Chat2Screen({Key? key}) : super(key: key);

  @override
  _Chat2ScreenState createState() => _Chat2ScreenState();
}

// Create a custom WidgetsBinding observer to track keyboard height changes
class KeyboardHeightObserver extends WidgetsBindingObserver {
  final void Function(double keyboardHeight) onKeyboardHeightChanged;

  //to get the input keyboard height
  KeyboardHeightObserver({required this.onKeyboardHeightChanged});

  //to call function inside _eventList
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeMetrics() {
    final keyboardHeight = WidgetsBinding.instance.window.viewInsets.bottom;
    onKeyboardHeightChanged(keyboardHeight);
  }
}

class _Chat2ScreenState extends State<Chat2Screen> {
  late Directory appDir;
  static const double _topHeight = 450;
  static const String _loading = 'Loading...';
  Offset _offset = Offset(220, 420);
  bool _isDragging = false;

  late final Future<Map<int, String>> _dataResume = resumeLogic.getResumeEventData();
  late final Future<List<LawyerInfo>?> _avatar = resumeLogic.fetchLawyerAvatar();

  final EventSourceManager eventSourceManager = EventSourceManager();
  final TextEditingController _textFieldController = TextEditingController();
  late VideoPlayerController _videoPlayerController;
  bool playing = false;

  bool eventEnd = false;
  final Map<int, String> eventMap = {};
  List<LawyerInfo>? lawyerList = [];
  int lawyerPointer = 0;
  int nextLineTextCnt = 0;

  int eventMapPoint = 1;
  bool _isMenuOpen = false;
  // Create a FocusNode instance
  //final FocusNode _focusNode = FocusNode();
  double keyboardHeight = 0.0;
  late KeyboardHeightObserver keyOb;

  @override
  void initState() {
    late LawyerInfo? lawyer;
    super.initState();
    initializeAppDir();

    TTSUtil.audioPlayer.onPlayerStateChanged.listen((event) {
      if (event == PlayerState.completed) {
        //speechingMap = {};
        playing = false;
        //notifyListeners();
      }
    });

    //init avater video
    _avatar.then((lawyerRec) async {
      if (lawyerRec != null) {
        lawyerList = lawyerRec;
        if (lawyerList!.isNotEmpty) {
          for (int i = 0; i < lawyerList!.length; i++) {
            lawyer = lawyerList?[i];
            await downloadAndSaveVideo(lawyer!.avatarAnimations, i.toString());
          }

          //final appDir = await getApplicationDocumentsDirectory();
          _videoPlayerController = VideoPlayerController.file(File('${appDir.path}/0.mp4'))
            ..initialize().then((_) {
              setState(() {});
              _videoPlayerController.play(); // Autoplay the video after initialization
              _videoPlayerController.setLooping(true);
            });
        }
      }
    }).catchError((error) {
      print('Error fetching lawyer AI avatar: $error');
    });

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

  Future<void> initializeAppDir() async {
    appDir = await getApplicationDocumentsDirectory();
  }

  Future<void> downloadAndSaveVideo(String videoUrl, String fn) async {
    final response = await http.get(Uri.parse(videoUrl));
    final appDir = await getApplicationDocumentsDirectory();
    final videoFile = File('${appDir.path}/$fn.mp4');
    await videoFile.writeAsBytes(response.bodyBytes);
  }

  void speech(String toRead) {
    TTSUtil.playVoice(toRead);
    playing = true;
  }

  Future<void> switchLawyer() async {
    late LawyerInfo? lawyer;
    lawyerPointer = 1 - lawyerPointer;
    lawyer = lawyerList?[lawyerPointer];
    //final appDir = await getApplicationDocumentsDirectory();

    _videoPlayerController = VideoPlayerController.file(File('${appDir.path}/$lawyerPointer.mp4'))
      ..initialize().then((_) {
        setState(() {});
        _videoPlayerController.play(); // Autoplay the video after initialization
        _videoPlayerController.setLooping(true);
      });
  }

  void eventListScrollToBottom() {
    if (_eventsListKey.currentState != null) {
      _eventsListKey.currentState!.scrollToBottom();
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
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
    Navigator.of(context).pop();
  }

  Future<void> _connectToEventSource() async {
    await eventSourceManager.connectToEventSource(_textFieldController.text);

    eventSourceManager.eventSource.listen((Event event) async {
      setState(() {
        if (event.data != null) {
          if (eventMap[eventMapPoint] == _loading) {
            eventMap[eventMapPoint] = 'Ａ：';
          }
          eventMap[eventMapPoint] = (eventMap[eventMapPoint] ?? '') + event.data!;
          eventListScrollToBottom();
        }
      });
    });

    eventSourceManager.eventSource.listen((Event event) {
      if (event.event == 'end') {
        if (eventMap[eventMapPoint] != null) {
          speech(eventMap[eventMapPoint]!);
        }
        eventMapPoint++;
        eventEnd = true;
      }
    });
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

  /*
  Widget _buildButton() {
    return Container(
      width: 150, // Change the width to make the button twice bigger
      height: 150, // Change the height to make the button twice bigger
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey, // You can change the background color here
        boxShadow: [
          BoxShadow(
            color: Colors.black26, // You can adjust the shadow color
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // You can adjust the shadow offset
          ),
        ],
      ),
      child: _videoPlayerController.value.isInitialized
          ? ClipOval(
        child: AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio,
          child: VideoPlayer(_videoPlayerController),
        ),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

   */

  Widget _buildButton() {
    var content;

    /*
    if(lawyer != null) {
      content = CachedNetworkImage(
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(),
        errorWidget: (context, url, error) => Icon(Icons.error),
        imageUrl:lawyer.avatar,
      );
    } else {
      content = Container();
    }
     */

    try {
      if (_videoPlayerController != null) {
        content = ClipOval(
          child: AspectRatio(
            aspectRatio: _videoPlayerController.value.aspectRatio,
            child: VideoPlayer(_videoPlayerController),
          ),
        );
      } else {
        content = CircularProgressIndicator();
      }
    } catch (error, stackTrace) {
      content = Container();
    }

    return Container(
      width: 180,
      height: 180,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.transparent, // Use transparent color for the outer container
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 0,
            blurRadius: 2,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer Transparent Container
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey,
            ),
            child: content, // Your original content
          ),
          // Left Icon

          Positioned(
            left: -5, // Adjust the position as needed
            child: GestureDetector(
              onTap: () {
                switchLawyer();
              },
              child: Icon(
                Icons.arrow_back,
                size: 30, // Adjust the icon size as needed
                color: Colors.white, // Change the color of the icon as needed
              ),
            ),
          ),
          // Right Icon

          Positioned(
            right: -5, // Adjust the position as needed
            child: GestureDetector(
              onTap: () {
                switchLawyer();
              },
              child: Icon(
                Icons.arrow_forward,
                size: 30, // Adjust the icon size as needed
                color: Colors.white, // Change the color of the icon as needed
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return Container(
        color: $styles.colors.white,
        child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, snapshot) {
                      return Stack(
                        children: [
                          //_TopContent(),
                          _EventsList(key: _eventsListKey, data: eventMap),

                          Positioned(
                              left: _offset.dx,
                              top: _offset.dy,
                              child: Stack(children: [
                                Draggable(
                                  onDragEnd: (details) {
                                    setState(() {
                                      _offset = details.offset;
                                      _isDragging = true;
                                    });
                                  },
                                  feedback: _buildButton(),
                                  childWhenDragging: Container(),
                                  child: GestureDetector(
                                    onTapDown: (_) {
                                      _isDragging = false;
                                    },
                                    onTapUp: (_) {
                                      _isDragging = false;
                                    },
                                    child: _buildButton(),
                                    /*
                                        child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => Container(),
                                          errorWidget: (context, url, error) => Icon(Icons.error),
                                          imageUrl:lawyer.avatar,
                                        ),
                                         */
                                  ),
                                ),
                              ])),
                        ],
                      );
                    },
                  ),
                ),
                Container(
                  height: keyboardHeight / 2 + 60, // or 312 Adjust the height according to your needs
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
