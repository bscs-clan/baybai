import 'package:baybai/components/theme/text.dart';
import 'package:flutter/material.dart';
import 'package:baybai/components/theme/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Explore extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const Explore({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppColors.dark,
                BlendMode.srcIn,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                title,
                style: AppTextStyles.normal,
              ),
            ),

            SvgPicture.asset('assets/icons/arrow-right.svg'),
          ],
        ),
      ),
    );
  }
}