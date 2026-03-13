import 'package:baybai/components/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      automaticallyImplyLeading: false,
      elevation: 0,
      shadowColor: AppColors.lightgrey,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 1,
      toolbarHeight: 88,
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24),
      actions: const [_ProfileButton(), SizedBox(width: 12), _SettingsButton()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(88);
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton();

  static const double _radius = 14;
  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(_radius)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Image.asset('assets/images/profile.jpg', fit: BoxFit.cover),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton();

  static const double _radius = 14;
  static const double _size = 48;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: AppColors.lightgrey, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(0, 4),
            blurRadius: 8,
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
