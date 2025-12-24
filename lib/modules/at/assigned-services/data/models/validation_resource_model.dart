class ValidationResource {
  final bool simultaneity;
  final int returnValueId;
  final bool resourceType;
  final String validationErrorMessage;

  ValidationResource({
    required this.simultaneity,
    required this.returnValueId,
    required this.resourceType,
    required this.validationErrorMessage,
  });

  factory ValidationResource.fromJson(Map<String, dynamic> json) {
    return ValidationResource(
      simultaneity: json['simultaneity'] ?? false,
      returnValueId: json['returnValueId'] ?? 0,
      resourceType: json['resourceType'] ?? true,
      validationErrorMessage: json['validationErrorMessage'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'simultaneity': simultaneity,
      'returnValueId': returnValueId,
      'resourceType': resourceType,
      'validationErrorMessage': validationErrorMessage,
    };
  }
}
