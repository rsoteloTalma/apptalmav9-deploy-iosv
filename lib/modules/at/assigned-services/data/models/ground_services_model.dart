List<GroundServices> groundServicesToList(List<dynamic> jsonList) {
  return jsonList.map((e) => GroundServices.fromJson(e)).toList();
}

List<Map<String, dynamic>> groundServicesToJsonList(
    List<GroundServices> services) {
  return services.map((e) => e.toJson()).toList();
}

class GroundServices {
  final String serviceHeaderId;
  final int personId;
  final String origin;
  final String incomingFlight;
  final String destiny;
  final String outgoingFlight;
  final String company;
  final String sta;
  final String eta;
  final String ata;
  final String vta;
  final String std;
  final String etd;
  final String vtd;
  final String flightNotes;
  final String gate;
  final int gateId;
  final String gateOut;
  final int gateIdOut;
  final String aircraft;
  final int serviceTypeStageId;
  final String serviceTypeStage;
  final String serviceTypeStageOut;
  final int serviceStage;
  final int serviceStageOut;
  final int sequenceStage;
  final int sequenceStageOut;

  GroundServices(
      {required this.serviceHeaderId,
      required this.personId,
      required this.origin,
      required this.incomingFlight,
      required this.destiny,
      required this.outgoingFlight,
      required this.company,
      required this.sta,
      required this.eta,
      required this.ata,
      required this.vta,
      required this.std,
      required this.etd,
      required this.vtd,
      required this.serviceTypeStageId,
      required this.flightNotes,
      required this.gate,
      required this.gateId,
      required this.gateOut,
      required this.gateIdOut,
      required this.aircraft,
      required this.serviceTypeStage,
      required this.serviceTypeStageOut,
      required this.serviceStage,
      required this.serviceStageOut,
      required this.sequenceStage,
      required this.sequenceStageOut});

  factory GroundServices.fromJson(Map<String, dynamic> json) {
    return GroundServices(
        serviceHeaderId: json['serviceHeaderId'] ?? '',
        personId: json['personId'] ?? 0,
        origin: json['origin'] ?? '',
        incomingFlight: json['incomingFlight'] ?? '',
        destiny: json['destiny'] ?? '',
        outgoingFlight: json['outgoingFlight'] ?? '',
        company: json['company'] ?? '',
        sta: json['sta'] ?? '',
        eta: json['eta'] ?? '',
        ata: json['ata'] ?? '',
        vta: (json['ata']?.isNotEmpty ?? false)
            ? json['ata']
            : (json['eta']?.isNotEmpty ?? false)
                ? json['eta']
                : json['sta'],
        std: json['std'] ?? '',
        etd: json['etd'] ?? '',
        vtd: (json['etd']?.isNotEmpty ?? false) ? json['etd'] : json['std'],
        flightNotes: json['flightNotes'] ?? '',
        gate: json['gate'] ?? '',
        gateId: json['gateId'] ?? 0,
        gateOut: json['gateOut'] ?? "",
        gateIdOut: json['gateIdOut'] ?? 0,
        aircraft: json['aircraft'] ?? "",
        serviceTypeStageId: json['serviceTypeStageId'] ?? 0,
        serviceTypeStage: json['serviceTypeStage'] ?? "",
        serviceTypeStageOut: json['serviceTypeStageOut'] ?? "",
        serviceStage: json['serviceStage'] ?? 0,
        serviceStageOut: json['serviceStageOut'] ?? 0,
        sequenceStage: json['sequenceStage'] ?? 0,
        sequenceStageOut: json['sequenceStageOut'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {
      'serviceHeaderId': serviceHeaderId,
      'personId': personId,
      'origin': origin,
      'incomingFlight': incomingFlight,
      'destiny': destiny,
      'outgoingFlight': outgoingFlight,
      'company': company,
      'sta': sta,
      'eta': eta,
      'ata': ata,
      'vta': vta,
      'std': std,
      'etd': etd,
      'vtd': vtd,
      'serviceTypeStageId': serviceTypeStageId,
      'flightNotes': flightNotes,
      'gate': gate,
      "gateId": gateId,
      "gateOut": gateOut,
      "gateIdOut": gateIdOut,
      "aircraft": aircraft,
      "serviceTypeStage": serviceTypeStage,
      "serviceTypeStageOut": serviceTypeStageOut,
      "serviceStage": serviceStage,
      "serviceStageOut": serviceStageOut,
      "sequenceStage": sequenceStage,
      "sequenceStageOut": sequenceStageOut
    };
  }
}
