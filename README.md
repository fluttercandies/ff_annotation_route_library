# ff_annotation_route_library

The library for ff_annotation_route.

### Navigator 2.0

you can see full demo in example1
#### Main.dart

``` dart
import 'dart:convert';
import 'package:example1/src/model/test_model.dart';
import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'example1_route.dart';
import 'example1_routes.dart';

void main() {
  // tool will handle simple types(int,double,bool etc.), but not all of them.
  // for example, you can type in web browser
  // http://localhost:64916/#flutterCandies://testPageF?list=[4,5,6]&map={"ddd":123}&testMode={"id":2,"isTest":true}
  // the queryParameters will be converted base on your case.
  FFConvert.convert = <T>(dynamic value) {
    if (value == null) {
      return null;
    }
    print(T);
    final dynamic output = json.decode(value.toString());
    if (<int>[] is T && output is List<dynamic>) {
      return output.map<int>((dynamic e) => asT<int>(e)).toList() as T;
    } else if (<String, String>{} is T && output is Map<dynamic, dynamic>) {
      return output.map<String, String>((dynamic key, dynamic value) =>
          MapEntry<String, String>(key.toString(), value.toString())) as T;
    } else if (const TestMode() is T && output is Map<dynamic, dynamic>) {
      return TestMode.fromJson(output) as T;
    }

    return json.decode(value.toString()) as T;
  };
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FFRouteInformationParser _ffRouteInformationParser =
      FFRouteInformationParser();

  final FFRouterDelegate _ffRouterDelegate = FFRouterDelegate(
    getRouteSettings: getRouteSettings,
    pageWrapper: <T>(FFPage<T> ffPage) {
      return ffPage.copyWith(
        widget: ffPage.name == Routes.fluttercandiesMainpage ||
                ffPage.name == Routes.fluttercandiesDemogrouppage.name
            ? ffPage.widget
            : CommonWidget(
                child: ffPage.widget,
                routeName: ffPage.routeName,
              ),
      );
    },
  );
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ff_annotation_route demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // initialRoute
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: const RouteInformation(
          location: Routes.fluttercandiesMainpage,
        ),
      ),
      routeInformationParser: kIsWeb ? _ffRouteInformationParser : null,
      routerDelegate: _ffRouterDelegate,
    );
  }
}
```

#### FFRouteInformationParser

It's working on Web when you type in browser or report to browser. A delegate that is used by the [Router] widget to parse a route information
into a configuration of type [RouteSettings]. 

for example:

`xxx?a=1&b=2` <=> `RouteSettings(name:'xxx',arguments:<String, dynamic>{'a':'1','b':'2'})`


#### FFRouterDelegate

A delegate that is used by the [Router] widget to build and configure anavigating widget. 

It provides push/pop methods like [Navigator].

``` dart
  FFRouterDelegate.of(context).pushNamed<void>(
    Routes.flutterCandiesTestPageF.name,
    arguments: Routes.flutterCandiesTestPageF.d(
      <int>[1, 2, 3],
      map: <String, String>{'ddd': 'dddd'},
      testMode: const TestMode(id: 1, isTest: true),
    ),
  );
```

you can find more demo in `test_page_c.dart`.

#### Push

##### Push name

``` dart
  FFRouterDelegate.of(context).pushNamed<void>(
    Routes.flutterCandiesTestPageA,
  );
```

##### Push name with arguments

* `arguments` **MUST** be a `Map<String, dynamic>`

```dart
  FFRouterDelegate.of(context).pushNamed<void>(
    Routes.flutterCandiesTestPageF.name,
    arguments: Routes.flutterCandiesTestPageF.d(
      <int>[1, 2, 3],
      map: <String, String>{'ddd': 'dddd'},
      testMode: const TestMode(id: 1, isTest: true),
    ),
  );
```
* enable --supper-arguments

``` dart
  FFRouterDelegate.of(context).pushNamed<void>(
    Routes.flutterCandiesTestPageF.name,
    arguments: <String, dynamic>{
        'list': <int>[1, 2, 3],
        'map': <String, String>{'ddd': 'dddd'},
        'testMode': const TestMode(id: 1, isTest: true),
     }
  ) 
```
