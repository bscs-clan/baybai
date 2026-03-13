import 'package:baybai/components/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {

  static TextStyle heading = GoogleFonts.montserrat(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
  );

  static TextStyle body = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.mediumgrey,
  );
  static TextStyle bigheader = GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.dark,
  );

  static TextStyle caption = GoogleFonts.montserrat(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.disable,
  );
   static TextStyle normal = GoogleFonts.montserrat(
    fontSize: 12,
    color: AppColors.dark,
  );
   static TextStyle xnormal = GoogleFonts.montserrat(
    fontSize: 14,
    color: AppColors.dark,
  );
  static TextStyle mininormal = GoogleFonts.montserrat(
    fontSize: 10,
    color: AppColors.dark,
  );
  static TextStyle boldnormal = GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static TextStyle button = GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

}