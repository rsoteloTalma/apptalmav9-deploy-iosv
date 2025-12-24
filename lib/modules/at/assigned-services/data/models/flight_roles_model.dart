class FlightRoles {
  final String roleName;
  final String? statusCoverageRole;
  final bool statusCoverageRoleAlert;
  final bool isCheck;

  FlightRoles({
    required this.roleName,
    this.statusCoverageRole,
    required this.statusCoverageRoleAlert,
    required this.isCheck,
  });

  factory FlightRoles.fromJson(Map<String, dynamic> json) {
    return FlightRoles(
      roleName: json['roleName'] ?? "",
      statusCoverageRole: json['statusCoverageRole'] ?? "",
      statusCoverageRoleAlert: json['statusCoverageRoleAlert'] ?? false,
      isCheck: json['isCheck'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'roleName': roleName,
        'statusCoverageRole': statusCoverageRole,
        'statusCoverageRoleAlert': statusCoverageRoleAlert,
        'isCheck': isCheck,
      };

  FlightRoles copyWith({
    String? roleName,
    String? statusCoverageRole,
    bool? statusCoverageRoleAlert,
    bool? isCheck,
  }) {
    return FlightRoles(
      roleName: roleName ?? this.roleName,
      statusCoverageRole: statusCoverageRole ?? this.statusCoverageRole,
      statusCoverageRoleAlert:
          statusCoverageRoleAlert ?? this.statusCoverageRoleAlert,
      isCheck: isCheck ?? this.isCheck,
    );
  }
}
