import "package:baybai/core/theme/colors.dart";
import "package:baybai/core/theme/text.dart";
import "package:baybai/shared/components/base/component_tokens.dart";
import "package:flutter/material.dart";
import "package:shadcn_flutter/shadcn_flutter.dart" as shadcn;

enum ButtonType { primary, secondary, outline, ghost }

enum ButtonSize { sm, md, lg }

class Button extends StatelessWidget {
  final String label;
  final IconData? leftIcon;
  final IconData? rightIcon;
  final VoidCallback? onTap;
  final ButtonType type;
  final ButtonSize size;
  final double? width;

  const Button({
    super.key,
    required this.label,
    this.leftIcon,
    this.rightIcon,
    this.onTap,
    this.type = ButtonType.primary,
    this.size = ButtonSize.md,
    this.width,
  });

  bool get _isEnabled => onTap != null;

  @override
  Widget build(BuildContext context) {
    final metrics = _ButtonMetrics.fromSize(size);

    final radius = BorderRadius.circular(metrics.borderRadius);

    final content = SizedBox(
      height: metrics.height,
      width: width,
      child: shadcn.Button(
        style: _buttonStyle(context, metrics, radius),
        onPressed: onTap,
        enabled: _isEnabled,
        leading: leftIcon == null
            ? null
            : Icon(
                leftIcon,
                size: metrics.iconSize,
                color: _foregroundColor(context),
              ),
        trailing: rightIcon == null
            ? null
            : Icon(
                rightIcon,
                size: metrics.iconSize,
                color: _foregroundColor(context),
              ),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: metrics.textStyle.copyWith(
              height: 1,
              color: _foregroundColor(context),
            ),
          ),
        ),
      ),
    );

    final button = Opacity(opacity: _isEnabled ? 1 : 0.6, child: content);

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: type == ButtonType.primary && _isEnabled
            ? ComponentShadow.primary
            : null,
        borderRadius: radius,
      ),
      child: button,
    );
  }

  shadcn.AbstractButtonStyle _buttonStyle(
    BuildContext context,
    _ButtonMetrics metrics,
    BorderRadius radius,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseStyle = switch (type) {
      ButtonType.primary => shadcn.ButtonStyle.primary(
        size: metrics.shadcnSize,
        density: shadcn.ButtonDensity.comfortable,
      ),
      ButtonType.secondary => shadcn.ButtonStyle.secondary(
        size: metrics.shadcnSize,
        density: shadcn.ButtonDensity.comfortable,
      ),
      ButtonType.outline => shadcn.ButtonStyle.outline(
        size: metrics.shadcnSize,
        density: shadcn.ButtonDensity.comfortable,
      ),
      ButtonType.ghost => shadcn.ButtonStyle.ghost(
        size: metrics.shadcnSize,
        density: shadcn.ButtonDensity.comfortable,
      ),
    };

    final background = switch (type) {
      ButtonType.primary =>
        _isEnabled
            ? AppColors.primary
            : AppColors.primary.withValues(alpha: 0.6),
      ButtonType.secondary => isDark ? AppColors.darkCompBg : AppColors.white,
      ButtonType.outline => Colors.transparent,
      ButtonType.ghost => Colors.transparent,
    };

    final border = switch (type) {
      ButtonType.outline => Border.all(
        color: isDark ? AppColors.darkWhite : AppColors.dark,
        width: 1,
      ),
      _ => null,
    };

    return baseStyle
        .withPadding(
          padding: EdgeInsets.symmetric(
            horizontal: metrics.horizontalPadding,
            vertical: metrics.verticalPadding,
          ),
        )
        .withBorderRadius(
          borderRadius: radius,
          hoverBorderRadius: radius,
          focusBorderRadius: radius,
          disabledBorderRadius: radius,
        )
        .withBackgroundColor(color: background)
        .withForegroundColor(color: _foregroundColor(context))
        .withBorder(border: border);
  }

  Color _foregroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (!_isEnabled) {
      return isDark
          ? AppColors.darkWhite.withValues(alpha: 0.6)
          : AppColors.text.withValues(alpha: 0.6);
    }

    return switch (type) {
      ButtonType.primary => isDark ? AppColors.text : AppColors.background,
      ButtonType.secondary => isDark ? AppColors.darkText : AppColors.text,
      ButtonType.outline => isDark ? AppColors.darkText : AppColors.text,
      ButtonType.ghost => isDark ? AppColors.darkText : AppColors.text,
    };
  }
}

class _ButtonMetrics {
  final double horizontalPadding;
  final double verticalPadding;
  final double iconSize;
  final double borderRadius;
  final double height;
  final TextStyle textStyle;
  final shadcn.ButtonSize shadcnSize;

  const _ButtonMetrics({
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSize,
    required this.borderRadius,
    required this.height,
    required this.textStyle,
    required this.shadcnSize,
  });

  factory _ButtonMetrics.fromSize(ButtonSize size) {
    final base = _ButtonMetrics(
      horizontalPadding: 18,
      verticalPadding: 12,
      iconSize: 20,
      borderRadius: ComponentRadius.md,
      height: 44,
      textStyle: AppTextStyles.wbody.copyWith(fontWeight: FontWeight.bold),
      shadcnSize: shadcn.ButtonSize.normal,
    );

    return switch (size) {
      ButtonSize.md => base,
      ButtonSize.sm => _ButtonMetrics(
        horizontalPadding: base.horizontalPadding - 4,
        verticalPadding: base.verticalPadding - 2,
        iconSize: 16,
        borderRadius: ComponentRadius.sm,
        height: 36,
        textStyle: AppTextStyles.wbody.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        shadcnSize: shadcn.ButtonSize.small,
      ),
      ButtonSize.lg => _ButtonMetrics(
        horizontalPadding: base.horizontalPadding + 6,
        verticalPadding: base.verticalPadding + 4,
        iconSize: 24,
        borderRadius: ComponentRadius.lg,
        height: 52,
        textStyle: AppTextStyles.wbody.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
        shadcnSize: shadcn.ButtonSize.large,
      ),
    };
  }
}
