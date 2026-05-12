import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Full-screen farm background with a dark green overlay.
/// Wrap every screen's Scaffold body with this widget.
class FarmBackground extends StatelessWidget {
  final Widget child;
  final bool showOverlay;

  const FarmBackground({
    super.key,
    required this.child,
    this.showOverlay = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-screen farm image
        Positioned.fill(
          child: Image.asset(
            'assets/images/farm.jpg',
            fit: BoxFit.cover,
          ),
        ),
        // Dark green overlay
        Positioned.fill(
          child: Container(
            color: const Color(0xFF0A1F0F).withOpacity(0.8),
          ),
        ),
        // Subtle grain texture overlay
        if (showOverlay)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.3),
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                ],
              ),
            ),
          ),
        child,
      ],
    );
  }
}

/// Glassmorphism card widget.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blurStrength;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 18,
    this.blurStrength = 12,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blurStrength,
          sigmaY: blurStrength,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.glassCard,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? AppColors.glassBorder,
              width: 1.2,
            ),
          ),
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(margin: margin, child: card),
      );
    }
    return Container(margin: margin, child: card);
  }
}
