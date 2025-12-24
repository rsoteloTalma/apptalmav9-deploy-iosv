import 'package:apptalma_v9/core/models/airport.dart';
import 'package:apptalma_v9/core/models/user_roles.dart';
class User {
  final String token;
  final int userCioId;
  final String employeeId;
  final bool isActive;
  final bool passwordChange;
  final String userName;
  final String name;
  final String lastName;
  final String email;
  final String employeePosition;
  final int? operationAirportId;
  final List<UserRoles> roles;
  final List<Airport> setAirports;

  User({
    required this.token,
    required this.userCioId,
    required this.employeeId,
    required this.isActive,
    required this.passwordChange,
    required this.userName,
    required this.name,
    required this.lastName,
    required this.email,
    required this.employeePosition,
    this.operationAirportId,
    required this.roles,
    required this.setAirports,
  });

  // Deserialización desde JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'],
      userCioId: json['userCioId'],
      employeeId: json['employeeId'],
      isActive: json['isActive'],
      passwordChange: json['passwordChange'],
      userName: json['userName'],
      name: json['name'],
      lastName: json['lastName'],
      email: json['email'],
      employeePosition: json['employeePosition'],
      operationAirportId: json['operationAirportId'],
      roles: (json['roles'] as List)
          .map((role) => UserRoles.fromJson(role))
          .toList(),
      setAirports: (json['setAirports'] as List)
          .map((airport) => Airport.fromJson(airport))
          .toList(),
    );
  }

  // Serialización a JSON
  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userCioId': userCioId,
      'employeeId': employeeId,
      'isActive': isActive,
      'passwordChange': passwordChange,
      'userName': userName,
      'name': name,
      'lastName': lastName,
      'email': email,
      'employeePosition': employeePosition,
      'operationAirportId': operationAirportId,
      'roles': roles.map((role) => role.toJson()).toList(),
      'setAirports': setAirports.map((airport) => airport.toJson()).toList(),
    };
  }
  
}


