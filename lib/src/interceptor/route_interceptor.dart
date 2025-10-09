import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';

/// Manages route interceptors globally and per route basis.
class RouteInterceptorManager {
  factory RouteInterceptorManager() => _routeInterceptors;

  RouteInterceptorManager._();

  static final RouteInterceptorManager _routeInterceptors =
      RouteInterceptorManager._();

  // Global interceptors, applied to all routes.
  final List<RouteInterceptor> _interceptors = <RouteInterceptor>[];

  // Route-specific interceptors mapped by route name.
  final Map<String, List<RouteInterceptor>> _interceptorMap =
      <String, List<RouteInterceptor>>{};

  /// Adds a global interceptor to be applied to all routes.
  void addGlobalInterceptor(RouteInterceptor interceptor) {
    _interceptors.add(interceptor);
  }

  /// Adds a list of global interceptors to be applied to all routes.
  void addGlobalInterceptors(List<RouteInterceptor> interceptors) {
    _interceptors.addAll(interceptors);
  }

  /// Adds interceptors for a specific route by its name.
  void addRouteInterceptors(
    String routeName,
    List<RouteInterceptor> interceptors,
  ) {
    _interceptorMap[routeName] = interceptors;
  }

  /// Merges another map of route-specific interceptors.
  void addAllRouteInterceptors(
    Map<String, List<RouteInterceptor>> interceptorsMap,
  ) {
    _interceptorMap.addAll(interceptorsMap);
  }

  /// Removes a global interceptor.
  void removeGlobalInterceptor(RouteInterceptor interceptor) {
    _interceptors.remove(interceptor);
  }

  /// Removes all interceptors for a specific route by its name.
  void removeRouteInterceptors(String routeName) {
    _interceptorMap.remove(routeName);
  }

  /// Clears all global interceptors.
  void clearGlobalInterceptors() {
    _interceptors.clear();
  }

  /// Clears all route-specific interceptors.
  void clearRouteInterceptors() {
    _interceptorMap.clear();
  }

  /// Runs the interceptors, starting with route-specific ones (if any)
  /// and falling back to global interceptors.
  /// Returns a [RouteInterceptResult] that includes the action taken by the interceptor.
  Future<RouteInterceptResult> intercept(
    String routeName, {
    Object? arguments,
  }) async {
    // If no route-specific interceptors are found, use global interceptors.
    final List<RouteInterceptor> interceptors =
        _interceptorMap[routeName] ??= _interceptors;

    RouteInterceptResult routeInterceptResult = RouteInterceptResult(
      action: RouteInterceptAction.complete,
      routeName: routeName,
      arguments: arguments,
    );

    // Execute each interceptor in the chain.
    for (final RouteInterceptor interceptor in interceptors) {
      routeInterceptResult = await interceptor.intercept(
        routeName,
        arguments: arguments,
      );

      // If the interceptor returns anything other than 'next', break the chain.
      if (routeInterceptResult.action != RouteInterceptAction.next) {
        return routeInterceptResult;
      }

      // Update the name and arguments for the next interceptor.
      routeName = routeInterceptResult.routeName;
      arguments = routeInterceptResult.arguments;
    }

    return routeInterceptResult;
  }
}
