import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/settings/presentation/view_models/theme_cubit.dart";

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDarkMode =
            themeMode == ThemeMode.dark ||
            (themeMode == ThemeMode.system &&
                MediaQuery.platformBrightnessOf(context) == Brightness.dark);

        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: _iconColor(context, isDarkMode),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Account Settings",
              style: TextStyle(
                color: _textColor(context, isDarkMode),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: ListView(
            children: [
              _buildNameTile(context, isDarkMode),
              _buildInfoTile(context, isDarkMode),
              _buildEmailTile(context, isDarkMode),
              _buildPasswordTile(context, isDarkMode),
              _buildDeleteAccountTile(context, isDarkMode),
            ],
          ),
        );
      },
    );
  }

  // ================================================================
  // Helper Methods
  // ================================================================

  Color _iconColor(BuildContext context, bool isDark) =>
      isDark ? AppColors.darkIcon : AppColors.icon;

  Color _textColor(BuildContext context, bool isDark) =>
      isDark ? AppColors.darkText : AppColors.text;

  Color _subtitleColor(BuildContext context, bool isDark) =>
      isDark ? AppColors.darkTextGrey : AppColors.textGrey;

  Widget _buildDeleteAccountTile(BuildContext context, bool isDarkMode) {
    return ListTile(
      leading: Icon(Icons.delete_outline, color: Colors.red),
      title: Text(
        "Delete Account",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
      ),
      subtitle: Text(
        "Delete your BaybAI account",
        style: TextStyle(color: _subtitleColor(context, isDarkMode)),
      ),
      onTap: () {},
    );
  }

  Widget _buildNameTile(BuildContext context, bool isDarkMode) {
    return ListTile(
      leading: Icon(
        Icons.person_outline,
        color: _iconColor(context, isDarkMode),
      ),
      title: Text(
        "Account name",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _textColor(context, isDarkMode),
        ),
      ),
      subtitle: Text(
        "Edit your account name",
        style: TextStyle(color: _subtitleColor(context, isDarkMode)),
      ),
      onTap: () {},
    );
  }

  Widget _buildEmailTile(BuildContext context, bool isDarkMode) {
    return ListTile(
      leading: Icon(
        Icons.mail_outline,
        color: _iconColor(context, isDarkMode),
      ),
      title: Text(
        "Email address",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _textColor(context, isDarkMode),
        ),
      ),
      subtitle: Text(
        "Change your email address",
        style: TextStyle(color: _subtitleColor(context, isDarkMode)),
      ),
      onTap: () {},
    );
  }

  Widget _buildPasswordTile(BuildContext context, bool isDarkMode) {
    return ListTile(
      leading: Icon(
        Icons.lock_outline,
        color: _iconColor(context, isDarkMode),
      ),
      title: Text(
        "Password",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _textColor(context, isDarkMode),
        ),
      ),
      subtitle: Text(
        "Change your account password",
        style: TextStyle(color: _subtitleColor(context, isDarkMode)),
      ),
      onTap: () {},
    );
  }

  Widget _buildInfoTile(BuildContext context, bool isDarkMode) {
    return ListTile(
      leading: Icon(
        Icons.badge_outlined,
        color: _iconColor(context, isDarkMode),
      ),
      title: Text(
        "Personal Information",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _textColor(context, isDarkMode),
        ),
      ),
      subtitle: Text(
        "Edit your personal information",
        style: TextStyle(color: _subtitleColor(context, isDarkMode)),
      ),
      onTap: () {},
    );
  }
}
