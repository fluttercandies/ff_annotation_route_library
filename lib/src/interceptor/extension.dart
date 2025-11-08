import 'dart:async';

import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/widgets.dart';

import 'route_interceptor.dart';

/// NavigatorState extension adding `*WithInterceptor` variants of common
/// navigation methods. Each variant runs the registered interceptor chain
/// before delegating to the underlying Navigator API. If an interceptor
/// returns `abort`, navigation is cancelled. If it rewrites the route name /
/// arguments, the mutated values are used.
extension NavigatorWithInterceptorExtension on NavigatorState {
  /// Internal helper invoking the manager; returns null if aborted.
  Future<RouteInterceptResult?> _intercept(
    String routeName, {
    Object? arguments,
  }) async {
    final RouteInterceptResult result =
        await RouteInterceptorManager().intercept(
      routeName,
      arguments: arguments,
    );
    if (result.action == RouteInterceptAction.abort) {
      return null;
    }

    return result;
  }

  /// Push a named route onto the navigator that most tightly encloses the given
  /// context.
  ///
  /// {@template flutter.widgets.navigator.pushNamed}
  /// The route name will be passed to the [Navigator.onGenerateRoute]
  /// callback. The returned route will be pushed into the navigator.
  ///
  /// The new route and the previous route (if any) are notified (see
  /// [Route.didPush] and [Route.didChangeNext]). If the [Navigator] has any
  /// [Navigator.observers], they will be notified as well (see
  /// [NavigatorObserver.didPush]).
  ///
  /// Ongoing gestures within the current route are canceled when a new route is
  /// pushed.
  ///
  /// Returns a [Future] that completes to the `result` value passed to [pop]
  /// when the pushed route is popped off the navigator.
  ///
  /// The `T` type argument is the type of the return value of the route.
  ///
  /// To use [pushNamed], an [Navigator.onGenerateRoute] callback must be
  /// provided,
  /// {@endtemplate}
  ///
  /// {@template flutter.widgets.Navigator.pushNamed}
  /// The provided `arguments` are passed to the pushed route via
  /// [RouteSettings.arguments]. Any object can be passed as `arguments` (e.g. a
  /// [String], [int], or an instance of a custom `MyRouteArguments` class).
  /// Often, a [Map] is used to pass key-value pairs.
  ///
  /// The `arguments` may be used in [Navigator.onGenerateRoute] or
  /// [Navigator.onUnknownRoute] to construct the route.
  /// {@endtemplate}
  ///
  /// {@tool snippet}
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// void _didPushButton() {
  ///   Navigator.pushNamed(context, '/settings');
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// {@tool snippet}
  ///
  /// The following example shows how to pass additional `arguments` to the
  /// route:
  ///
  /// ```dart
  /// void _showBerlinWeather() {
  ///   Navigator.pushNamed(
  ///     context,
  ///     '/weather',
  ///     arguments: <String, String>{
  ///       'city': 'Berlin',
  ///       'country': 'Germany',
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// {@tool snippet}
  ///
  /// The following example shows how to pass a custom Object to the route:
  ///
  /// ```dart
  /// class WeatherRouteArguments {
  ///   WeatherRouteArguments({ required this.city, required this.country });
  ///   final String city;
  ///   final String country;
  ///
  ///   bool get isGermanCapital {
  ///     return country == 'Germany' && city == 'Berlin';
  ///   }
  /// }
  ///
  /// void _showWeather() {
  ///   Navigator.pushNamed(
  ///     context,
  ///     '/weather',
  ///     arguments: WeatherRouteArguments(city: 'Berlin', country: 'Germany'),
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [restorablePushNamed], which pushes a route that can be restored
  ///    during state restoration.
  Future<T?> pushNamedWithInterceptor<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    final RouteInterceptResult? result =
        await _intercept(routeName, arguments: arguments);
    if (result == null) {
      return null;
    }

