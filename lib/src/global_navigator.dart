import 'package:flutter/material.dart';

/// GlobalNavigator
///
/// Convenience access point for a globally registered `NavigatorState`.
///
/// NOTE: Prefer passing `BuildContext` or injecting navigation abstractions
/// in production code for testability. Global access is helpful for quick
/// prototyping or background callbacks where context is unavailable.
class GlobalNavigator {
  // Private constructor to prevent instantiation, ensuring this class is used statically.
  GlobalNavigator._();

  /// Global key used to locate the active `NavigatorState`.
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Returns the underlying `Navigator` widget. Throws an assertion error if
  /// the navigator has not been mounted yet.
  static Navigator? get navigator {
    assert(navigatorKey.currentState != null, 'Navigator is not initialized.');
    return navigatorKey.currentState!.widget;
  }

  /// Returns the current `BuildContext` for the global navigator. Useful when
  /// a context is required but not threaded through the call chain.
  static BuildContext? get context {
    assert(
      navigatorKey.currentContext != null,
      'Navigator is not initialized.',
    );
    return navigatorKey.currentContext;
  }
}
