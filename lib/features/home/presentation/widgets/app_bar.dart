import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/auth/domain/entities/account_profile.dart";
import "package:baybai/features/auth/domain/usecases/get_account_profile.dart";
import "package:baybai/injection_container.dart";
import "package:baybai/shared/components/buttons/icon_button.dart";

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(64);
}

class _CustomAppBarState extends State<CustomAppBar> {
  late Future<AccountProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = serviceLoc<GetAccountProfile>()();
  }

  Future<void> _openProfile() async {
    await Navigator.pushNamed(context, "/user-profile");
    if (!mounted) return;
    setState(() => _profileFuture = serviceLoc<GetAccountProfile>()());
  }

  Widget _profileAvatar(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppColors.gray80 : AppColors.gray20;
    final foregroundColor = isDarkMode ? AppColors.gray40 : AppColors.gray70;

    return FutureBuilder<AccountProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final imageUrl = snapshot.data?.profilePictureUrl;
        return ClipOval(
          child: imageUrl == null
              ? CircleAvatar(
                  radius: 20,
                  backgroundColor: backgroundColor,
                  child: Icon(Icons.person, size: 24, color: foregroundColor),
                )
              : Image.network(
                  imageUrl,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => CircleAvatar(
                    radius: 20,
                    backgroundColor: backgroundColor,
                    child: Icon(Icons.person, size: 24, color: foregroundColor),
                  ),
                ),
        );
      },
    );
  }

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
              onTap: _openProfile,
              child: _profileAvatar(context),
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
          size: 24,
          color: Colors.transparent,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedSettings01,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.gray10
                : AppColors.gray100,
          ),
        ),
      ],
    );
  }
}
