import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'page.dart';
import 'route_helper.dart';

typedef NavigatorWrapper = Widget Function(Navigator navigator);

/// Signature for the [FFRouterDelegate.popUntil] predicate argument.
typedef PagePredicate = bool Function(FFPage<dynamic> page);

class FFRouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings> {
  FFRouterDelegate({
    @required this.getRouteSettings,
    this.reportsRouteUpdateToEngine = true,
    this.onPopPage,
    this.navigatorWrapper,
    this.observers,
    this.pageWrapper,
  }) : navigatorKey = GlobalKey<NavigatorState>();
  final bool reportsRouteUpdateToEngine;
  final PopPageCallback onPopPage;
  final List<FFPage<dynamic>> _pages = <FFPage<dynamic>>[];
  final NavigatorWrapper navigatorWrapper;
  final PageWrapper pageWrapper;
  final FFRouteSettings Function({
    @required String name,
    Map<String, dynamic> arguments,
  }) getRouteSettings;

  /// A list of observers for this navigator.
  final List<NavigatorObserver> observers;
  List<FFPage<dynamic>> get pages => _pages;
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  NavigatorState get navigatorState => navigatorKey?.currentState;

  static FFRouterDelegate of(BuildContext context) {
    final RouterDelegate<dynamic> delegate = Router.of(context).routerDelegate;
    assert(delegate is FFRouterDelegate, 'Delegate type must match');
    return delegate as FFRouterDelegate;
  }

  /// RootBackButtonDispatcher / ChildBackButtonDispatcher
  /// Called by the [Router] when the [Router.backButtonDispatcher] reports that
  /// the operating system is requesting that the current route be popped.
  ///
  /// The method should return a boolean [Future] to indicate whether this
  /// delegate handles the request. Returning false will cause the entire app
  /// to be popped.
  ///
  /// Consider using a [SynchronousFuture] if the result can be computed
  /// synchronously, so that the [Router] does not need to wait for the next
  /// microtask to schedule a build.
  @override
  Future<bool> popRoute() async {
    return super.popRoute();
  }

  @override
  Widget build(BuildContext context) {
    final Navigator navigator = Navigator(
      pages: pages.toList(),
      key: navigatorKey,
      reportsRouteUpdateToEngine: reportsRouteUpdateToEngine ?? kIsWeb,
      onPopPage: onPopPage ??
          (Route<dynamic> route, dynamic result) {
            if (_pages.isNotEmpty) {
              final FFPage<dynamic> removed = _pages.lastWhere(
                  (FFPage<dynamic> element) =>
                      element.name == route.settings.name);
              _pages.remove(removed);
              updatePages();
            }
            return route.didPop(result);
          },
      observers: <NavigatorObserver>[
        HeroController(),
        if (observers != null) ...observers
      ],
    );

    if (navigatorWrapper != null) {
      return navigatorWrapper(navigator);
    } else {
      return navigator;
    }
  }

  /// Called by the [Router] when the [Router.routeInformationProvider] reports that a
  /// new route has been pushed to the application by the operating system.
  ///
  /// Consider using a [SynchronousFuture] if the result can be computed
  /// synchronously, so that the [Router] does not need to wait for the next
  /// microtask to schedule a build.
  @override
  Future<void> setNewRoutePath(RouteSettings configuration) {
    _pages.add(getRoutePage(
        name: configuration.name,
        arguments: configuration.arguments as Map<String, dynamic>));
    return SynchronousFuture<void>(null);
  }

  /// Called by the [Router] when it detects a route information may have
  /// changed as a result of rebuild.
  ///
  /// If this getter returns non-null, the [Router] will start to report new
  /// route information back to the engine. In web applications, the new
  /// route information is used for populating browser history in order to
  /// support the forward and the backward buttons.
  ///
  /// When overriding this method, the configuration returned by this getter
  /// must be able to construct the current app state and build the widget
  /// with the same configuration in the [build] method if it is passed back
  /// to the the [setNewRoutePath]. Otherwise, the browser backward and forward
  /// buttons will not work properly.
  ///
  /// By default, this getter returns null, which prevents the [Router] from
  /// reporting the route information. To opt in, a subclass can override this
  /// getter to return the current configuration.
  ///
  /// At most one [Router] can opt in to route information reporting. Typically,
  /// only the top-most [Router] created by [WidgetsApp.router] should opt for
  /// route information reporting.
  @override
  RouteSettings get currentConfiguration =>
      _pages.isNotEmpty ? _pages.last : null;

  FFPage<T> getRoutePage<T extends Object>(
      {String name, Map<String, dynamic> arguments}) {
    FFPage<T> ffPage =
        getRouteSettings(name: name, arguments: arguments).toFFPage<T>(
      key: getUniqueKey(
        name: name,
        arguments: arguments,
      ),
    );
    if (pageWrapper != null) {
      ffPage = pageWrapper(ffPage);
    }
    return ffPage;
  }

  /// navigator

  /// pop
  bool canPop() => navigatorKey?.currentState?.canPop();

  void pop<T extends Object>([T result]) {
    navigatorState.pop(result);
  }

  Future<bool> maybePop<T extends Object>([T result]) {
    return navigatorState.maybePop(result);
  }

  Future<T> popAndPushNamed<T extends Object>(
    String routeName, {
    T result,
    Map<String, dynamic> arguments,
  }) {
    pop<T>(result);
    return pushNamed<T>(routeName, arguments: arguments);
  }

  void popUntil(PagePredicate predicate) {
    _popUntil(predicate);
    updatePages();
  }

  void _popUntil(PagePredicate predicate) {
    final List<FFPage<dynamic>> removed = <FFPage<dynamic>>[];
    for (int i = pages.length - 1; i >= 0; i--) {
      final FFPage<dynamic> page = pages[i];
      if (predicate(page)) {
        break;
      }
      removed.add(page);
    }
    pages.removeWhere((FFPage<dynamic> element) => removed.contains(element));
  }

  /// pop

  /// push
  Future<T> pushNamed<T extends Object>(
    String routeName, {
    Map<String, dynamic> arguments,
  }) {
    final FFPage<T> page =
        getRoutePage<T>(name: routeName, arguments: arguments);
    pages.add(page);
    updatePages();
    return page.popped;
  }

  Future<T> push<T extends Object>(
    FFPage<T> page,
  ) {
    pages.add(page);
    updatePages();
    return page.popped;
  }

  Future<T> pushAndRemoveUntil<T extends Object>(
    FFPage<T> newPage,
    PagePredicate predicate,
  ) {
    _popUntil(predicate);
    return push<T>(newPage);
  }

  Future<T> pushNamedAndRemoveUntil<T extends Object>(
    String newRouteName,
    PagePredicate predicate, {
    Map<String, dynamic> arguments,
  }) {
    _popUntil(predicate);
    return pushNamed<T>(newRouteName, arguments: arguments);
  }

  /// push

  /// navigator

  void updatePages() {
    _debugCheckDuplicatedPageKeys();
    notifyListeners();
  }

  void _debugCheckDuplicatedPageKeys() {
    assert(() {
      final Set<Key> keyReservation = <Key>{};
      for (final Page<dynamic> page in pages) {
        if (page.key != null) {
          assert(!keyReservation.contains(page.key));
          keyReservation.add(page.key);
        }
      }
      return true;
    }());
  }

  LocalKey getUniqueKey({
    @required String name,
    Map<String, dynamic> arguments,
  }) {
    return ValueKey<String>(
        '$name${arguments == null ? '' : '-$arguments'}${_pages.length}');
  }
}
