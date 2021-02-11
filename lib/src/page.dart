import 'dart:io';

import 'package:ff_annotation_route_core/ff_annotation_route_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'route_helper.dart';

/// Navigator 1.0
class FFRouteSettings extends RouteSettings {
  const FFRouteSettings({
    @required String name,
    Object arguments,
    this.widget,
    this.showStatusBar,
    this.routeName,
    this.pageRouteType,
    this.description,
    this.exts,
  }) : super(
          name: name,
          arguments: arguments,
        );

  /// The Widget base on this route
  final Widget widget;

  /// Whether show status bar.
  final bool showStatusBar;

  /// The route name to track page
  final String routeName;

  /// The type of page route
  final PageRouteType pageRouteType;

  /// The description of route
  final String description;

  /// The extend arguments
  final Map<String, dynamic> exts;

  Route<dynamic> createRoute() {
    switch (pageRouteType) {
      case PageRouteType.material:
        return MaterialPageRoute<dynamic>(
          settings: this,
          builder: (BuildContext _) => widget,
        );
      case PageRouteType.cupertino:
        return CupertinoPageRoute<dynamic>(
          settings: this,
          builder: (BuildContext _) => widget,
        );
      case PageRouteType.transparent:
        return FFTransparentPageRoute<dynamic>(
          settings: this,
          pageBuilder: (
            BuildContext _,
            Animation<double> __,
            Animation<double> ___,
          ) =>
              widget,
        );
      default:
        return kIsWeb || !Platform.isIOS
            ? MaterialPageRoute<dynamic>(
                settings: this,
                builder: (BuildContext _) => widget,
              )
            : CupertinoPageRoute<dynamic>(
                settings: this,
                builder: (BuildContext _) => widget,
              );
    }
  }

  @override
  FFRouteSettings copyWith({
    String name,
    Object arguments,
    LocalKey key,
    Widget widget,
    bool showStatusBar,
    String routeName,
    PageRouteType pageRouteType,
    String description,
    Map<String, dynamic> exts,
  }) {
    return FFRouteSettings(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      widget: widget ?? this.widget,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      routeName: routeName ?? this.routeName,
      pageRouteType: pageRouteType ?? this.pageRouteType,
      description: description ?? this.description,
      exts: exts ?? this.exts,
    );
  }

  FFPage toFFPage({
    String name,
    Object arguments,
    LocalKey key,
    Widget widget,
    bool showStatusBar,
    String routeName,
    PageRouteType pageRouteType,
    String description,
    Map<String, dynamic> exts,
  }) {
    return FFPage(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      key: key,
      widget: widget ?? this.widget,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      routeName: routeName ?? this.routeName,
      pageRouteType: pageRouteType ?? this.pageRouteType,
      description: description ?? this.description,
      exts: exts ?? this.exts,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'arguments': arguments,
        'showStatusBar': showStatusBar,
        'routeName': routeName,
        'pageRouteType': pageRouteType,
        'description': description,
        'exts': exts,
      };
}

/// Navigator 2.0
class FFPage extends Page<dynamic> {
  const FFPage({
    @required String name,
    Object arguments,
    LocalKey key,
    this.widget,
    this.showStatusBar,
    this.routeName,
    this.pageRouteType,
    this.description,
    this.exts,
  }) : super(
          key: key,
          name: name,
          arguments: arguments,
        );

  /// The Widget base on this route
  final Widget widget;

  /// Whether show status bar.
  final bool showStatusBar;

  /// The route name to track page
  final String routeName;

  /// The type of page route
  final PageRouteType pageRouteType;

  /// The description of route
  final String description;

  /// The extend arguments
  final Map<String, dynamic> exts;

  @override
  Route<dynamic> createRoute(BuildContext context) {
    switch (pageRouteType) {
      case PageRouteType.material:
        return MaterialPageRoute<dynamic>(
          settings: this,
          builder: (BuildContext _) => widget,
        );
      case PageRouteType.cupertino:
        return CupertinoPageRoute<dynamic>(
          settings: this,
          builder: (BuildContext _) => widget,
        );
      case PageRouteType.transparent:
        return FFTransparentPageRoute<dynamic>(
          settings: this,
          pageBuilder: (
            BuildContext _,
            Animation<double> __,
            Animation<double> ___,
          ) =>
              widget,
        );
      default:
        return kIsWeb || !Platform.isIOS
            ? MaterialPageRoute<dynamic>(
                settings: this,
                builder: (BuildContext _) => widget,
              )
            : CupertinoPageRoute<dynamic>(
                settings: this,
                builder: (BuildContext _) => widget,
              );
    }
  }

  @override
  FFPage copyWith({
    String name,
    Object arguments,
    LocalKey key,
    Widget widget,
    bool showStatusBar,
    String routeName,
    PageRouteType pageRouteType,
    String description,
    Map<String, dynamic> exts,
  }) {
    return FFPage(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      key: key ?? this.key,
      widget: widget ?? this.widget,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      routeName: routeName ?? this.routeName,
      pageRouteType: pageRouteType ?? this.pageRouteType,
      description: description ?? this.description,
      exts: exts ?? this.exts,
    );
  }

  FFRouteSettings toFFRouteSettings({
    String name,
    Object arguments,
    LocalKey key,
    Widget widget,
    bool showStatusBar,
    String routeName,
    PageRouteType pageRouteType,
    String description,
    Map<String, dynamic> exts,
  }) {
    return FFRouteSettings(
      name: name ?? this.name,
      arguments: arguments ?? this.arguments,
      widget: widget ?? this.widget,
      showStatusBar: showStatusBar ?? this.showStatusBar,
      routeName: routeName ?? this.routeName,
      pageRouteType: pageRouteType ?? this.pageRouteType,
      description: description ?? this.description,
      exts: exts ?? this.exts,
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
      };
}
