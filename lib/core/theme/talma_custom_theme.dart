import 'package:flutter/material.dart';
import 'package:apptalma_v9/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

extension CustomTextTheme on TextTheme {
  TextStyle get atFlightNumber => GoogleFonts.roboto(
        fontSize: 25,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryColor,
      ).copyWith(
        height: 1.0,
      );

  TextStyle get upcomingFlight => GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.green,
      ).copyWith(
        height: 1.0,
      );

  TextStyle get atFlightIata => GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black45,
      ).copyWith(
        height: 1.0,
      );

  TextStyle get atFlightTime => GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ).copyWith(
        height: 1.0,
      );

  TextStyle get atParking => GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.grey,
      ).copyWith(
        height: 1.0,
      );

  // Standard
  TextStyle get disabledTitleLg => GoogleFonts.roboto(
        fontSize: 25,
        fontWeight: FontWeight.w300,
        color: Colors.grey,
      ).copyWith(
        height: 1.0,
      );

  TextStyle get disabledTitleMd => GoogleFonts.roboto(
        fontSize: 20,
        fontWeight: FontWeight.w300,
        color: Colors.grey,
      ).copyWith(
        height: 1.0,
      );
}
