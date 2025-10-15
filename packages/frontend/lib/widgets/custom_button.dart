import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonStyle? style;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final BorderSide? side;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style,
    this.icon,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.side,
  }) : super(key: key);

  /// Botón primario (elevated)
  const CustomButton.primary({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style,
    this.icon,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.side,
  }) : super(key: key);

  /// Botón secundario (outlined)
  const CustomButton.secondary({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style,
    this.icon,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.side,
  }) : super(key: key);

  /// Botón de texto
  const CustomButton.text({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style,
    this.icon,
    this.padding,
    this.width,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.side,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isButtonEnabled = isEnabled && !isLoading && onPressed != null;

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: isButtonEnabled ? onPressed : null,
        style: _buildButtonStyle(context, theme),
        child: _buildButtonContent(theme),
      ),
    );
  }

  ButtonStyle _buildButtonStyle(BuildContext context, ThemeData theme) {
    final defaultStyle = ElevatedButton.styleFrom(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        side: side ?? BorderSide.none,
      ),
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      shadowColor: Colors.transparent,
    );

    if (style != null) {
      return style!.merge(defaultStyle);
    }

    return defaultStyle;
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? theme.colorScheme.onPrimary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: foregroundColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Botón secundario (outlined)
class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonStyle? style;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? foregroundColor;
  final double? borderRadius;
  final BorderSide? side;

  const CustomOutlinedButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style,
    this.icon,
    this.padding,
    this.width,
    this.height,
    this.foregroundColor,
    this.borderRadius,
    this.side,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isButtonEnabled = isEnabled && !isLoading && onPressed != null;

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: OutlinedButton(
        onPressed: isButtonEnabled ? onPressed : null,
        style: _buildButtonStyle(context, theme),
        child: _buildButtonContent(theme),
      ),
    );
  }

  ButtonStyle _buildButtonStyle(BuildContext context, ThemeData theme) {
    final defaultStyle = OutlinedButton.styleFrom(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        side: side ?? BorderSide(color: theme.colorScheme.outline),
      ),
      foregroundColor: foregroundColor,
    );

    if (style != null) {
      return style!.merge(defaultStyle);
    }

    return defaultStyle;
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: foregroundColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Botón de texto
class CustomTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final ButtonStyle? style;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color? foregroundColor;
  final double? borderRadius;

  const CustomTextButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.style,
    this.icon,
    this.padding,
    this.width,
    this.height,
    this.foregroundColor,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isButtonEnabled = isEnabled && !isLoading && onPressed != null;

    return SizedBox(
      width: width,
      height: height ?? 48,
      child: TextButton(
        onPressed: isButtonEnabled ? onPressed : null,
        style: _buildButtonStyle(context, theme),
        child: _buildButtonContent(theme),
      ),
    );
  }

  ButtonStyle _buildButtonStyle(BuildContext context, ThemeData theme) {
    final defaultStyle = TextButton.styleFrom(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
      ),
      foregroundColor: foregroundColor,
    );

    if (style != null) {
      return style!.merge(defaultStyle);
    }

    return defaultStyle;
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            foregroundColor ?? theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: foregroundColor,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
