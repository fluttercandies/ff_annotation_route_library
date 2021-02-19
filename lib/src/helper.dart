import 'dart:convert';

import 'dart:developer';

class FFConvert {
  FFConvert._();

  /// simple types(int,double,bool etc.) are handled, but not all of them.
  /// for example, you can type in web browser
  /// http://localhost:64916/#flutterCandies://testPageF?list=[4,5,6]&map={"ddd":123}&testMode={"id":2,"isTest":true}
  /// you should override following method, and convert queryParameters base on your case.
  static T Function<T>(dynamic value) convert = <T>(dynamic value) {
    if (value == null) {
      return null;
    }
    return json.decode(value.toString()) as T;
  };
}

T asT<T>(dynamic value, [T defaultValue]) {
  if (value is T) {
    return value;
  }
  try {
    if (value != null) {
      final String valueS = value.toString();
      if ('' is T) {
        return valueS as T;
      } else if (0 is T) {
        return int.parse(valueS) as T;
      } else if (0.0 is T) {
        return double.parse(valueS) as T;
      } else if (false is T) {
        if (valueS == '0' || valueS == '1') {
          return (valueS == '1') as T;
        }
        return bool.fromEnvironment(valueS) as T;
      } else {
        return FFConvert.convert<T>(value);
      }
    }
  } catch (e, stackTrace) {
    log('asT<$T>', error: e, stackTrace: stackTrace);
    return defaultValue;
  }

  return defaultValue;
}
