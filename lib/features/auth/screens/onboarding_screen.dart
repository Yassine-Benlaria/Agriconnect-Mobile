import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../router/app_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 48),
                // Header
                Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border:
                            Border.all(color: AppColors.glassBorder, width: 1.5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(
                          'assets/images/agriconnect copped.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'AgriConnect',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Algeria\'s agricultural marketplace',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const Spacer(),

                Text(
                  'I am...',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 28),

                // Role buttons
                _RoleButton(
                  icon: Icons.agriculture_rounded,
                  title: 'THE FARMER',
                  subtitle: 'Sell my fresh produce directly',
                  color: const Color(0xFF52B788),
                  onTap: () => context.go(
                      '${AppRoutes.login}?role=FARMER',
                  ),
                ),
                const SizedBox(height: 16),
                _RoleButton(
                  icon: Icons.shopping_basket_rounded,
                  title: 'THE BUYER',
                  subtitle: 'Buy fresh products from local farms',
                  color: const Color(0xFF74C69D),
                  onTap: () => context.go(
                      '${AppRoutes.login}?role=BUYER',
                  ),
                ),
                const SizedBox(height: 16),
                _RoleButton(
                  icon: Icons.local_shipping_rounded,
                  title: 'THE DELIVERY',
                  subtitle: 'Deliver orders and earn per trip',
                  color: const Color(0xFF95D5B2),
                  onTap: () => context.go(
                      '${AppRoutes.login}?role=DELIVERER',
                  ),
                ),

                const Spacer(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'I AM $title',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
