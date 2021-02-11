import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'page.dart';

class FFNavigatorObserver extends NavigatorObserver {
  FFNavigatorObserver({this.routeChange});

  final RouteChange routeChange;

  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    _didRouteChange(previousRoute, route);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    _didRouteChange(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didRemove(route, previousRoute);
    _didRouteChange(previousRoute, route);
  }

  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _didRouteChange(newRoute, oldRoute);
  }

  void _didRouteChange(Route<dynamic> newRoute, Route<dynamic> oldRoute) {
    // oldRoute may be null when route first time enter.
    routeChange?.call(newRoute, oldRoute);
  }
}

typedef RouteChange = void Function(
    Route<dynamic> newRoute, Route<dynamic> oldRoute);

class FFTransparentPageRoute<T> extends PageRouteBuilder<T> {
  FFTransparentPageRoute({
    RouteSettings settings,
    @required RoutePageBuilder pageBuilder,
    RouteTransitionsBuilder transitionsBuilder = _defaultTransitionsBuilder,
    Duration transitionDuration = const Duration(milliseconds: 150),
    bool barrierDismissible = false,
    Color barrierColor,
    String barrierLabel,
    bool maintainState = true,
  })  : assert(pageBuilder != null),
        assert(transitionsBuilder != null),
        assert(barrierDismissible != null),
        assert(maintainState != null),
        super(
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

Route<dynamic> onGenerateRoute({
  @required
      RouteSettings settings,
  @required
      FFRouteSettings Function({
    @required String name,
    Map<String, dynamic> arguments,
  })
          getRouteSettings,
  Widget notFoundFallback,
  Map<String, dynamic> arguments,
  RouteWrapper routeWrapper,
}) {
  arguments ??= settings.arguments as Map<String, dynamic>;

  FFRouteSettings pageRoute = getRouteSettings(
    name: settings.name,
    arguments: arguments,
  );

  if (routeWrapper != null) {
    pageRoute = routeWrapper(pageRoute);
  }
  final Widget page = pageRoute.widget ?? notFoundFallback;
  if (page == null) {
    throw Exception(
      '''Route "${settings.name}" returned null. Route Widget must never return null,
          maybe the reason is that route name did not match with right path.
          You can use parameter[notFoundFallback] to avoid this ugly error.''',
    );
  }

  return pageRoute.createRoute();
}

typedef RouteWrapper = FFRouteSettings Function(FFRouteSettings pageRoute);
