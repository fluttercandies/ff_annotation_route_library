import 'dart:async';
import 'dart:io';

import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageRoute;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'route_helper.dart';

/// FFRouteSettings / FFPage
///
/// This file contains data structures and helpers bridging generated route
/// metadata (`ff_annotation_route_core`) with concrete `Route` / `Page`
/// instances for both Navigator 1.0 and Router 2.0 use cases.
///
/// Key concepts:
///  * `FFRouteSettings` – extends `RouteSettings` with page builder, status bar
///    flags, descriptive metadata and extension slots.
///  * `FFPage` – a `Page` subclass wrapping builder logic for declarative
///    navigation.
///  * Factory helpers for notFound and error routes.
///
/// Generated code will typically call into these APIs to construct runtime
/// navigation artifacts.
/// Navigator 1.0
class FFRouteSettings extends RouteSettings {
  const FFRouteSettings({
    required String name,
    required this.builder,
    Object? arguments,
    this.showStatusBar,
    this.routeName,
    this.pageRouteType,
    this.description,
    this.exts,
    this.codes,
  }) : super(
          name: name,
          arguments: arguments,
        );

  factory FFRouteSettings.notFound(Widget notFoundWidget) {
    return FFRouteSettings(
      name: FFRoute.notFoundName,
      routeName: FFRoute.notFoundRouteName,
      builder: () => notFoundWidget,
    );
  }

  /// to support something can't write in annotation
  /// it will be hadnled as a code when generate route
  final Map<String, dynamic>? codes;

  /// The builder return the page
  final PageBuilder builder;

  /// The Widget base on this route
  //final Widget? widget;

  /// Whether show status bar.
  final bool? showStatusBar;

  /// The route name to track page
  final String? routeName;

  /// The type of page route
  final PageRouteType? pageRouteType;

  /// The description of route
  final String? description;

  /// The extend arguments
  final Map<String, dynamic>? exts;

  /// Whether the setting is targeting the not found route.
  bool get isNotFound =>
      name == FFRoute.notFoundName && routeName == FFRoute.notFoundRouteName;

