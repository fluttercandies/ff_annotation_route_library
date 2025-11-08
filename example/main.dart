import 'package:ff_annotation_route_library/ff_annotation_route_library.dart';
import 'package:flutter/widgets.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget>
    with RouteLifecycleMixin<MyWidget> {
  @override
  void onPageShow() {
    // Do something when the page is shown
    super.onPageShow();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
