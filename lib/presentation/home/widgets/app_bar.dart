import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:baybai/core/configs/theme/colors.dart";

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      toolbarHeight: 64,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24),
      actions: const [_SettingsButton()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}


class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/settings"),
      child: Container(
        width: _size,
        height: _size,
        decoration: ShapeDecoration(
          color: isDarkMode ? AppColors.darkBox : AppColors.box,
          shape: RoundedSuperellipseBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: SvgPicture.asset(
            "assets/icons/setting.svg",
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isDarkMode ? AppColors.darkIcon : AppColors.icon,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }
}
