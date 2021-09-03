import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'page.dart';

/// The NavigatorObserver to listen route change
class FFNavigatorObserver extends NavigatorObserver {
  FFNavigatorObserver({this.routeChange});

  final RouteChange? routeChange;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _didRouteChange(previousRoute, route);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _didRouteChange(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _didRouteChange(previousRoute, route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _didRouteChange(newRoute, oldRoute);
  }

  void _didRouteChange(Route<dynamic>? newRoute, Route<dynamic>? oldRoute) {
    // oldRoute may be null when route first time enter.
    routeChange?.call(newRoute, oldRoute);
  }
}

/// Route change call back
/// [FFNavigatorObserver.routeChange]
typedef RouteChange = void Function(
    Route<dynamic>? newRoute, Route<dynamic>? oldRoute);

/// Transparent Page Route
class FFTransparentPageRoute<T> extends PageRouteBuilder<T> {
  FFTransparentPageRoute({
    RouteSettings? settings,
    required RoutePageBuilder pageBuilder,
    RouteTransitionsBuilder transitionsBuilder = _defaultTransitionsBuilder,
    Duration transitionDuration = const Duration(milliseconds: 150),
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
    bool maintainState = true,
  }) : super(
          settings: settings,
          opaque: false,
          pageBuilder: pageBuilder,
          transitionsBuilder: transitionsBuilder,
          transitionDuration: transitionDuration,
          barrierDismissible: barrierDismissible,
          barrierColor: barrierColor,
          barrierLabel: barrierLabel,
          maintainState: maintainState,
        );
}

Widget _defaultTransitionsBuilder(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    ),
    child: child,
  );
}

/// onGenerateRoute for Navigator 1.0
Route<dynamic> onGenerateRoute({
  required RouteSettings settings,
  required GetRouteSettings getRouteSettings,
  Widget? notFoundWidget,
  Map<String, dynamic>? arguments,
  RouteSettingsWrapper? routeSettingsWrapper,
}) {
  arguments ??= settings.arguments as Map<String, dynamic>?;

  FFRouteSettings routeSettings = getRouteSettings(
    name: settings.name!,
    arguments: arguments,
  );

  if (routeSettingsWrapper != null) {
    routeSettings = routeSettingsWrapper(routeSettings);
  }
  final Widget? page = routeSettings.widget ?? notFoundWidget;
  if (page == null) {
    throw Exception(
      '''Route "${settings.name}" returned null. Route Widget must never return null,
          maybe the reason is that route name did not match with right path.
          You can use parameter[notFoundFallback] to avoid this ugly error.''',
    );
  }

  if (routeSettings.widget == null) {
    routeSettings = routeSettings.copyWith(widget: page);
  }

  return routeSettings.createRoute();
}

/// [onGenerateRoute], re-define FFRouteSettings in this call back
typedef RouteSettingsWrapper = FFRouteSettings Function(
    FFRouteSettings pageRoute);

/// [FFRouterDelegate.pageWrapper], re-define FFPage in this call back
typedef PageWrapper = FFPage<T> Function<T>(FFPage<T> pageRoute);

/// The getRouteSettings method which is created by [ff_annotation_route]
typedef GetRouteSettings = FFRouteSettings Function({
  required String name,
  Map<String, dynamic>? arguments,
  Widget? notFoundWidget,
});
