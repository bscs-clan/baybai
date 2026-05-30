import "package:flutter/material.dart";
import "package:solar_icons/solar_icons.dart";
import "package:baybai/shared/components/buttons/icon_button.dart";

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
            Navigator.pushNamed(context, "/settings");
          },
          icon: SolarIconsOutline.settings,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}
