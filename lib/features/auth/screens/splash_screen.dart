import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/farm_background.dart';
import '../providers/auth_provider.dart';
import '../models/auth_state.dart';
import '../../../router/app_router.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        // Router redirect handles the actual navigation
      } else if (next.status == AuthStatus.unauthenticated) {
        context.go(AppRoutes.onboarding);
      }
    });

    return Scaffold(
      body: FarmBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreenLight.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 60,
                  color: AppColors.accentGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'AgriConnect',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Fresh from the farm to your door',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 64),
              const CircularProgressIndicator(
                color: AppColors.accentGreen,
                strokeWidth: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
