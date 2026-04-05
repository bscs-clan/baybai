import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/core/configs/theme/text.dart";

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const Navbar({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final items = [
      {"asset": "assets/icons/learn.svg", "label": "Learn", "index": 0},
      {"asset": "assets/icons/scanner.svg", "label": "Scan", "index": 1},
      {
        "asset": "assets/icons/transliteration.svg",
        "label": "Convert",
        "index": 2,
      },
    ];

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.darkBox : AppColors.box,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 32,
              spreadRadius: 8,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Row(
          children: items.map((item) => _navItem(context, item)).toList(),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, Map<String, dynamic> item) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final int index = item["index"];
    final String asset = item["asset"];
    final String label = item["label"];
    final bool isSelected = selectedIndex == index;

    final Color iconColor = isSelected
        ? AppColors.primary
        : (isDarkMode ? AppColors.darkIcon : AppColors.icon);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                asset,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.mbody.copyWith(color: iconColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
