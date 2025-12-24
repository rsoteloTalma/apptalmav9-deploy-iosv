class AppConfig {
  final int appConfigId;
  final String key;
  final String value;
  final String module;

  AppConfig({
    required this.appConfigId,
    required this.key,
    required this.value,
    required this.module,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appConfigId: json['appConfigId'],
      key: json['key'],
      value: json['value'],
      module: json['module'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appConfigId': appConfigId,
      'key': key,
      'value': value,
      'module': module,
    };
  }
}
