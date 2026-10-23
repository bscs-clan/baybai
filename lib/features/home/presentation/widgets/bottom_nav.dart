import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/settings/presentation/view_models/scan_settings_cubit.dart";

final List<_NavItem> items = [
  _NavItem(
    activeIcon: HugeIcons.strokeRoundedHome03,
    inactiveIcon: HugeIcons.strokeRoundedHome03,
    label: "Learn",
    index: 0,
  ),
  _NavItem(
    activeIcon: HugeIcons.strokeRounded3DView,
    inactiveIcon: HugeIcons.strokeRounded3DView,
    label: "Scan",
    index: 1,
  ),
  _NavItem(
    activeIcon: HugeIcons.strokeRoundedArrowDataTransferHorizontal,
    inactiveIcon: HugeIcons.strokeRoundedArrowDataTransferHorizontal,
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
  final List<List<dynamic>> activeIcon;
  final List<List<dynamic>> inactiveIcon;
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
            color: isDarkMode ? AppColors.gray100 : AppColors.bg,
            border: Border(
              top: BorderSide(
                color: isDarkMode ? AppColors.gray80 : AppColors.gray10,
              ),
            ),
          ),
          child: Row(
            children: visibleItems.map((item) {
              final bool isSelected = selectedIndex == item.index;

              final Color iconColor = isSelected
                  ? AppColors.primary60
                  : (isDarkMode ? AppColors.gray40 : AppColors.gray60);

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
