import 'package:wonders/common_libs.dart';
import 'package:wonders/logic/common/string_utils.dart';
import 'package:wonders/logic/data/wonder_data.dart';
import 'package:wonders/ui/common/app_icons.dart';
import 'dart:io';
import 'package:wonders/ui/common/controls/app_page_indicator.dart';
import 'package:wonders/ui/common/gradient_container.dart';
import 'package:wonders/ui/common/themed_text.dart';
import 'package:wonders/ui/common/utils/app_haptics.dart';
import 'package:camera/camera.dart' as cam;
//import 'package:wonders/ui/common/modals/camera_recorder.dart';
import 'package:wonders/ui/common/modals/video_recorder.dart';
import 'package:wonders/ui/screens/home_menu/home_menu.dart';
import 'package:wonders/ui/wonder_illustrations/common/animated_clouds.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_illustration.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_illustration_config.dart';
import 'package:wonders/ui/wonder_illustrations/common/wonder_title_text.dart';
import 'package:wonders/ui/common/app_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wonders/ui/common/controls/simple_header.dart';
//import 'package:amplify_flutter/amplify_flutter.dart';
//import 'package:amplify_storage_s3/amplify_storage_s3.dart';
//import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
//import 'package:amplify_storage_s3/method_channel_storage_s3.dart';
import 'package:wonders/amplifyconfiguration.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path/path.dart' as path;

part '_vertical_swipe_controller.dart';
part 'widgets/_animated_arrow_button.dart';
part 'widgets/_entry_input.dart';

class UploadScreen extends StatefulWidget with GetItStatefulWidgetMixin {
  UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

/// Shows a horizontally scrollable list PageView sandwiched between Foreground and Background layers
/// arranged in a parallax style.
class _UploadScreenState extends State<UploadScreen> with SingleTickerProviderStateMixin {
  late final _pageController = PageController(
    viewportFraction: 1,
    initialPage: _numWonders * 9999, // allow 'infinite' scrolling by starting at a very high page
  );
  //late final WonderData wonder = wondersLogic.getData(widget.type);

  List<WonderData> get _wonders => wondersLogic.all;
  bool _isMenuOpen = false;

  /// Set initial wonderIndex
  late int _wonderIndex = 0;
  int get _numWonders => _wonders.length;

  /// Used to polish the transition when leaving this page for the details view.
  /// Used to capture the _swipeAmt at the time of transition, and freeze the wonder foreground in place as we transition away.
  double? _swipeOverride;

  /// Used to let the foreground fade in when this view is returned to (from details)
  bool _fadeInOnNextBuild = false;

  /// All of the items that should fade in when returning from details view.
  /// Using individual tweens is more efficient than tween the entire parent
  final _fadeAnims = <AnimationController>[];

  WonderData get currentWonder => _wonders[_wonderIndex];

  late final _VerticalSwipeController _swipeController = _VerticalSwipeController(this, _showDetailsPage);

  bool _isSelected(WonderType t) => t == currentWonder.type;
  bool isAmplifyConfigured = false;

  @override
  void initState() {
    print("---init---");
    //setAmplify();
  }
/*
  void setAmplify() async {
    await configureAmplify();
  }
  Future configureAmplify() async {
    try {
      await Amplify.addPlugins([AmplifyAuthCognito(), AmplifyStorageS3()]);
      await Amplify.configure(amplifyconfig);
    } on AmplifyAlreadyConfiguredException {
      print(
          'Amplify was already configured. Looks like app restarted on android.');
    }

    //notifyListeners();
    isAmplifyConfigured = true;
  }

 */

  @override
  void deactivate() {
    print("--2-deactivated--");
    super.deactivate();
  }

  void _setPageIndex(int index) {
    if (index == _wonderIndex) return;
    // To support infinite scrolling, we can't jump directly to the pressed index. Instead, make it relative to our current position.
    final pos = ((_pageController.page ?? 0) / _numWonders).floor() * _numWonders;
    _pageController.jumpToPage(pos + index);
  }

  void _showDetailsPage() async {
    /*
        _swipeOverride = _swipeController.swipeAmt.value;
        context.push(ScreenPaths.wonderDetails(currentWonder.type));
        debugPrint(ScreenPaths.wonderDetails(currentWonder.type));
        await Future.delayed(100.ms);
        _swipeOverride = null;
        _fadeInOnNextBuild = true;
    */
  }

  void _startDelayedFgFade() async {
    try {
      for (var a in _fadeAnims) {
        a.value = 0;
      }
      await Future.delayed(300.ms);
      for (var a in _fadeAnims) {
        a.forward();
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_fadeInOnNextBuild == true) {
      _startDelayedFgFade();
      _fadeInOnNextBuild = false;
    }

    return _swipeController.wrapGestureDetector(Container(
      color: $styles.colors.black,
      child: Stack(
        children: [
          Stack(
            children: [
              /// Background
              ..._buildBgAndClouds(),

              /// Controls that float on top of the various illustrations
              _buildFloatingUi(),

            ],
          ).animate().fadeIn(),

          BackBtn().safe(),
        ],

      ),
    ));
  }

  List<Widget> _buildBgAndClouds() {
    return [
      // Background
      ..._wonders.map((e) {
        final config = WonderIllustrationConfig.bg(isShowing: _isSelected(e.type));
        return WonderIllustration(e.type, config: config);
      }).toList(),
      // Clouds
      FractionallySizedBox(
        widthFactor: 1,
        heightFactor: .5,
        child: AnimatedClouds(wonderType: currentWonder.type, opacity: 1),
      )
    ];
  }

  void _handleSearchSubmitted(String query) {
    print("##111");
  }

  Widget _buildFloatingUi() {
    return Stack(children: [

      /// Floating controls / UI
      AnimatedSwitcher(
        duration: $styles.times.fast,
        /*
        child: Row(
          children: <Widget>[
            Text('Begin', style:TextStyle(
              color:Colors.red,
            )),
            //Spacer(), // Defaults to a flex of one.
            Text('Middle'),
            // Gives twice the space between Middle and End than Begin and Middle.
            //Spacer(flex: 2),
            Text('End'),
          ],
        ),
        */

        child: RepaintBoundary(
          child: OverflowBox(
            child: Column(
              mainAxisSize: MainAxisSize.min,

/*
              children: <Widget>[
                Text('Begin', style:TextStyle(
                  color:Colors.red,
                )),
                Spacer(), // Defaults to a flex of one.
                Text('Middle', style:TextStyle(
                  color:Colors.red,
                )),
                // Gives twice the space between Middle and End than Begin and Middle.
                Spacer(flex: 2),
                Text('End', style:TextStyle(
                  color:Colors.red,
                )),
              ],
*/

              children: [
                //SizedBox(width: double.infinity),
                //const Spacer(),
                /// Title Content
                LightText(
                    child: Transform.translate(
                      offset: Offset(0, -100),
                      child: Column(
                        children: [
                          Semantics(
                            // Hide the title when the menu is open for visual polish
                            child: AnimatedOpacity(
                              opacity: _isMenuOpen ? 0 : 1,
                              duration: $styles.times.fast,
                              child: WonderTitleText("ttt5", enableShadows: true),
                            ),
                          ),

                          Gap($styles.insets.md),

                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: $styles.insets.sm),
                            child: _EntryInput(onSubmit: _handleSearchSubmitted),
                          ),

                        ],
                      ),
                    ),
                ),
                //Gap($styles.insets.md),

              ],
            ),
          ),
        ),


      ),


    ]);
  }
}
