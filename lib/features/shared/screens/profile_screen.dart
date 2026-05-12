import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/enums.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Avatar + name
                const SizedBox(height: 16),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.4),
                  backgroundImage: user.avatarUrl != null
                      ? NetworkImage(user.avatarUrl!)
                      : null,
                  child: user.avatarUrl == null
                      ? Text(
                          user.fullname.isNotEmpty
                              ? user.fullname[0].toUpperCase()
                              : '?',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: Colors.white),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(user.fullname,
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Text(
                    user.role.name,
                    style: const TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 12),
                  ),
                ),
                if (user.rating > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC107), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${user.rating.toStringAsFixed(1)} (${user.ratingCount} reviews)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 32),

                // Info cards
                _InfoTile(icon: Icons.email_outlined, label: 'Email', value: user.email),
                if (user.phoneNumber != null)
                  _InfoTile(icon: Icons.phone_outlined, label: 'Phone', value: user.phoneNumber!),
                if (user.address != null)
                  _InfoTile(icon: Icons.location_on_outlined, label: 'Address', value: user.address!),
                if (user.wilaya != null)
                  _InfoTile(icon: Icons.map_outlined, label: 'Wilaya', value: user.wilaya!.nameLatin),

                // Role-specific info
                if (user.role == UserRole.FARMER && user.farmerProfile != null)
                  ..._farmerInfo(context, user.farmerProfile!),
                if (user.role == UserRole.DELIVERER &&
                    user.delivererProfile != null)
                  ..._delivererInfo(context, user.delivererProfile!),

                const SizedBox(height: 32),
                GlassButton(
                  label: 'Sign Out',
                  icon: Icons.logout_rounded,
                  accentColor: AppColors.error,
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go('/onboarding');
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _farmerInfo(BuildContext context, dynamic fp) {
    return [
      _InfoTile(
          icon: Icons.signpost_outlined,
          label: 'Farm Address',
          value: fp.exactAddress ?? '-'),
      _InfoTile(
          icon: Icons.category_outlined,
          label: 'Activity',
          value: (fp.activityType as ActivityType).label),
      if (fp.landArea != null)
        _InfoTile(
            icon: Icons.grass_outlined,
            label: 'Land Area',
            value: '${fp.landArea} ha'),
    ];
  }

  List<Widget> _delivererInfo(BuildContext context, dynamic dp) {
    return [
      _InfoTile(
          icon: Icons.local_shipping_outlined,
          label: 'Vehicle',
          value: (dp.vehicleType as VehicleType).label),
      if (dp.matricule != null)
        _InfoTile(
            icon: Icons.badge_outlined,
            label: 'Matricule',
            value: dp.matricule),
      _InfoTile(
          icon: Icons.circle,
          label: 'Status',
          value: dp.isAvailable ? 'Available' : 'On Delivery'),
    ];
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.glassCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 20),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.textMuted)),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}
