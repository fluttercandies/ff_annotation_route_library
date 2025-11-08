import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'page.dart';

/// The NavigatorObserver to listen route change
/// FFNavigatorObserver
///
/// Lightweight observer that forwards route transition events through a
/// single callback (`routeChange`). Useful for analytics or debugging.
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
  Route<dynamic>? newRoute,
  Route<dynamic>? oldRoute,
);

/// Transparent Page Route
/// A `PageRoute` that renders transparently (non-opaque) with a fade
/// transition. Useful for overlays or dialogs that should not fully obscure
/// underlying content.
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
  Map<String, dynamic>? arguments,
  RouteSettingsWrapper? routeSettingsWrapper,
  PageBuilder? notFoundPageBuilder,
  FFErrorWidgetBuilder? errorWidgetBuilder,
}) {
  FFRouteSettings? routeSettings;

  try {
    arguments ??= settings.arguments as Map<String, dynamic>?;

    routeSettings = getRouteSettings(
      name: settings.name!,
      arguments: arguments,
    );

    if (routeSettingsWrapper != null) {
      routeSettings = routeSettingsWrapper(routeSettings);
    }
    if (notFoundPageBuilder != null &&
        routeSettings.name == FFRoute.notFoundName) {
      routeSettings = routeSettings.copyWith(builder: notFoundPageBuilder);
    }

    return routeSettings.createRoute(errorWidgetBuilder: errorWidgetBuilder);
  } catch (e, s) {
    if (errorWidgetBuilder != null) {
      return FFRouteSettings.createRouteFromBuilder(
        pageBuilder: () => Builder(
          builder: (context) => errorWidgetBuilder(context, e, s),
        ),
        pageRouteType: routeSettings?.pageRouteType,
        settings: settings,
        errorWidgetBuilder: errorWidgetBuilder,
      );
    }
    rethrow;
  }
}

/// [onGenerateRoute], re-define FFRouteSettings in this call back
typedef RouteSettingsWrapper = FFRouteSettings Function(
  FFRouteSettings pageRoute,
);

/// [FFRouterDelegate.pageWrapper], re-define FFPage in this call back
typedef PageWrapper = FFPage<T> Function<T>(FFPage<T> pageRoute);

/// The getRouteSettings method which is created by [ff_annotation_route]
typedef GetRouteSettings = FFRouteSettings Function({
  required String name,
  Map<String, dynamic>? arguments,
  PageBuilder? notFoundPageBuilder,
});
