import "package:flutter/material.dart";
import "package:baybai/shared/components/buttons/icon_button.dart";
import "package:baybai/shared/components/icons/solar_icon.dart";

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
        CustomIconButton(
          onTap: () {
            Navigator.pushNamed(context, "/user-profile");
          },
          child: Image.asset(
            "assets/images/img_profile.jpg",
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
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
