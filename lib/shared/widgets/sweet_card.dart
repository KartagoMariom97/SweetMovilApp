import 'package:flutter/material.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

class SweetCard extends StatelessWidget {
  const SweetCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.borderColor,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor ?? AppColors.outlineVariant,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ),
    );
  }
}
