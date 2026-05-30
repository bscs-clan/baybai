import "package:baybai/core/theme/colors.dart";
import "package:flutter/material.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;

class AppAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;
  final shadcn.AvatarWidget? badge;

  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 44,
    this.backgroundColor,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final initials = shadcn.Avatar.getInitials(name);
    final color = backgroundColor ?? AppColors.primary.withValues(alpha: 0.14);

    if (imageUrl == null || imageUrl!.isEmpty) {
      return shadcn.Avatar(
        initials: initials,
        size: size,
        backgroundColor: color,
        badge: badge,
      );
    }

    return shadcn.Avatar.network(
      initials: initials,
      size: size,
      backgroundColor: color,
      badge: badge,
      photoUrl: imageUrl!,
    );
  }
}
