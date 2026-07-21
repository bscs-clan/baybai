import "package:flutter/material.dart";
import "package:google_fonts/google_fonts.dart";
import "package:baybai/core/theme/colors.dart";

class AppTextStyles {
  static TextStyle heading = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
  );

  static TextStyle body = GoogleFonts.inter(
    fontSize: 14,
    color: AppColors.dark,
  );
  static TextStyle wbody = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );
  static TextStyle bigbody = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
  );
  static TextStyle title = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.dark,
  );
  static TextStyle bodywhite = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );
}
