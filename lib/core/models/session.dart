import 'package:apptalma_v9/core/models/user.dart';

class Session {
  User user;
  String enviroment;
  String appVersion;

  Session(
      {required this.user, required this.enviroment, required this.appVersion});

  // Serialización a JSON
  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(), // Serializa el objeto User utilizando su toJson
      'enviroment': enviroment,
      'appVersion': appVersion,
    };
  }
}
