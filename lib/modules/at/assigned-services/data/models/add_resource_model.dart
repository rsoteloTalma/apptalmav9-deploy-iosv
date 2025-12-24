import 'package:apptalma_v9/modules/at/assigned-services/data/models/flight_roles_model.dart';

class AddResource {
  final int userId;
  final String serviceHeaderId;
  final String employeeId;
  final String processStatus;
  final String processName;
  final int valueDataId;
  final int stageTypeId;
  final List<FlightRoles> roles;

  AddResource({
    required this.userId,
    required this.serviceHeaderId,
    required this.employeeId,
    required this.processStatus,
    required this.processName,
    required this.valueDataId,
    required this.stageTypeId,
    required this.roles,
  });

  factory AddResource.fromJson(Map<String, dynamic> json) {
    return AddResource(
      userId: json['userId'] ?? 0,
      serviceHeaderId: json['serviceHeaderId'] ?? 0,
      employeeId: json['employeeId'] ?? "",
      processStatus: json['processStatus'] ?? "",
      processName: json['processName'] ?? "",
      valueDataId: json['valueDataId'] ?? 0,
      stageTypeId: json['stageTypeId'] ?? 0,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((e) => FlightRoles.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'serviceHeaderId': serviceHeaderId,
      'employeeId': employeeId,
      'processStatus': processStatus,
      'processName': processName,
      'valueDataId': valueDataId,
      'stageTypeId': stageTypeId,
      'roles': roles.map((e) => e.toJson()).toList(),
    };
  }
}
