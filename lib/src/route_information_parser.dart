import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class FFRouteInformationParser extends RouteInformationParser<RouteSettings> {
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
