class AirportInfo {
  final int airportId;
  final String code;
  final String name;
  final String airportMessage;
  final String airportImage;

  AirportInfo({
    required this.airportId,
    required this.code,
    required this.name,
    required this.airportMessage,
    required this.airportImage,
  });

  factory AirportInfo.fromJson(Map<String, dynamic> json) {
    return AirportInfo(
      airportId: json['airportId'],
      code: json['code'],
      name: json['name'],
      airportMessage: json['airportMessage'],
      airportImage: json['airportImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'airportId': airportId,
      'code': code,
      'name': name,
      'airportMessage': airportMessage,
      'airportImage': airportImage,
    };
  }
}
