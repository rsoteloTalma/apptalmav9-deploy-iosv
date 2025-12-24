import 'package:flutter/material.dart';

IconData getIconFromString(String? iconName) {
  switch (iconName) {
    case 'search':
      return Icons.search;
    case 'person':
      return Icons.person;
    case 'airplane_ticket':
      return Icons.airplane_ticket;
    case 'luggage':
      return Icons.luggage;
    case 'qr_code_scanner':
      return Icons.qr_code_scanner;
    case 'check_circle':
      return Icons.check_circle;
    case 'flight_takeoff':
      return Icons.flight_takeoff;
    case 'qr_code':
      return Icons.qr_code;
    case 'flight':
      return Icons.flight;
    default:
      return Icons.circle; // Ícono por defecto
  }
}
