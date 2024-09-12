import 'package:flutter/widgets.dart';

abstract class ExtendedRouteAware implements RouteAware {
  bool get isPage;

  /// Called when the app is going into foreground.
  void onForeground() {}

  /// Called when the app is going into background.
  void onBackground() {}

  /// Called when current page is shown.
  void onPageShow() {}

  ///  Called when current page is hide.
  void onPageHide() {}

  /// Called when current route is shown.
  void onRouteShow() {}

  ///  Called when current route is hide.
  void onRouteHide() {}

  /// Called when the top route has been popped off, and the current route
  /// shows up.
  @override
  void didPopNext() {
    if (isPage) {
      onPageShow();
    }
    onRouteShow();
  }

  /// Called when the current route has been pushed.
  @override
  void didPush() {
    if (isPage) {
      onPageShow();
    }
    onRouteShow();
  }

  /// Called when the current route has been popped off.
  @override
  void didPop() {
    if (isPage) {
      onPageHide();
    }
    onRouteHide();
  }

  /// Called when a new route has been pushed, and the current route is no
  /// longer visible.
  @override
  void didPushNext() {
    if (isPage) {
      onPageHide();
    }
    onRouteHide();
  }
}
