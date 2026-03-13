import 'package:baybai/components/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const Navbar({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final List<String> icons = [
      'assets/icons/home.svg',
      'assets/icons/learn.svg',
      'assets/icons/practice.svg',
      'assets/icons/game.svg',
      'assets/icons/scan.svg',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.lightgrey, width: 1),
        ),
      ),
      height: 80,
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: Alignment(
              -1.0 + (selectedIndex * 2 / (icons.length - 1)), 
              0,
            ),
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastLinearToSlowEaseIn,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.lightprimary,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              icons.length,
              (index) {
                final bool isSelected = selectedIndex == index;
                final String iconPath = isSelected
                    ? icons[index].replaceFirst('.svg', '_bold.svg')
                    : icons[index];

                return SizedBox(
                  width: 48,
                  height: 48,
                  child: IconButton(
                    onPressed: () => onTap(index),
                    icon: SvgPicture.asset(
                      iconPath,
                      width: 24,
                      height: 24,
                      colorFilter: ColorFilter.mode(
                        isSelected ? AppColors.primary : AppColors.mediumgrey,
                        BlendMode.srcIn,
                      ),
                    ),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}