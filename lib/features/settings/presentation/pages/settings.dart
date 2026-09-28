import "package:flutter/material.dart";
import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_custom_tabs/flutter_custom_tabs.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:baybai/core/theme/colors.dart";
import "package:baybai/features/settings/presentation/view_models/scan_settings_cubit.dart";
import "package:baybai/features/settings/presentation/view_models/theme_cubit.dart";

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
              "Settings",
              style: TextStyle(
                color: _textColor(context, isDarkMode),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: ListView(
            children: [
              _buildAccountTile(context, isDarkMode),
              _buildThemeTile(context, isDarkMode),
              _buildDeveloperTile(context, isDarkMode),
              _buildCrashlyticsTile(context, isDarkMode),
              _buildLinkTile(
                context,
                isDarkMode,
                title: "Terms & Conditions",
                subtitle: "April 23, 2025",
                icon: Icons.checklist,
                url: "https://baybai.org",
              ),
              _buildLinkTile(
                context,
                isDarkMode,
                title: "Privacy Policy",
                subtitle: "April 23, 2025",
                icon: Icons.security,
                url: "https://baybai.org",
              ),
              _buildLinkTile(
                context,
                isDarkMode,
                title: "About Us",
                subtitle: "App version ${dotenv.env["APP_VERSION"] ?? '1.0.0'}",
                icon: Icons.info_outline,
                url: dotenv.env["WEB_HOST"] ?? "https://baybai.org",
              ),
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

  Widget _buildThemeTile(BuildContext context, bool isDarkMode) {
    return ListTile(
      leading: Icon(
        Icons.dark_mode,
        color: _iconColor(context, isDarkMode),
      ),
      title: Text(
        "Dark Mode",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _textColor(context, isDarkMode),
        ),
      ),
      subtitle: Text(
        "App theme",
        style: TextStyle(color: _subtitleColor(context, isDarkMode)),
      ),
      trailing: Switch(
        value: isDarkMode,
        activeThumbColor: AppColors.primary,
        onChanged: (value) {
          final cubit = context.read<ThemeCubit>();
          cubit.updateTheme(value ? ThemeMode.dark : ThemeMode.light);
        },
      ),
    );
  }

  Widget _buildAccountTile(BuildContext context, bool isDarkMode) {
    return ListTile(
      leading: Icon(
        Icons.account_circle,
        color: _iconColor(context, isDarkMode),
      ),
      title: Text(
        "Account Settings",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _textColor(context, isDarkMode),
        ),
      ),
      subtitle: Text(
        "Manage your account",
        style: TextStyle(color: _subtitleColor(context, isDarkMode)),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: _iconColor(context, isDarkMode),
        size: 20,
      ),
      onTap: () {
        Navigator.pushNamed(context, "/account-settings");
      },
    );
  }

  Widget _buildDeveloperTile(BuildContext context, bool isDarkMode) {
    final developerMode = context
        .watch<ScanSettingsCubit>()
        .state
        .developerModeEnabled;

    return ListTile(
      leading: Icon(
        Icons.code,
        color: _iconColor(context, isDarkMode),
      ),
      title: Text(
        'Developers Mode',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _textColor(context, isDarkMode),
        ),
      ),
      subtitle: Text(
        'Let AI learns from your corrections. Enable to label detected texts in scan.',
        style: TextStyle(color: _subtitleColor(context, isDarkMode)),
      ),
      trailing: Switch(
        value: developerMode,
        activeThumbColor: AppColors.primary,
        onChanged: (value) {
          context.read<ScanSettingsCubit>().setDeveloperMode(value);
        },
      ),
    );
  }

  Widget _buildCrashlyticsTile(BuildContext context, bool isDarkMode) {
    return ListTile(
      leading: Icon(
        Icons.bug_report,
        color: _iconColor(context, isDarkMode),
      ),
      title: Text(
        "Send Crashlytics",
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _textColor(context, isDarkMode),
        ),
      ),
      subtitle: Text(
        "Help us improve the app by sending crash reports.",
        style: TextStyle(color: _subtitleColor(context, isDarkMode)),
      ),
      trailing: Switch(
        value: true,
        activeThumbColor: AppColors.primary,
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildLinkTile(
    BuildContext context,
    bool isDarkMode, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String url,
  }) {
    return ListTile(
      leading: Icon(icon, color: _iconColor(context, isDarkMode)),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: _textColor(context, isDarkMode),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: _subtitleColor(context, isDarkMode)),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: _iconColor(context, isDarkMode),
        size: 20,
      ),
      onTap: () => _launchUrl(context, url),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          shareState: CustomTabsShareState.off,
          urlBarHidingEnabled: true,
          showTitle: true,
          closeButton: CustomTabsCloseButton(
            icon: CustomTabsCloseButtonIcons.back,
          ),
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Could not launch $url: $e');
      }
    }
  }
}
