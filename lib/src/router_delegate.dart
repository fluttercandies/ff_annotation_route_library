import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'page.dart';
import 'route_helper.dart';

typedef NavigatorWrapper = Widget Function(Navigator navigator);

class FFRouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings> {
  FFRouterDelegate({
    @required this.getRouteSettings,
    this.reportsRouteUpdateToEngine = true,
    this.onPopPage,
    this.navigatorWrapper,
    this.observers,
    this.routeWrapper,
  }) : navigatorKey = GlobalKey<NavigatorState>();
  final bool reportsRouteUpdateToEngine;
  final PopPageCallback onPopPage;
  final List<FFPage> _pages = <FFPage>[];
  final NavigatorWrapper navigatorWrapper;
  final RouteWrapper routeWrapper;
  final FFRouteSettings Function({
    @required String name,
    Map<String, dynamic> arguments,
  }) getRouteSettings;

  /// A list of observers for this navigator.
  final List<NavigatorObserver> observers;
  List<FFPage> get pages => _pages;
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  bool get canPop => navigatorKey?.currentState?.canPop();

  NavigatorState get navigatorState => navigatorKey?.currentState;

  static FFRouterDelegate of(BuildContext context) {
    final RouterDelegate<dynamic> delegate = Router.of(context).routerDelegate;
    assert(delegate is FFRouterDelegate, 'Delegate type must match');
    return delegate as FFRouterDelegate;
  }

  void pushNamed(
    String routeName, {
    Object arguments,
  }) {
    _pages.add(getRoutePage(
        name: routeName, arguments: arguments as Map<String, dynamic>));
    notifyListeners();
  }

  /// RootBackButtonDispatcher/ChildBackButtonDispatcher
  //
  @override
  Future<bool> popRoute() async {
    return super.popRoute();
  }

  @override
  Widget build(BuildContext context) {
    final Navigator navigator = Navigator(
      pages: <Page<dynamic>>[...pages],
      key: navigatorKey,
      reportsRouteUpdateToEngine: reportsRouteUpdateToEngine ?? kIsWeb,
      onPopPage: onPopPage ??
          (Route<dynamic> route, dynamic result) {
            if (_pages.isNotEmpty) {
              if (_pages.last.name == route.settings.name) {
                _pages.removeLast();
                notifyListeners();
              }
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

  @override
  Future<void> setNewRoutePath(RouteSettings configuration) {
    _pages.add(getRoutePage(
        name: configuration.name,
        arguments: configuration.arguments as Map<String, dynamic>));
    return SynchronousFuture<void>(null);
  }

  FFPage getRoutePage({String name, Map<String, dynamic> arguments}) {
    FFRouteSettings routeSettings =
        getRouteSettings(name: name, arguments: arguments);
    if (routeWrapper != null) {
      routeSettings = routeWrapper(routeSettings);
    }
    return routeSettings.toFFPage();
  }

  @override
  RouteSettings get currentConfiguration => _pages.last;
}
