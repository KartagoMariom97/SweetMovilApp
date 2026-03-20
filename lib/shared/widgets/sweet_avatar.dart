import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sweet_mobile_app/core/theme/app_colors.dart';

class SweetAvatar extends StatelessWidget {
  const SweetAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 24,
    this.showBadge = false,
    this.isOnline = false,
  });

  final String? imageUrl;
  final String name;
  final double radius;
  final bool showBadge;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primaryVariant,
          child: imageUrl != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _initials(),
                    errorWidget: (_, __, ___) => _initials(),
                  ),
                )
              : _initials(),
        ),
        if (showBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: radius * 0.55,
              height: radius * 0.55,
              decoration: BoxDecoration(
                color: isOnline ? AppColors.success : AppColors.onSurfaceVariant,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _initials() {
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Text(
      initials,
      style: TextStyle(
        color: Colors.white,
        fontSize: radius * 0.6,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