  static Route<dynamic> createRouteFromBuilder({
    required PageBuilder pageBuilder,
    PageRouteType? pageRouteType,
    RouteSettings? settings,
    FFErrorWidgetBuilder? errorWidgetBuilder,
  }) {
    Widget builder(BuildContext context) {
      try {
        return pageBuilder();
      } catch (e, s) {
        if (errorWidgetBuilder != null) {
          return errorWidgetBuilder(context, e, s);
        }
        rethrow;
      }
    }

    switch (pageRouteType) {
      case PageRouteType.material:
        return MaterialPageRoute(
          settings: settings,
          builder: builder,
        );
      case PageRouteType.cupertino:
        return CupertinoPageRoute(
          settings: settings,
          builder: builder,
        );
      case PageRouteType.transparent:
        return FFTransparentPageRoute(
          settings: settings,
          pageBuilder: (context, _, __) => builder(context),
        );
      case null:
        if (kIsWeb) {
          return MaterialPageRoute(
            settings: settings,
            builder: builder,
          );
        }
        if (Platform.isIOS || Platform.isMacOS) {
          return CupertinoPageRoute(
            settings: settings,
            builder: builder,
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: builder,
        );
    }
  }

  Route<dynamic> createRoute({FFErrorWidgetBuilder? errorWidgetBuilder}) {
    return createRouteFromBuilder(
      pageBuilder: builder,
      pageRouteType: pageRouteType,
      settings: this,
      errorWidgetBuilder: errorWidgetBuilder,
    );
  }

  FFRouteSettings copyWith({
    String? name,
    Object? arguments,
    PageBuilder? builder,
    bool? showStatusBar,
    String? routeName,
    PageRouteType? pageRouteType,
    String? description,
    Map<String, dynamic>? exts,
    Map<String, dynamic>? codes,
  }) {
    return FFRouteSettings(
      name: name ?? this.name!,
      arguments: arguments ?? this.arguments,
      builder: builder ?? this.builder,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      routeName: routeName ?? this.routeName,
      pageRouteType: pageRouteType ?? this.pageRouteType,
      description: description ?? this.description,
      exts: exts ?? this.exts,
      codes: codes ?? this.codes,
    );
  }

  FFPage<T> toFFPage<T extends Object?>({
    String? name,
    Object? arguments,
    required LocalKey key,
    PageBuilder? builder,
    bool? showStatusBar,
    String? routeName,
    PageRouteType? pageRouteType,
    String? description,
    Map<String, dynamic>? exts,
    Map<String, dynamic>? codes,
  }) {
    return FFPage<T>(
      name: name ?? this.name!,
      arguments: arguments ?? this.arguments,
      key: key,
      builder: builder ?? this.builder,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      routeName: routeName ?? this.routeName,
      pageRouteType: pageRouteType ?? this.pageRouteType,
      description: description ?? this.description,
      exts: exts ?? this.exts,
      codes: codes ?? this.codes,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'arguments': arguments,
      'showStatusBar': showStatusBar,
      'routeName': routeName,
      'pageRouteType': pageRouteType,
      'description': description,
      'exts': exts,
      'codes': codes,
    };
  }
}

/// Navigator 2.0
class FFPage<T> extends Page<T> {
  FFPage({
    required String name,
    required LocalKey key,
    required this.builder,
    Object? arguments,
    this.showStatusBar,
    this.routeName,
    this.pageRouteType,
    this.description,
    this.exts,
    this.codes,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
        );

  /// to support something can't write in annotation
  /// it will be hadnled as a code when generate route
  final Map<String, dynamic>? codes;

  /// The builder return the page
  final PageBuilder builder;

  /// The Widget base on this route
  //final Widget widget;

  /// Whether show status bar.
  final bool? showStatusBar;

  /// The route name to track page
  final String? routeName;

  /// The type of page route
  final PageRouteType? pageRouteType;

  /// The description of route
  final String? description;

  /// The extend arguments
  final Map<String, dynamic>? exts;

  /// A future that completes when this route is popped off the navigator.
  ///
  /// The future completes with the value given to [Navigator.pop], if any, or
  /// else the value of [null].
  Future<T> get popped => _popCompleter.future;
  final Completer<T> _popCompleter = Completer<T>();

  bool get isCompleted => _popCompleter.isCompleted;

  /// pop this route
  bool didPop([T? result]) {
    if (!_popCompleter.isCompleted) {
      _popCompleter.complete(result);
    }
    return true;
  }

  @override
  Route<T> createRoute(BuildContext context) {
    final Route<T> route = _createRoute(context);
    return route
      ..popped.then((T? value) {
        if (!isCompleted) {
          _popCompleter.complete(value);
        }
      });
  }

  Route<T> _createRoute(BuildContext context) {
    switch (pageRouteType) {
      case PageRouteType.material:
        return MaterialPageRoute<T>(
          settings: this,
          builder: (BuildContext _) => builder(),
        );
      case PageRouteType.cupertino:
        return CupertinoPageRoute<T>(
          settings: this,
          builder: (BuildContext _) => builder(),
        );
      case PageRouteType.transparent:
        return FFTransparentPageRoute<T>(
          settings: this,
          pageBuilder: (
            BuildContext _,
            Animation<double> __,
            Animation<double> ___,
          ) =>
              builder(),
        );
      default:
        return kIsWeb || !Platform.isIOS
            ? MaterialPageRoute<T>(
                settings: this,
                builder: (BuildContext _) => builder(),
              )
            : CupertinoPageRoute<T>(
                settings: this,
                builder: (BuildContext _) => builder(),
              );
    }
  }

  FFPage<T> copyWith({
    String? name,
    Object? arguments,
    LocalKey? key,
    PageBuilder? builder,
    bool? showStatusBar,
    String? routeName,
    PageRouteType? pageRouteType,
    String? description,
    Map<String, dynamic>? exts,
    Map<String, dynamic>? codes,
  }) {
    return FFPage<T>(
      name: name ?? this.name!,
      arguments: arguments ?? this.arguments,
      key: key ?? this.key!,
      builder: builder ?? this.builder,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      routeName: routeName ?? this.routeName,
      pageRouteType: pageRouteType ?? this.pageRouteType,
      description: description ?? this.description,
      exts: exts ?? this.exts,
      codes: codes ?? this.codes,
    );
  }

  FFRouteSettings toFFRouteSettings({
    String? name,
    Object? arguments,
    LocalKey? key,
    PageBuilder? builder,
    bool? showStatusBar,
    String? routeName,
    PageRouteType? pageRouteType,
    String? description,
    Map<String, dynamic>? exts,
    Map<String, dynamic>? codes,
  }) {
    return FFRouteSettings(
      name: name ?? this.name!,
      arguments: arguments ?? this.arguments,
      builder: builder ?? this.builder,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      routeName: routeName ?? this.routeName,
      pageRouteType: pageRouteType ?? this.pageRouteType,
      description: description ?? this.description,
      exts: exts ?? this.exts,
      codes: codes ?? this.codes,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'arguments': arguments,
        'key': key,
        'showStatusBar': showStatusBar,
        'routeName': routeName,
        'pageRouteType': pageRouteType,
        'description': description,
        'exts': exts,
        'codes': codes,
      };
}

/// The builder return the page
typedef PageBuilder = Widget Function();

/// The builder return the error page
typedef FFErrorWidgetBuilder = Widget Function(
  BuildContext context,
  Object error,
  StackTrace stackTrace,
);

/// GoRouter
///
class FFGoRouterRouteSettings extends RouteSettings {
  const FFGoRouterRouteSettings({
    required String name,
    required this.builder,
    Object? arguments,
    this.showStatusBar,
    this.routeName,
    this.pageRouteType,
    this.description,
    this.exts,
    this.codes,
  }) : super(
          name: name,
          arguments: arguments,
        );

  factory FFGoRouterRouteSettings.notFound(Widget notFoundWidget) {
    return FFGoRouterRouteSettings(
      name: FFRoute.notFoundName,
      routeName: FFRoute.notFoundRouteName,
      builder: (_) => notFoundWidget,
    );
  }

  /// to support something can't write in annotation
  /// it will be hadnled as a code when generate route
  final Map<String, dynamic>? codes;

  /// The builder return the page
  final GoRouterPageBuilder builder;

  /// The Widget base on this route
  //final Widget? widget;

  /// Whether show status bar.
  final bool? showStatusBar;

  /// The route name to track page
  final String? routeName;

  /// The type of page route
  final PageRouteType? pageRouteType;

  /// The description of route
  final String? description;

  /// The extend arguments
  final Map<String, dynamic>? exts;

  /// Whether the setting is targeting the not found route.
  bool get isNotFound =>
      name == FFRoute.notFoundName && routeName == FFRoute.notFoundRouteName;
}

/// The builder return the page
typedef GoRouterPageBuilder = Widget Function(
  Map<String, dynamic> safeArguments,
);
