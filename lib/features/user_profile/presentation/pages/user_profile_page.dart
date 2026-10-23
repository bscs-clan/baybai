import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/features/auth/domain/entities/account_profile.dart";
import "package:baybai/features/auth/domain/usecases/get_account_profile.dart";
import "package:baybai/features/auth/domain/usecases/sign_out.dart";
import "package:baybai/features/auth/domain/usecases/upload_profile_picture.dart";
import "package:baybai/injection_container.dart";
import "package:flutter/material.dart";
import "package:hugeicons/hugeicons.dart";
import "package:image_picker/image_picker.dart";

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final Future<AccountProfile?> _profileFuture;
  bool _isSigningOut = false;
  bool _isUploadingPicture = false;
  String? _uploadedPictureUrl;

  @override
  void initState() {
    super.initState();
    _profileFuture = serviceLoc<GetAccountProfile>()();
  }

  Future<void> _signOut() async {
    setState(() => _isSigningOut = true);
    await serviceLoc<SignOut>()();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, "/login", (_) => false);
  }

  Future<void> _selectProfilePicture() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null || !mounted) return;
    setState(() => _isUploadingPicture = true);
    try {
      final imageUrl = await serviceLoc<UploadProfilePicture>()(image.path);
      if (mounted) setState(() => _uploadedPictureUrl = imageUrl);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Could not update profile picture: $error",
              style: AppTextStyles.regularSm,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPicture = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppColors.gray10 : AppColors.gray100;
    final subtitleColor = isDarkMode ? AppColors.gray40 : AppColors.gray70;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.gray100 : AppColors.bg,
      appBar: AppBar(
        leading: IconButton(
          icon: HugeIcon(
            icon: HugeIcons.strokeRoundedArrowLeft02,
            color: textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<AccountProfile?>(
        future: _profileFuture,
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final profilePictureUrl =
              _uploadedPictureUrl ?? profile?.profilePictureUrl;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _isUploadingPicture
                              ? null
                              : _selectProfilePicture,
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: Stack(
                              children: [
                                ClipOval(
                                  child: SizedBox.expand(
                                    child: profilePictureUrl == null
                                        ? _defaultProfileImage(
                                            isDarkMode,
                                            subtitleColor,
                                          )
                                        : Image.network(
                                            profilePictureUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    _defaultProfileImage(
                                                      isDarkMode,
                                                      subtitleColor,
                                                    ),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary60,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDarkMode
                                            ? AppColors.gray100
                                            : AppColors.bg,
                                        width: 2,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: _isUploadingPicture
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.bg,
                                            ),
                                          )
                                        : const HugeIcon(
                                            icon:
                                                HugeIcons.strokeRoundedCamera01,
                                            size: 14,
                                            color: AppColors.bg,
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile?.fullName ?? "User Account",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.boldLg.copyWith(
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile?.email ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.regularSm.copyWith(
                                  color: subtitleColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              const Divider(thickness: 12, color: AppColors.gray10),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Account",
                      style: AppTextStyles.boldMd.copyWith(color: textColor),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: HugeIcon(
                        icon: HugeIcons.strokeRoundedAccountSetting01,
                        color: textColor,
                        size: 24,
                      ),
                      title: Text(
                        "Account Settings",
                        style: AppTextStyles.regularSm.copyWith(
                          color: textColor,
                        ),
                      ),
                      trailing: HugeIcon(
                        icon: HugeIcons.strokeRoundedArrowRight02,
                        color: subtitleColor,
                        size: 24,
                      ),
                      onTap: () =>
                          Navigator.pushNamed(context, "/account-settings"),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const HugeIcon(
                        icon: HugeIcons.strokeRoundedLogout01,
                        color: AppColors.error,
                        size: 24,
                      ),
                      title: Text("Logout",
                        style: AppTextStyles.regularSm.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                      enabled: !_isSigningOut,
                      onTap: _isSigningOut ? null : _signOut,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _defaultProfileImage(bool isDarkMode, Color iconColor) {
    return Container(
      color: isDarkMode ? AppColors.gray80 : AppColors.gray20,
      alignment: Alignment.center,
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedUserCircle,
        size: 44,
        color: iconColor,
      ),
    );
  }
}
