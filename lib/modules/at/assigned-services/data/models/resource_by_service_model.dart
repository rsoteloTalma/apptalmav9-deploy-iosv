import "dart:convert";
import 'package:apptalma_v9/modules/at/assigned-services/data/models/flight_roles_model.dart';

class ResourceByService {
  final int serviceHeaderId;
  final int personId;
  final String employeeId;
  final String employeeName;
  final String companyIATACode;
  final String position;
  final String readingDate;
  final String readingEndDate;
  final String statusCoverageProcess;
  final List<FlightRoles> roles;

  ResourceByService({
    required this.serviceHeaderId,
    required this.personId,
    required this.employeeId,
    required this.employeeName,
    required this.companyIATACode,
    required this.position,
    required this.readingDate,
    required this.readingEndDate,
    required this.statusCoverageProcess,
    required this.roles,
  });

  factory ResourceByService.fromJson(Map<String, dynamic> json) {
    return ResourceByService(
      serviceHeaderId: json["serviceHeaderId"] ?? 0,
      personId: json["personId"] ?? 0,
      employeeId: json["employeeId"] ?? "",
      employeeName: json["employeeName"] ?? "",
      companyIATACode: json["companyIATACode"] ?? "",
      position: json["position"] ?? "",
      readingDate: json["readingDate"] ?? "",
      readingEndDate: json["readingEndDate"] ?? "",
      statusCoverageProcess: json["statusCoverageProcess"] ?? "",
      roles: (json['rolJson'] as List<dynamic>?)
              ?.map((item) => FlightRoles.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "serviceHeaderId": serviceHeaderId,
      "personId": personId,
      "employeeId": employeeId,
      "employeeName": employeeName,
      "companyIATACode": companyIATACode,
      "position": position,
      "readingDate": readingDate,
      "readingEndDate": readingEndDate,
      "statusCoverageProcess": statusCoverageProcess,
      'roles': roles.map((item) => item.toJson()).toList(),
    };
  }

  static List<ResourceByService> listFromJson(String str) {
    final data = json.decode(str) as List;
    return data.map((item) => ResourceByService.fromJson(item)).toList();
  }

  static String listToJson(List<ResourceByService> list) {
    final data = list.map((item) => item.toJson()).toList();
    return json.encode(data);
  }
}

class ProcessResult {
  final bool state;
  final String message;

  ProcessResult({required this.state, required this.message});
}
