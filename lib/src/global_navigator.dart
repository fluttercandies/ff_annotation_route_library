import 'package:flutter/material.dart';

// GlobalNavigator class is a utility class for managing global navigation actions.
// It provides easy access to the Navigator and BuildContext from anywhere in the app.
class GlobalNavigator {
  // Private constructor to prevent instantiation, ensuring this class is used statically.
  GlobalNavigator._();

  // GlobalKey that will be used to access the NavigatorState globally.
  // This allows us to perform navigation without directly depending on a specific context.
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // Getter for accessing the Navigator. It retrieves the Navigator widget from the current state.
  // An assert is added to ensure that the navigatorKey is initialized before accessing it.
  static Navigator? get navigator {
    assert(navigatorKey.currentState != null, 'Navigator is not initialized.');
    return navigatorKey.currentState!.widget;
  }

  // Getter for accessing the current BuildContext of the Navigator.
  // Useful when you need to pass context to some widgets or perform actions that require context.
  // Asserts ensure that the context is initialized before trying to use it.
  static BuildContext? get context {
    assert(
        navigatorKey.currentContext != null, 'Navigator is not initialized.');
    return navigatorKey.currentContext;
  }
}
