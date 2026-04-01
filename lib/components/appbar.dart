import 'package:baybai/components/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      automaticallyImplyLeading: false,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 1,
      toolbarHeight: 64,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24),
      actions: const [_ProfileButton(), SizedBox(width: 8), _SettingsButton()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton();

  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
     child: ClipRSuperellipse( 
        borderRadius: BorderRadius.circular(16),
        child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
     decoration: ShapeDecoration(
        color: AppColors.box,
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
      child: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/setting.svg',
          width: 24,
          height: 24,
          colorFilter: const ColorFilter.mode(AppColors.dark, BlendMode.srcIn),
        ),
        onPressed: () {},
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
    );
  }
}