    return pushNamed<T>(result.routeName, arguments: result.arguments);
  }

  /// Push a named route onto the navigator that most tightly encloses the given
  /// context.
  ///
  /// {@template flutter.widgets.navigator.restorablePushNamed}
  /// Unlike [Route]s pushed via [pushNamed], [Route]s pushed with this method
  /// are restored during state restoration according to the rules outlined
  /// in the "State Restoration" section of [Navigator].
  /// {@endtemplate}
  ///
  /// {@macro flutter.widgets.navigator.pushNamed}
  ///
  /// {@template flutter.widgets.Navigator.restorablePushNamed.arguments}
  /// The provided `arguments` are passed to the pushed route via
  /// [RouteSettings.arguments]. Any object that is serializable via the
  /// [StandardMessageCodec] can be passed as `arguments`. Often, a Map is used
  /// to pass key-value pairs.
  ///
  /// The arguments may be used in [Navigator.onGenerateRoute] or
  /// [Navigator.onUnknownRoute] to construct the route.
  /// {@endtemplate}
  ///
  /// {@template flutter.widgets.Navigator.restorablePushNamed.returnValue}
  /// The method returns an opaque ID for the pushed route that can be used by
  /// the [RestorableRouteFuture] to gain access to the actual [Route] object
  /// added to the navigator and its return value. You can ignore the return
  /// value of this method, if you do not care about the route object or the
  /// route's return value.
  /// {@endtemplate}
  ///
  /// {@tool snippet}
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// void _showParisWeather() {
  ///   Navigator.restorablePushNamed(
  ///     context,
  ///     '/weather',
  ///     arguments: <String, String>{
  ///       'city': 'Paris',
  ///       'country': 'France',
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  @optionalTypeArgs
  Future<String> restorablePushNamedWithInterceptor<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    final RouteInterceptResult? result =
        await _intercept(routeName, arguments: arguments);
    if (result == null) {
      return '';
    }

    return restorablePushNamed<T>(
      result.routeName,
      arguments: result.arguments,
    );
  }

  /// Replace the current route of the navigator that most tightly encloses the
  /// given context by pushing the route named [routeName] and then disposing
  /// the previous route once the new route has finished animating in.
  ///
  /// {@template flutter.widgets.navigator.pushReplacementNamed}
  /// If non-null, `result` will be used as the result of the route that is
  /// removed; the future that had been returned from pushing that old route
  /// will complete with `result`. Routes such as dialogs or popup menus
  /// typically use this mechanism to return the value selected by the user to
  /// the widget that created their route. The type of `result`, if provided,
  /// must match the type argument of the class of the old route (`TO`).
  ///
  /// The route name will be passed to the [Navigator.onGenerateRoute]
  /// callback. The returned route will be pushed into the navigator.
  ///
  /// The new route and the route below the removed route are notified (see
  /// [Route.didPush] and [Route.didChangeNext]). If the [Navigator] has any
  /// [Navigator.observers], they will be notified as well (see
  /// [NavigatorObserver.didReplace]). The removed route is notified once the
  /// new route has finished animating (see [Route.didComplete]). The removed
  /// route's exit animation is not run (see [popAndPushNamed] for a variant
  /// that does animated the removed route).
  ///
  /// Ongoing gestures within the current route are canceled when a new route is
  /// pushed.
  ///
  /// Returns a [Future] that completes to the `result` value passed to [pop]
  /// when the pushed route is popped off the navigator.
  ///
  /// The `T` type argument is the type of the return value of the new route,
  /// and `TO` is the type of the return value of the old route.
  ///
  /// To use [pushReplacementNamed], a [Navigator.onGenerateRoute] callback must
  /// be provided.
  /// {@endtemplate}
  ///
  /// {@macro flutter.widgets.Navigator.pushNamed}
  ///
  /// {@tool snippet}
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// void _switchToBrightness() {
  ///   Navigator.pushReplacementNamed(context, '/settings/brightness');
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [restorablePushReplacementNamed], which pushes a replacement route that
  ///    can be restored during state restoration.
  @optionalTypeArgs
  Future<T?> pushReplacementNamedWithInterceptor<T extends Object?,
      TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    final RouteInterceptResult? routeInterceptResult = await _intercept(
      routeName,
      arguments: arguments,
    );
    if (routeInterceptResult == null) {
      return null;
    }
    return pushReplacementNamed<T, TO>(
      routeInterceptResult.routeName,
      arguments: routeInterceptResult.arguments,
      result: result,
    );
  }

  /// Replace the current route of the navigator that most tightly encloses the
  /// given context by pushing the route named [routeName] and then disposing
  /// the previous route once the new route has finished animating in.
  ///
  /// {@template flutter.widgets.navigator.restorablePushReplacementNamed}
  /// Unlike [Route]s pushed via [pushReplacementNamed], [Route]s pushed with
  /// this method are restored during state restoration according to the rules
  /// outlined in the "State Restoration" section of [Navigator].
  /// {@endtemplate}
  ///
  /// {@macro flutter.widgets.navigator.pushReplacementNamed}
  ///
  /// {@macro flutter.widgets.Navigator.restorablePushNamed.arguments}
  ///
  /// {@macro flutter.widgets.Navigator.restorablePushNamed.returnValue}
  ///
  /// {@tool snippet}
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// void _switchToAudioVolume() {
  ///   Navigator.restorablePushReplacementNamed(context, '/settings/volume');
  /// }
  /// ```
  /// {@end-tool}
  @optionalTypeArgs
  Future<String> restorablePushReplacementNamedWithInterceptor<
      T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    final RouteInterceptResult? routeInterceptResult =
        await _intercept(routeName, arguments: arguments);
    if (routeInterceptResult == null) {
      return '';
    }

    return restorablePushReplacementNamed<T, TO>(
      routeInterceptResult.routeName,
      arguments: routeInterceptResult.arguments,
      result: result,
    );
  }

  /// Pop the current route off the navigator that most tightly encloses the
  /// given context and push a named route in its place.
  ///
  /// {@template flutter.widgets.navigator.popAndPushNamed}
  /// The popping of the previous route is handled as per [pop].
  ///
  /// The new route's name will be passed to the [Navigator.onGenerateRoute]
  /// callback. The returned route will be pushed into the navigator.
  ///
  /// The new route, the old route, and the route below the old route (if any)
  /// are all notified (see [Route.didPop], [Route.didComplete],
  /// [Route.didPopNext], [Route.didPush], and [Route.didChangeNext]). If the
  /// [Navigator] has any [Navigator.observers], they will be notified as well
  /// (see [NavigatorObserver.didPop] and [NavigatorObserver.didPush]). The
  /// animations for the pop and the push are performed simultaneously, so the
  /// route below may be briefly visible even if both the old route and the new
  /// route are opaque (see [TransitionRoute.opaque]).
  ///
  /// Ongoing gestures within the current route are canceled when a new route is
  /// pushed.
  ///
  /// Returns a [Future] that completes to the `result` value passed to [pop]
  /// when the pushed route is popped off the navigator.
  ///
  /// The `T` type argument is the type of the return value of the new route,
  /// and `TO` is the return value type of the old route.
  ///
  /// To use [popAndPushNamed], a [Navigator.onGenerateRoute] callback must be provided.
  ///
  /// {@endtemplate}
  ///
  /// {@macro flutter.widgets.Navigator.pushNamed}
  ///
  /// {@tool snippet}
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// void _selectAccessibility() {
  ///   Navigator.popAndPushNamed(context, '/settings/accessibility');
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [restorablePopAndPushNamed], which pushes a new route that can be
  ///    restored during state restoration.
  @optionalTypeArgs
  Future<T?>
      popAndPushNamedWithInterceptor<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    final RouteInterceptResult? routeInterceptResult = await _intercept(
      routeName,
      arguments: arguments,
    );
    if (routeInterceptResult == null) {
      return null;
    }
    return popAndPushNamed<T, TO>(
      routeInterceptResult.routeName,
      arguments: routeInterceptResult.arguments,
      result: result,
    );
  }

  /// Pop the current route off the navigator that most tightly encloses the
  /// given context and push a named route in its place.
  ///
  /// {@template flutter.widgets.navigator.restorablePopAndPushNamed}
  /// Unlike [Route]s pushed via [popAndPushNamed], [Route]s pushed with
  /// this method are restored during state restoration according to the rules
  /// outlined in the "State Restoration" section of [Navigator].
  /// {@endtemplate}
  ///
  /// {@macro flutter.widgets.navigator.popAndPushNamed}
  ///
  /// {@macro flutter.widgets.Navigator.restorablePushNamed.arguments}
  ///
  /// {@macro flutter.widgets.Navigator.restorablePushNamed.returnValue}
  ///
  /// {@tool snippet}
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// void _selectNetwork() {
  ///   Navigator.restorablePopAndPushNamed(context, '/settings/network');
  /// }
  /// ```
  /// {@end-tool}
  @optionalTypeArgs
  Future<String> restorablePopAndPushNamedWithInterceptor<T extends Object?,
      TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    final RouteInterceptResult? routeInterceptResult =
        await _intercept(routeName, arguments: arguments);
    if (routeInterceptResult == null) {
      return '';
    }

    return restorablePopAndPushNamed<T, TO>(
      routeInterceptResult.routeName,
      arguments: routeInterceptResult.arguments,
      result: result,
    );
  }

  /// Push the route with the given name onto the navigator that most tightly
  /// encloses the given context, and then remove all the previous routes until
  /// the `predicate` returns true.
  ///
  /// {@template flutter.widgets.navigator.pushNamedAndRemoveUntil}
  /// The predicate may be applied to the same route more than once if
  /// [Route.willHandlePopInternally] is true.
  ///
  /// To remove routes until a route with a certain name, use the
  /// [RoutePredicate] returned from [ModalRoute.withName].
  ///
  /// To remove all the routes below the pushed route, use a [RoutePredicate]
  /// that always returns false (e.g. `(Route<dynamic> route) => false`).
  ///
  /// The removed routes are removed without being completed, so this method
  /// does not take a return value argument.
  ///
  /// The new route's name (`routeName`) will be passed to the
  /// [Navigator.onGenerateRoute] callback. The returned route will be pushed
  /// into the navigator.
  ///
  /// The new route and the route below the bottommost removed route (which
  /// becomes the route below the new route) are notified (see [Route.didPush]
  /// and [Route.didChangeNext]). If the [Navigator] has any
  /// [Navigator.observers], they will be notified as well (see
  /// [NavigatorObserver.didPush] and [NavigatorObserver.didRemove]). The
  /// removed routes are disposed, without being notified, once the new route
  /// has finished animating. The futures that had been returned from pushing
  /// those routes will not complete.
  ///
  /// Ongoing gestures within the current route are canceled when a new route is
  /// pushed.
  ///
  /// Returns a [Future] that completes to the `result` value passed to [pop]
  /// when the pushed route is popped off the navigator.
  ///
  /// The `T` type argument is the type of the return value of the new route.
  ///
  /// To use [pushNamedAndRemoveUntil], an [Navigator.onGenerateRoute] callback
  /// must be provided.
  /// {@endtemplate}
  ///
  /// {@macro flutter.widgets.Navigator.pushNamed}
  ///
  /// {@tool snippet}
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// void _resetToCalendar() {
  ///   Navigator.pushNamedAndRemoveUntil(context, '/calendar', ModalRoute.withName('/'));
  /// }
  /// ```
  /// {@end-tool}
  ///
  /// See also:
  ///
  ///  * [restorablePushNamedAndRemoveUntil], which pushes a new route that can
  ///    be restored during state restoration.
  @optionalTypeArgs
  Future<T?> pushNamedAndRemoveUntilWithInterceptor<T extends Object?>(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) async {
    final RouteInterceptResult? routeInterceptResult = await _intercept(
      newRouteName,
      arguments: arguments,
    );
    if (routeInterceptResult == null) {
      return null;
    }
    return pushNamedAndRemoveUntil<T>(
      routeInterceptResult.routeName,
      predicate,
      arguments: routeInterceptResult.arguments,
    );
  }

  /// Push the route with the given name onto the navigator that most tightly
  /// encloses the given context, and then remove all the previous routes until
  /// the `predicate` returns true.
  ///
  /// {@template flutter.widgets.navigator.restorablePushNamedAndRemoveUntil}
  /// Unlike [Route]s pushed via [pushNamedAndRemoveUntil], [Route]s pushed with
  /// this method are restored during state restoration according to the rules
  /// outlined in the "State Restoration" section of [Navigator].
  /// {@endtemplate}
  ///
  /// {@macro flutter.widgets.navigator.pushNamedAndRemoveUntil}
  ///
  /// {@macro flutter.widgets.Navigator.restorablePushNamed.arguments}
  ///
  /// {@macro flutter.widgets.Navigator.restorablePushNamed.returnValue}
  ///
  /// {@tool snippet}
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// void _resetToOverview() {
  ///   Navigator.restorablePushNamedAndRemoveUntil(context, '/overview', ModalRoute.withName('/'));
  /// }
  /// ```
  /// {@end-tool}
  @optionalTypeArgs
  Future<String>
      restorablePushNamedAndRemoveUntilWithInterceptor<T extends Object?>(
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) async {
    final RouteInterceptResult? routeInterceptResult =
        await _intercept(newRouteName, arguments: arguments);
    if (routeInterceptResult == null) {
      return '';
    }
    return restorablePushNamedAndRemoveUntil<T>(
      routeInterceptResult.routeName,
      predicate,
      arguments: routeInterceptResult.arguments,
    );
  }
}
