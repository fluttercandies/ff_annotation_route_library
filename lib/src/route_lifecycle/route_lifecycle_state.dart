import 'package:flutter/widgets.dart';

import 'extended_route_aware.dart';
import 'extended_route_observer.dart';

@optionalTypeArgs
// RouteLifecycleMixin is a mixin that provides lifecycle management for routes.
// It uses the ExtendedRouteAware mixin to monitor route changes and also observes
// the app's lifecycle events through WidgetsBindingObserver.
//
// Usage example:
// ```dart
// class MyPageState extends State<MyPage> with RouteLifecycleMixin {
//   @override
//   void onPageShow() {
//     // Called when the page is shown
//   }
// }
// ```
mixin RouteLifecycleMixin<T extends StatefulWidget> on State<T>
    implements ExtendedRouteAware, WidgetsBindingObserver {
  // Stores the current modal route (could be any route type)
  ModalRoute<dynamic>? _modalRoute;

  // Getter to access the current modal route
  ModalRoute<dynamic>? get modalRoute => _modalRoute;

  // Stores the current page route (specific to PageRoute type)
  PageRoute<dynamic>? _pageRoute;

  // Getter to access the current page route
  PageRoute<dynamic>? get pageRoute => _pageRoute;

  // Checks if the current route is a page route
  @override
  bool get isPage => _pageRoute != null;

  // Called when the state is initialized
  @override
  void initState() {
    super.initState();
    // Registers the WidgetsBindingObserver to listen for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
  }

  // Called when dependencies change, such as when the widget tree is rebuilt
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the current modal route from the context
    _modalRoute = ModalRoute.of(context);

    // If the current route is a PageRoute, cast it to PageRoute
    if (_modalRoute is PageRoute) {
      _pageRoute = _modalRoute as PageRoute<dynamic>;
    } else {
      _pageRoute = null;
    }

    // Subscribe this state to the route observer to track route changes
    ExtendedRouteObserver().subscribe(this, _modalRoute!);
  }

  // Called when the widget is disposed of
  @override
  void dispose() {
    // Remove the WidgetsBindingObserver when the state is destroyed
    WidgetsBinding.instance.removeObserver(this);

    // Unsubscribe from the route observer to stop tracking route changes
    ExtendedRouteObserver().unsubscribe(this);

    super.dispose();
  }

  // Called when the app's lifecycle state changes (e.g., app is resumed or paused)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check if this route is the current one before handling lifecycle events
    if (_modalRoute?.isCurrent == true) {
      // If the app comes to the foreground, call onForeground()
      if (state == AppLifecycleState.resumed) {
        onForeground();
      }
      // If the app goes to the background, call onBackground()
      else if (state == AppLifecycleState.paused) {
        onBackground();
      }
    }
  }

  // ExtendedRouteAware interface implementation
  @override
  void onPageShow() {}

  @override
  void onPageHide() {}

  @override
  void onForeground() {}

  @override
  void onBackground() {}
}

@optionalTypeArgs
@Deprecated(
  'Use RouteLifecycleMixin instead. This will be removed in a future version.',
)
// RouteLifecycleState is deprecated. Use RouteLifecycleMixin instead for better flexibility.
//
// Migration example:
// Before:
// ```dart
// class MyPageState extends RouteLifecycleState<MyPage> { }
// ```
//
// After:
// ```dart
// class MyPageState extends State<MyPage> with RouteLifecycleMixin { }
// ```
abstract class RouteLifecycleState<T extends StatefulWidget> extends State<T>
    with RouteLifecycleMixin<T> {}
