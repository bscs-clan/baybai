import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/settings/presentation/view_models/scan_settings_cubit.dart";

final List<_NavItem> items = [
  _NavItem(
    activeIcon: Icons.home_outlined,
    inactiveIcon: Icons.home_outlined,
    label: "Learn",
    index: 0,
  ),
  _NavItem(
    activeIcon: Icons.document_scanner_outlined,
    inactiveIcon: Icons.document_scanner_outlined,
    label: "Scan",
    index: 1,
  ),
  _NavItem(
    activeIcon: Icons.swap_horiz_outlined,
    inactiveIcon: Icons.swap_horiz_outlined,
    label: "Convert",
    index: 2,
  ),
  _NavItem(
    activeIcon: Icons.storage_outlined,
    inactiveIcon: Icons.storage_outlined,
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
            color: AppColors.grey1,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 32,
                spreadRadius: 8,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Row(
            children: visibleItems.map((item) {
              final bool isSelected = selectedIndex == item.index;

              final Color iconColor = isSelected
                  ? AppColors.primary
                  : (isDarkMode ? AppColors.white : AppColors.grey12);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(item.index),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.inactiveIcon,
                          size: 24,
                          color: iconColor,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body.copyWith(
                            color: iconColor,
                            fontSize: 12,
                          ),
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
