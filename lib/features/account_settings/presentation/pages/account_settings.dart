import "package:flutter/material.dart";
import "package:solar_icons/solar_icons.dart";
import "package:baybai/core/theme/colors.dart";

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            SolarIconsOutline.arrowLeft,
            color: isDarkMode ? AppColors.darkIcon : AppColors.icon,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Account Settings",
          style: TextStyle(
            color: isDarkMode ? AppColors.darkText : AppColors.text,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(child: Text("Account Settings")),
    );
  }
}
