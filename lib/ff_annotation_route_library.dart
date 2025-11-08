/// ff_annotation_route_library
///
/// This is the public entry point for the annotation–driven navigation helper
/// package. It re‑exports the core annotation types (`ff_annotation_route_core`)
/// together with higher level runtime helpers:
///
///  * Global navigation utilities (`GlobalNavigator`)
///  * Route building and settings models (`FFRouteSettings`, `FFPage`, etc.)
///  * Router 2.0 delegate / information parser (`FFRouterDelegate`, `FFRouteInformationParser`)
///  * Interceptor infrastructure (route interception & navigator extensions)
///  * Lifecycle observation (page/route & app foreground/background hooks)
///
/// Import this single library in application code instead of individual
/// files for a stable, curated surface:
///
/// ```dart
/// import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
/// ```
library ff_annotation_route_library;

export 'package:ff_annotation_route_core/ff_annotation_route_core.dart';

export 'src/global_navigator.dart';
export 'src/helper.dart';
export 'src/interceptor/extension.dart';
export 'src/interceptor/navigator_with_interceptor.dart';
export 'src/interceptor/route_interceptor.dart';
export 'src/page.dart';
export 'src/route_helper.dart';
export 'src/route_information_parser.dart';
export 'src/route_lifecycle/extended_route_aware.dart';
export 'src/route_lifecycle/extended_route_observer.dart';
export 'src/route_lifecycle/route_lifecycle_state.dart';
export 'src/router_delegate.dart';
