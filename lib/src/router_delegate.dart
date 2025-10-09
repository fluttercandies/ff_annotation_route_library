import 'package:collection/collection.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'page.dart';
import 'route_helper.dart';

/// [FFRouterDelegate.navigatorWrapper]
typedef NavigatorWrapper = Widget Function(Navigator navigator);

/// Signature for the [FFRouterDelegate.popUntil] predicate argument.
typedef PagePredicate = bool Function(FFPage<dynamic> page);

/// A delegate that is used by the [Router] widget to build and configure a
/// navigating widget.
class FFRouterDelegate extends RouterDelegate<RouteSettings>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteSettings> {
  FFRouterDelegate({
    required this.getRouteSettings,
    //this.reportsRouteUpdateToEngine,
    this.onPopPage,
    this.navigatorWrapper,
    this.observers,
    this.pageWrapper,
    this.transitionDelegate = const DefaultTransitionDelegate<dynamic>(),
    this.notFoundPageBuilder,
  }) : navigatorKey = GlobalKey<NavigatorState>();

  /// The delegate used for deciding how routes transition in or off the screen
  /// during the [pages] updates.
  ///
  /// Defaults to [DefaultTransitionDelegate] if not specified, cannot be null.
  final TransitionDelegate<dynamic> transitionDelegate;

  /// Whether this navigator should report route update message back to the
  /// engine when the top-most route changes.
  ///
  /// If the property is set to true, this navigator automatically sends the
  /// route update message to the engine when it detects top-most route changes.
  /// The messages are used by the web engine to update the browser URL bar.
  ///
  /// If there are multiple navigators in the widget tree, at most one of them
  /// can set this property to true (typically, the top-most one created from
  /// the [WidgetsApp]). Otherwise, the web engine may receive multiple route
  /// update messages from different navigators and fail to update the URL
  /// bar.
  ///
  /// Defaults to null(true on Web).
  // final bool? reportsRouteUpdateToEngine;

  /// Called when [pop] is invoked but the current [Route] corresponds to a
  /// [Page] found in the [pages] list.
  ///
  /// The `result` argument is the value with which the route is to complete
  /// (e.g. the value returned from a dialog).
  ///
  /// This callback is responsible for calling [Route.didPop] and returning
  /// whether this pop is successful.
  ///
  /// The [Navigator] widget should be rebuilt with a [pages] list that does not
  /// contain the [Page] for the given [Route]. The next time the [pages] list
  /// is updated, if the [Page] corresponding to this [Route] is still present,
  /// it will be interpreted as a new route to display.
  final PopPageCallback? onPopPage;

  /// The wrapper of Navigator
  final NavigatorWrapper? navigatorWrapper;

  /// The wrapper of Page, you can redefine page in this call back
  final PageWrapper? pageWrapper;

  /// The getRouteSettings method which is created by [ff_annotation_route]
  final GetRouteSettings getRouteSettings;

  /// A list of observers for this navigator.
  final List<NavigatorObserver>? observers;

  final List<FFPage<dynamic>> _pages = <FFPage<dynamic>>[];

  /// The current pages of navigator
  List<FFPage<dynamic>> get pages => _pages;

  /// If the page is not found, it's the default page
  final PageBuilder? notFoundPageBuilder;

  /// The key used for retrieving the current navigator
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  NavigatorState? get navigatorState => navigatorKey.currentState;

  /// Retrieves the immediate [RouterDelegate] ancestor from the given context.
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
  ///
  /// Handle Android hardware back button / web browser back button is a global event in stack.
  /// The element are inserted in the stack by passing BackButtonDispacher to
  /// your routers [RootBackButtonDispacher for the root navigator, ChildBackButtonDispacherwhich call takePriority for the others].
  /// override this method if you have specific operational requirement
  /// The demo [https://github.com/fluttercandies/ff_annotation_route/tree/master/example1/lib/nested_router_demo.dart]
  ///
  @override
  Future<bool> popRoute() async {
    return super.popRoute();
  }

