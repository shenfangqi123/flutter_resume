import 'package:flutter/material.dart' hide ModalBottomSheetRoute;

class PageRoutes {
  static const Duration kDefaultDuration = Duration(milliseconds: 300);

  static Route<T> dialog<T>(Widget child, [Duration duration = kDefaultDuration, bool opaque = false]) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      opaque: opaque,
      fullscreenDialog: true,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }

  static Route<T> dialogHalf<T>(Widget child, [Duration duration = kDefaultDuration, bool opaque = false]) {
    return PageRouteBuilder<T>(
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      pageBuilder: (context, animation, secondaryAnimation) {
        final screenHeight = MediaQuery.of(context).size.height;
        final halfScreenHeight = screenHeight / 2.5;

        return Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            height: halfScreenHeight,
            child: child,
          ),
        );
      },
      opaque: opaque,
      fullscreenDialog: false,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
