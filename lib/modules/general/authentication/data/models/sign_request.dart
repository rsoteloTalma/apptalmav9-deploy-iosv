class SignRequest {
  String user;
  String password;
  int appId;

  SignRequest({
    required this.user,
    required this.password,
    required this.appId
  });

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'password': password,
      'appId': appId,
    };
  }
}