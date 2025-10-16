import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final bool showIcon;

  const ErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.showIcon = true,
  });

  /// Mensaje de error simple
  const ErrorMessage.simple({
    super.key,
    required this.message,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.showIcon = true,
    this.icon,
  }) : onRetry = null;

  /// Mensaje de error con botón de reintento
  const ErrorMessage.withRetry({
    super.key,
    required this.message,
    required this.onRetry,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.showIcon = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: Border.all(
          color: theme.colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon ?? Icons.error_outline,
              color: textColor ?? theme.colorScheme.onErrorContainer,
              size: 32,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: textColor ?? theme.colorScheme.onErrorContainer,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget para mostrar mensajes de error en formularios
class FormErrorMessage extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? padding;
  final Color? textColor;

  const FormErrorMessage({
    super.key,
    required this.message,
    this.padding,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: textColor ?? theme.colorScheme.error,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor ?? theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para mostrar mensajes de éxito
class SuccessMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const SuccessMessage({
    super.key,
    required this.message,
    this.onDismiss,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.check_circle_outline,
            color: textColor ?? theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor ?? theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: textColor ?? theme.colorScheme.onPrimaryContainer,
                size: 20,
              ),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}

/// Widget para mostrar mensajes informativos
class InfoMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const InfoMessage({
    super.key,
    required this.message,
    this.onDismiss,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon ?? Icons.info_outline,
            color: textColor ?? theme.colorScheme.onSecondaryContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor ?? theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(
                Icons.close,
                color: textColor ?? theme.colorScheme.onSecondaryContainer,
                size: 20,
              ),
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}
