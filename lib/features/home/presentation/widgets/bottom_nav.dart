import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/settings/presentation/view_models/scan_settings_cubit.dart";

final List<_NavItem> items = [
  _NavItem(
    activeIcon: HugeIcons.strokeRoundedHome01,
    inactiveIcon: HugeIcons.strokeRoundedHome01,
    label: "Learn",
    index: 0,
  ),
  _NavItem(
    activeIcon: HugeIcons.strokeRoundedAiScan,
    inactiveIcon: HugeIcons.strokeRoundedAiScan,
    label: "Scan",
    index: 1,
  ),
  _NavItem(
    activeIcon: HugeIcons.strokeRoundedArrowLeftRight,
    inactiveIcon: HugeIcons.strokeRoundedArrowLeftRight,
    label: "Convert",
    index: 2,
  ),
  _NavItem(
    activeIcon: HugeIcons.strokeRoundedDatabase01,
    inactiveIcon: HugeIcons.strokeRoundedDatabase01,
    label: "Datasets",
    index: 3,
    requiresDeveloperMode: true,
  ),
];

class _NavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final int index;
  final bool requiresDeveloperMode;

  const _NavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.index,
    this.requiresDeveloperMode = false,
  });
}

class Navbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const Navbar({super.key, required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final developerModeEnabled = context
        .watch<ScanSettingsCubit>()
        .state
        .developerModeEnabled;

    final visibleItems = items.where((item) {
      if (!item.requiresDeveloperMode) return true;
      return developerModeEnabled;
    }).toList();

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.background,
            border: const Border(top: BorderSide(color: AppColors.grey1)),
          ),
          child: Row(
            children: visibleItems.map((item) {
              final bool isSelected = selectedIndex == item.index;

              final Color iconColor = isSelected
                  ? AppColors.blue6
                  : (isDarkMode ? AppColors.white : AppColors.grey5);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(item.index),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: item.inactiveIcon,
                          size: 24,
                          color: iconColor,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
