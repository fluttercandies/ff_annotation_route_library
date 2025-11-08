import 'package:flutter/widgets.dart';

import 'extended_route_aware.dart';
import 'extended_route_observer.dart';

/// RouteLifecycleMixin
///
/// Lightweight mixin you can apply to any `State<T>` to receive hooks for:
///  * Page visibility (page vs. non-page route differentiation)
///  * Route visibility (push / pop / obscured by another route)
///  * App foreground / background transitions (only when the route is current)
///
/// It internally subscribes to a globally configurable `BaseRouteObserver`
/// instance exposed via `RouteObserverHolder.observer`. Applications may swap
/// this observer before `runApp()` to implement custom route tracking.
///
/// Example:
/// ```dart
/// class _DetailState extends State<DetailPage> with RouteLifecycleMixin<DetailPage> {
///   @override
///   void onPageShow() => debugPrint('DetailPage visible');
///   @override
///   void onForeground() => debugPrint('DetailPage resumed with app');
/// }
/// ```
///
/// Override only the callbacks you care about; empty defaults avoid boilerplate.
mixin RouteLifecycleMixin<T extends StatefulWidget> on State<T> {
  ModalRoute<dynamic>? _modalRoute;
  PageRoute<dynamic>? _pageRoute;
  bool get isPage => _pageRoute != null;
  ModalRoute<dynamic>? get modalRoute => _modalRoute;
  PageRoute<dynamic>? get pageRoute => _pageRoute;

  late final _RouteLifecycleHelper _lifecycleHelper =
      _RouteLifecycleHelper(this);

  @override
  void initState() {
    super.initState();
    _lifecycleHelper.init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _modalRoute = ModalRoute.of(context);
    if (_modalRoute is PageRoute) {
      _pageRoute = _modalRoute as PageRoute<dynamic>;
    } else {
      _pageRoute = null;
    }
    _lifecycleHelper.subscribe(_modalRoute);
  }

  @override
  void dispose() {
    _lifecycleHelper.dispose();
    super.dispose();
  }

  /// Called when current page is shown.
  void onPageShow() {}

  /// Called when current page is hide.
  void onPageHide() {}

  /// Called when current route is shown.
  void onRouteShow() {}

  ///  Called when current route is hide.
  void onRouteHide() {}

  /// Called when the app is going into foreground.
  void onForeground() {}

  /// Called when the app is going into background.
  void onBackground() {}
}

/// Internal helper bridging Flutter's `RouteAware` & `WidgetsBindingObserver`
/// protocols to the external callback surface exposed by `RouteLifecycleMixin`.
/// Not part of the public API.
class _RouteLifecycleHelper with ExtendedRouteAware, WidgetsBindingObserver {
  _RouteLifecycleHelper(this._state);

  final RouteLifecycleMixin _state;
  ModalRoute<dynamic>? _modalRoute;

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void subscribe(ModalRoute<dynamic>? modalRoute) {
    if (modalRoute != null) {
      _modalRoute = modalRoute;
      RouteObserverHolder.observer.subscribe(this, modalRoute);
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_modalRoute != null) {
      RouteObserverHolder.observer.unsubscribe(this);
    }
  }

  @override
  void onPageShow() {
    _state.onPageShow();
  }

  @override
  void onPageHide() {
    _state.onPageHide();
  }

  @override
  void onRouteShow() {
    _state.onRouteShow();
  }

  @override
  void onRouteHide() {
    _state.onRouteHide();
  }

  // WidgetsBindingObserver
  @override
  void didChangeAppLifecycleState(AppLifecycleState state_) {
    if (_state._modalRoute?.isCurrent == true) {
      if (state_ == AppLifecycleState.resumed) {
        _state.onForeground();
      } else if (state_ == AppLifecycleState.paused) {
        _state.onBackground();
      }
    }
  }

  @override
  bool get isPage => _state.isPage;
}

/// Deprecated style convenience base class; prefer the mixin directly.
/// Keeping for backwards compatibility.
abstract class RouteLifecycleState<T extends StatefulWidget> extends State<T>
    with RouteLifecycleMixin<T> {}
