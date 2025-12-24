class GenericResponse<T> {
  int success;
  String? message;
  List<String>? errors;
  T? data;

  // Constructor vacío
  GenericResponse({
    required this.success,
    this.message,
    this.errors,
    this.data,
  });

  // Constructor con solo mensaje de error
  GenericResponse.errorMessage(String this.message)
      : success = EProgrammingState.error.value,
        errors = null,
        data = null;

  // Constructor con estado y mensaje
  GenericResponse.withState(int programmingState, String this.message)
      : success = programmingState,
        errors = null,
        data = null;

  // Constructor con datos y mensaje opcional
  GenericResponse.withData(T this.data, {this.message})
      : success = EProgrammingState.success.value,
        errors = null;

  // Constructor con datos, estado y mensaje opcional
  GenericResponse.withDataAndState(
      T this.data, int programmingState, {this.message})
      : success = programmingState,
        errors = null;

  // Constructor con datos, lista de errores y mensaje opcional
  GenericResponse.withErrors(
      T this.data, List<String> messages, {this.message})
      : success = EProgrammingState.success.value,
        errors = messages;

  // Deserialización desde JSON
  factory GenericResponse.fromJson(Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return GenericResponse(
      success: json['success'],
      message: json['message'],
      errors: json['errors'] != null ? List<String>.from(json['errors']) : null,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }

  // Serialización a JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'success': success,
      'message': message,
      'errors': errors,
      'data': data != null ? toJsonT(data as T) : null,
    };
  }
}

// Enumeración de estados
enum EProgrammingState {
  error(0),
  success(1),
  info(2),
  warning(3);

  final int value;
  const EProgrammingState(this.value);
}