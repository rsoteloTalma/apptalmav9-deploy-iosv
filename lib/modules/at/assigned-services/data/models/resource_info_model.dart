import 'package:apptalma_v9/modules/at/assigned-services/data/models/flight_roles_model.dart';

class ResourceInformation {
  final int personId;
  final String employeeId;
  final String employeeName;
  final String companyIATACode;
  final String statusCoverageProcess;
  final bool statusCoverageProcessAlert;
  final List<FlightRoles> roles;

  ResourceInformation({
    required this.personId,
    required this.employeeId,
    required this.employeeName,
    required this.companyIATACode,
    required this.statusCoverageProcess,
    required this.statusCoverageProcessAlert,
    required this.roles,
  });

  factory ResourceInformation.fromJson(Map<String, dynamic> json) {
    return ResourceInformation(
      personId: json['personId'] ?? 0,
      employeeId: json['employeeId'] ?? "",
      employeeName: json['employeeName'] ?? "",
      companyIATACode: json['companyIATACode'] ?? "",
      statusCoverageProcess: json['statusCoverageProcess'] ?? "",
      statusCoverageProcessAlert: json['statusCoverageProcessAlert'] ?? false,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((item) => FlightRoles.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'personId': personId,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'companyIATACode': companyIATACode,
      'statusCoverageProcess': statusCoverageProcess,
      'statusCoverageProcessAlert': statusCoverageProcessAlert,
      'roles': roles.map((item) => item.toJson()).toList(),
    };
  }

  factory ResourceInformation.empty() {
    return ResourceInformation(
      personId: 0,
      employeeId: "",
      employeeName: "",
      companyIATACode: "",
      statusCoverageProcess: "",
      statusCoverageProcessAlert: false,
      roles: [],
    );
  }
}
