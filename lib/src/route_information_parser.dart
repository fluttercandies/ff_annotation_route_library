import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class FFRouteInformationParser extends RouteInformationParser<RouteSettings> {
  /// Converts the given route information into parsed data to pass to a
  /// [RouterDelegate].
  ///
  /// The method should return a future which completes when the parsing is
  /// complete. The parsing may be asynchronous if, e.g., the parser needs to
  /// communicate with the OEM thread to obtain additional data about the route.
  ///
  /// Consider using a [SynchronousFuture] if the result can be computed
  /// synchronously, so that the [Router] does not need to wait for the next
  /// microtask to pass the data to the [RouterDelegate].
  @override
  Future<RouteSettings> parseRouteInformation(
      RouteInformation routeInformation) {
    final Uri uri = Uri.tryParse(routeInformation.location);
    String name = routeInformation.location;
    if (uri.queryParameters.isNotEmpty) {
      name = routeInformation.location
          .substring(0, routeInformation.location.indexOf('?'));
    }

    return SynchronousFuture<RouteSettings>(RouteSettings(
      name: name,
      arguments: uri.queryParameters,
    ));
  }

  /// Restore the route information from the given configuration.
  ///
  /// This is not required if you do not opt for the route information reporting
  /// , which is used for updating browser history for the web application. If
  /// you decides to opt in, you must also overrides this method to return a
  /// route information.
  ///
  /// In practice, the [parseRouteInformation] method must produce an equivalent
  /// configuration when passed this method's return value
  @override
  RouteInformation restoreRouteInformation(RouteSettings configuration) {
    String location = configuration.name;
    if (configuration.arguments != null &&
        configuration.arguments is Map<String, dynamic>) {
      final Map<String, dynamic> arguments =
          configuration.arguments as Map<String, dynamic>;
      final List<String> keys = arguments.keys.toList();
      for (int i = 0; i < keys.length; i++) {
        final String key = keys[i];
        if (i == 0) {
          location += '?';
        } else {
          location += '&';
        }
        location += '$key=${arguments[key]}';
      }
    }
    return RouteInformation(
      location: location,
    );
  }
}
