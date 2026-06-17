import "package:flutter/material.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/shared/components/buttons/icon_button.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;

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
      actions: [
        _ProfileImageButton(
          onTap: () {
            Navigator.pushNamed(context, "/user-profile");
          },
        ),
        const SizedBox(width: 12),
        CustomIconButton(
          onTap: () {
            Navigator.pushNamed(context, "/settings");
          },
          icon: AppSolarIcons.settings,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class _ProfileImageButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _ProfileImageButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 48,
      height: 48,
      decoration: ShapeDecoration(
        color: isDarkMode ? AppColors.darkBox : AppColors.box,
        shape: RoundedSuperellipseBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: shadcn.Button(
        onPressed: onTap,
        style: shadcn.ButtonStyle.ghostIcon(
          size: shadcn.ButtonSize.normal,
          shape: shadcn.ButtonShape.rectangle,
        ).withPadding(padding: EdgeInsets.zero),
        child: Image.asset(
          "assets/images/img_profile.jpg",
          width: 48,
          height: 48,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
