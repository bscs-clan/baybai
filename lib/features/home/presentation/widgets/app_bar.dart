import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
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
      leadingWidth: 72,
      leading: Padding(
         padding: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
        child: SizedBox(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () {
                Navigator.pushNamed(context, "/user-profile");
              },
              child: ClipOval(
                child: Image.asset(
                  "assets/images/img_profile.jpg",
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
      actionsPadding: const EdgeInsets.only(right: 24),
      actions: [
        CustomIconButton(
          onTap: () {
            Navigator.pushNamed(context, "/settings");
          },
          size: 32,
          color: Colors.transparent,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedSettings01,
            size: 24,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkText
                : AppColors.icon,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64);
}