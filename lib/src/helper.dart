import 'dart:convert';

import 'dart:developer';

/// FFConvert
///
/// Simple conversion utility invoked by `asT<T>()`. Override the static
/// `convert` field to plug in custom parsing logic for complex types or to
/// handle non-JSON encodings.
///
/// Default behavior attempts `json.decode` on the string form of `value`.
class FFConvert {
  FFConvert._();

  /// simple types(int,double,bool etc.) are handled, but not all of them.
  /// for example, you can type in web browser
  /// http://localhost:64916/#flutterCandies://testPageF?list=[4,5,6]&map={"ddd":123}&testMode={"id":2,"isTest":true}
  /// you should override following method, and convert queryParameters base on your case.
  static T? Function<T extends Object?>(dynamic value) convert =
      <T>(dynamic value) {
    if (value == null) {
      return null;
    }
    return json.decode(value.toString()) as T?;
  };
}

/// Attempts to coerce a dynamic value into type `T` using:
///  * Direct `is T` check
///  * Primitive parsing for `String`, `int`, `double`, `bool`
///  * Fallback to `FFConvert.convert<T>`
/// Returns `defaultValue` if parsing fails.
T? asT<T extends Object?>(dynamic value, [T? defaultValue]) {
  if (value is T) {
    return value;
  }
  try {
    if (value != null) {
      final String valueS = value.toString();
      if ('' is T) {
        return valueS as T;
      } else if (0 is T) {
        return (int.tryParse(valueS) ?? double.tryParse(valueS)?.toInt()) as T;
      } else if (0.0 is T) {
        return double.parse(valueS) as T;
      } else if (false is T) {
        if (valueS == '0' || valueS == '1') {
          return (valueS == '1') as T;
        }
        return (valueS == 'true') as T;
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