  @override
  Widget build(BuildContext context) {
    final Navigator navigator = Navigator(
      pages: pages.toList(),
      key: navigatorKey,
      transitionDelegate: transitionDelegate,
      reportsRouteUpdateToEngine: false,
      // ignore: deprecated_member_use
      onPopPage: onPopPage ??
          (Route<dynamic> route, dynamic result) {
            if (_pages.length > 1 && route.settings is FFPage) {
              final FFPage<dynamic>? removed = _pages.lastWhereIndexedOrNull(
                (int index, FFPage<dynamic> element) =>
                    element.name == route.settings.name,
              );
              if (removed != null) {
                _pages.remove(removed);
                updatePages();
              }
            }
            return route.didPop(result);
          },
      observers: <NavigatorObserver>[
        HeroController(),
        if (observers != null) ...observers!,
      ],
    );

    if (navigatorWrapper != null) {
      return navigatorWrapper!(navigator);
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
    _pages.add(
      getRoutePage(
        name: configuration.name!,
        arguments: configuration.arguments as Map<String, dynamic>?,
      ),
    );
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
  RouteSettings? get currentConfiguration =>
      _pages.isNotEmpty ? _pages.last : null;

  FFPage<T?> getRoutePage<T extends Object?>({
    required String name,
    Map<String, dynamic>? arguments,
  }) {
    FFPage<T?> ffPage = getRouteSettings(
      name: name,
      arguments: arguments,
      notFoundPageBuilder: notFoundPageBuilder,
    ).toFFPage<T>(
      key: getUniqueKey(),
    );
    if (pageWrapper != null) {
      ffPage = pageWrapper!(ffPage);
    }
    return ffPage;
  }

  /// navigator

  /// pop

  /// Whether the navigator that most tightly encloses the given context can be
  /// popped.
  bool? canPop() => navigatorKey.currentState?.canPop();

  /// Pop the top-most route off the navigator that most tightly encloses the
  /// given context.
  void pop<T extends Object?>([T? result]) {
    navigatorState!.pop<T>(result);
  }

  // ignore: deprecated_member_use
  /// Consults the current route's [Route.willPop] method, and acts accordingly,
  /// potentially popping the route as a result; returns whether the pop request
  /// should be considered handled.
  Future<bool> maybePop<T extends Object?>([T? result]) {
    return navigatorState!.maybePop<T>(result);
  }

  /// Pop the current route off the navigator and push a named route in its
  /// place.
  Future<T?> popAndPushNamed<T extends Object?>(
    String routeName, {
    T? result,
    Map<String, dynamic>? arguments,
  }) {
    pop<T>(result);
    return pushNamed<T>(routeName, arguments: arguments);
  }

  /// Calls [pop] repeatedly on the navigator that most tightly encloses the
  /// given context until the predicate returns true.
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

  /// Push a named route onto the navigator that most tightly encloses the given
  /// context.
  Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Map<String, dynamic>? arguments,
  }) {
    final FFPage<T?> page = getRoutePage<T>(
      name: routeName,
      arguments: arguments,
    );
    pages.add(page);
    updatePages();
    return page.popped;
  }

  /// Push the given page onto the navigator.
  Future<T?> push<T extends Object?>(
    FFPage<T?> page,
  ) {
    pages.add(page);
    updatePages();
    return page.popped;
  }

  /// Push the given page onto the navigator that most tightly encloses the
  /// given context, and then remove all the previous routes until the
  /// `predicate` returns true.
  Future<T?> pushAndRemoveUntil<T extends Object?>(
    FFPage<T?> newPage,
    PagePredicate predicate,
  ) {
    _popUntil(predicate);
    return push<T>(newPage);
  }

  /// Push the route with the given name onto the navigator that most tightly
  /// encloses the given context, and then remove all the previous routes until
  /// the `predicate` returns true.
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    String newRouteName,
    PagePredicate predicate, {
    Map<String, dynamic>? arguments,
  }) {
    _popUntil(predicate);
    return pushNamed<T>(newRouteName, arguments: arguments);
  }

  /// push

  /// navigator

  /// call this after you change pages
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
          keyReservation.add(page.key!);
        }
      }
      return true;
    }());
  }

  /// Unique Key for Page
  UniqueKey getUniqueKey() => UniqueKey();
}
