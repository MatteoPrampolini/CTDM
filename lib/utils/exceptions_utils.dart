import 'dart:convert';

class CtdmException implements Exception {
  final String? details;
  final StackTrace? stackTrace;
  final String errorCode;

  CtdmException(this.details, this.stackTrace, this.errorCode);

  @override
  String toString() {
    return 'errorCode = $errorCode, message = $details';
  }

  CtdmError getDetailedError(String jsonString) {
    return getError(jsonString);
  }
}

class CtdmError {
  final String errorCode;
  final String description;
  final String type;

  CtdmError({
    required this.errorCode,
    required this.description,
    required this.type,
  });

  factory CtdmError.fromJson(Map<String, dynamic> json) {
    return CtdmError(
      errorCode: json['errorCode'],
      description: json['description'],
      type: json['type'],
    );
  }

  @override
  String toString() {
    return 'CtdmError{errorCode: $errorCode, description: $description, type: $type}';
  }
}

extension CtdmExceptionExtension on CtdmException {
  CtdmError getError(String jsonString) {
    try {
      Map<String, dynamic> jsonMap = json.decode(jsonString);

      if (jsonMap.containsKey("errors")) {
        Map<String, dynamic> errorsMap = jsonMap["errors"];

        if (errorsMap.containsKey(errorCode)) {
          return CtdmError(
              errorCode: errorCode,
              description: errorsMap[errorCode]['description'],
              type: errorsMap[errorCode]['type']);
        }
      }

      return CtdmError(
        errorCode: '0000',
        description: 'unknown',
        type: 'unknown',
      );
    } catch (e) {
      return CtdmError(
          errorCode: '0001',
          description: 'error parsing json error',
          type: 'weird');
    }
  }
}
