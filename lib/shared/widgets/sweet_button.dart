import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum SweetButtonVariant { primary, secondary, outlined, ghost }

class SweetButton extends StatelessWidget {
  const SweetButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = SweetButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  });

  const SweetButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  }) : variant = SweetButtonVariant.primary;

  const SweetButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  }) : variant = SweetButtonVariant.outlined;

  const SweetButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
  }) : variant = SweetButtonVariant.ghost;

  final String label;
  final VoidCallback? onPressed;
  final SweetButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final child = _buildChild(theme);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: switch (variant) {
        SweetButtonVariant.primary => ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        SweetButtonVariant.secondary => ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
            ),
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        SweetButtonVariant.outlined => OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
        SweetButtonVariant.ghost => TextButton(
            onPressed: isLoading ? null : onPressed,
            child: child,
          ),
      },
    ).animate().fadeIn(duration: 200.ms);
  }

  Widget _buildChild(ThemeData theme) {
    if (isLoading) {
      return const SizedBox.square(
        dimension: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      );
    }
    return Text(label);
  }
}
