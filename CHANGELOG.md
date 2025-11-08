## 3.2.3

* Add `RouteObserverHolder` to allow swapping the global `BaseRouteObserver` (inject a custom observer in `main()`)
* Provide `ExtendedRouteObserver` (singleton) as the default global observer; document how to replace it
* Introduce and document `RouteLifecycleMixin<T extends StatefulWidget>` for easy lifecycle hooks on State classes

## 3.2.2

* Add `BaseRouteObserver` as a base class that can be extended for custom route observers
* Refactor `RouteLifecycleState` to `RouteLifecycleMixin` for better flexibility and composability

## 3.2.1

* Add `FFGoRouterRouteSettings` and `GoRouterPageBuilder` to support `go_router`.

## 3.2.0

* Introduce `FFErrorWidgetBuilder` to build an error page correspondingly.
* Extract `FFRouteSettings.createRouteFromBuilder`.

## 3.1.0

* Support route interceptor
* Add `RouteLifecycleState` provides lifecycle management for routes
* Add `GlobalNavigator` manages global navigation actions

## 3.0.0

* Breaking change: use `FFRouteSettings.builder` instead of `FFRouteSettings.widget`
* Breaking change: use `FFPage.builder` instead of `FFPage.widget`
* Breaking change: use `notFoundPageBuilder` instead of `notFoundWidget` 

## 2.0.4

* Add `FFRouteSettings.notFound` factory constructor.

## 2.0.3

* add notFoundWidget for FFRouterDelegate

## 2.0.2

* add notFoundWidget for GetRouteSettings

## 2.0.1

* Fix issue that we should not set reportsRouteUpdateToEngine to true when use Router. Flutter #77143
  
## 2.0.0

* null*safety by default
## 1.2.4*nullsafety

* Fix T?

## 1.2.3*nullsafety

* Fix non*nullable error

## 1.2.2*nullsafety.1

* Migrate to non*nullable
## 1.2.2

* Fix FFRouteSettings's widget is null.
  
# 1.2.1

* Fix bool convert and popPage.
## 1.2.0

* Add more same method(navigator) for FFRouterDelegate

## 1.1.0

* Add FFConvert
## 1.0.0

* Initial version
