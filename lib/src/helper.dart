import 'dart:convert';

import 'dart:developer';

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
        return int.tryParse(valueS) as T;
      } else if (0.0 is T) {
        return double.tryParse(valueS) as T;
      } else if (false is T) {
        if (valueS == '0' || valueS == '1') {
          return (valueS == '1') as T;
        }
        return bool.fromEnvironment(value.toString()) as T;
      } else if (value is List || value is Map) {
        return jsonDecode(valueS) as T;
      }
    }
  } catch (e, stackTrace) {
    log('asT<$T>', error: e, stackTrace: stackTrace);
    return defaultValue;
  }

  return defaultValue;
}
