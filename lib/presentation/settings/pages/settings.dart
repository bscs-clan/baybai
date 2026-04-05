import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_custom_tabs/flutter_custom_tabs.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:flutter_tabler_icons/flutter_tabler_icons.dart";
import "package:baybai/core/configs/theme/colors.dart";
import "package:baybai/presentation/settings/bloc/theme_cubit.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(TablerIcons.arrow_left),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Settings"),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {},
            leading: Icon(TablerIcons.moon),
            title: Text("Dark Mode"),
            subtitle: Text("App theme"),
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (value) {
                _isDarkMode
                    ? context.read<ThemeCubit>().updateTheme(ThemeMode.light)
                    : context.read<ThemeCubit>().updateTheme(ThemeMode.dark);
                setState(() {
                  _isDarkMode = value;
                });
              },
              activeThumbColor: AppColors.primary,
            ),
          ),
          ListTile(
            onTap: () {
              _launchUrl("https://baybai.org");
            },
            leading: Icon(TablerIcons.scale),
            title: Text("Terms & Conditions"),
            subtitle: Text("April 23, 2025"),
          ),
          ListTile(
            onTap: () {
              _launchUrl("https://baybai.org");
            },
            leading: Icon(TablerIcons.shield_lock),
            title: Text("Privacy policy"),
            subtitle: Text("April 23, 2025"),
          ),
          ListTile(
            onTap: () {
              _launchUrl("${dotenv.env["WEB_HOST"]}/about");
            },
            leading: Icon(TablerIcons.info_circle),
            title: Text("About Us"),
            subtitle: Text("App version ${dotenv.env["APP_VERSION"]}"),
          ),
        ],
      ),
    );
  }
}

void _launchUrl(url) async {
  try {
    await launchUrl(
      Uri.parse(url),
      customTabsOptions: CustomTabsOptions(
        colorSchemes: CustomTabsColorSchemes.defaults(
          toolbarColor: AppColors.background,
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
    debugPrint(e.toString());
  }
}
