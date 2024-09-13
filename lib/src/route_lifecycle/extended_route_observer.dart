import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

/// [ExtendedRouteObserver] is a utility class that extends the functionality of
/// Flutter's built-in RouteObserver. It allows for more advanced route
/// management and tracking in the navigation stack. This class maintains
/// an internal list of active routes and provides several utility methods
/// for route inspection and manipulation.
///
/// Key features of [ExtendedRouteObserver]:
/// - Tracks all active routes in the navigation stack.
/// - Provides access to the top-most route via the `topRoute` getter.
/// - Allows checking if a specific route exists in the stack with `containsRoute()`.
/// - Enables retrieval of a route by its name using `getRouteByName()`.
/// - Notifies subscribers when a route is added or removed via `onRouteAdded` and `onRouteRemoved`.
/// - Supports custom actions when a route is added or removed via `onRouteAdd()` and `onRouteRemove()`.
///
/// This class is useful in cases where global route tracking or advanced
/// navigation behavior is needed, such as:
/// - Monitoring which routes are currently active.
/// - Handling custom navigation logic based on the current route stack.
/// - Implementing a navigation history feature or a breadcrumb-style navigator.
///
/// By leveraging this class, developers can gain better insight into and
/// control over their app's navigation state.
class ExtendedRouteObserver extends RouteObserver<Route<dynamic>> {
  // Singleton factory constructor for the ExtendedRouteObserver
  factory ExtendedRouteObserver() => _extendedRouteObserver;

  // Private named constructor
  ExtendedRouteObserver._();

  // Static instance for the singleton
  static final ExtendedRouteObserver _extendedRouteObserver =
      ExtendedRouteObserver._();

  // A list to store the routes currently in the navigation stack
  final List<Route<dynamic>> _routes = <Route<dynamic>>[];

  // Public getter to access the list of routes
  List<Route<dynamic>> get routes => _routes;

  // Public getter to access the top-most route in the stack
  Route<dynamic>? get topRoute => _routes.isNotEmpty ? _routes.last : null;

  // Notifier for route additions. External subscribers can listen for route additions.
  final ValueNotifier<Route<dynamic>?> onRouteAdded =
      ValueNotifier<Route<dynamic>?>(null);

  // Notifier for route removals. External subscribers can listen for route removals.
  final ValueNotifier<Route<dynamic>?> onRouteRemoved =
      ValueNotifier<Route<dynamic>?>(null);

  // Triggered when a new route is pushed onto the stack
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _addRoute(route); // Add the new route to the internal list
  }

  // Triggered when a route is popped off the stack
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _removeRoute(route); // Remove the route from the internal list
  }

  // Triggered when a route is removed (without being popped)
  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _removeRoute(route); // Remove the route from the internal list
  }

  // Triggered when a route is replaced by another route
  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _removeRoute(oldRoute); // Remove the old route from the internal list
    _addRoute(newRoute); // Add the new route to the internal list
  }

  // Adds a route to the internal list if it's not null
  void _addRoute(Route<dynamic>? route) {
    if (route != null) {
      _routes.add(route);
      onRouteAdd(route);
      onRouteAdded.value = route;
    }
  }

  // Removes a route from the internal list if it's not null
  void _removeRoute(Route<dynamic>? route) {
    if (route != null) {
      _routes.remove(route);
      onRouteRemove(route);
      onRouteRemoved.value = route;
    }
  }

  // Hook for custom actions when a route is added to the stack.
  // This can be overridden in subclasses to define specific behaviors.
  void onRouteAdd(Route<dynamic>? route) {}

  // Hook for custom actions when a route is removed from the stack.
  // This can be overridden in subclasses to define specific behaviors.
  void onRouteRemove(Route<dynamic>? route) {}

  // Checks if a specific route exists in the current route stack
  bool containsRoute(Route<dynamic> route) {
    return _routes.contains(route); // Returns true if the route is in the stack
  }

  // Retrieves a route by its name from the current route stack, returns null if not found
  Route<dynamic>? getRouteByName(String routeName) {
    // Searches for the first route with the matching name, or returns null if not found
    return _routes.firstWhereOrNull(
      (Route<dynamic> route) => route.settings.name == routeName,
    );
  }
}
