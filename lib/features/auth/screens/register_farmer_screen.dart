import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/enums/enums.dart';
import '../../../core/models/commune.dart';
import '../../../core/models/wilaya.dart';
import '../../../core/providers/geo_providers.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../core/widgets/glass_button.dart';
import '../providers/auth_provider.dart';
import '../../../router/app_router.dart';

class RegisterFarmerScreen extends ConsumerStatefulWidget {
  const RegisterFarmerScreen({super.key});

  @override
  ConsumerState<RegisterFarmerScreen> createState() =>
      _RegisterFarmerScreenState();
}

class _RegisterFarmerScreenState extends ConsumerState<RegisterFarmerScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // Step 1 — Personal info
  final _formKey1 = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  // Step 2 — Farm details
  final _formKey2 = GlobalKey<FormState>();
  final _farmAddressCtrl = TextEditingController();
  final _landAreaCtrl = TextEditingController();
  Wilaya? _selectedWilaya;
  Commune? _selectedCommune;
  ActivityType _activityType = ActivityType.VEGETABLES_FRUITS;

  void _nextPage() {
    if (!_formKey1.currentState!.validate()) return;
    _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    setState(() => _currentPage = 1);
  }

  Future<void> _submit() async {
    if (!_formKey2.currentState!.validate()) return;
    if (_selectedWilaya == null || _selectedCommune == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select wilaya and commune')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).registerFarmer({
        'fullname': _nameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'farmWilayaId': _selectedWilaya!.id,
        'farmCommuneId': _selectedCommune!.id,
        'farmExactAddress': _farmAddressCtrl.text.trim(),
        if (_landAreaCtrl.text.isNotEmpty)
          'farmLandArea': double.tryParse(_landAreaCtrl.text),
        'activityType': _activityType.name,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ref.read(authProvider).error ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _farmAddressCtrl.dispose();
    _landAreaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with step dots
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_currentPage == 0) {
                          context.go('${AppRoutes.login}?role=FARMER');
                        } else {
                          _pageCtrl.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut);
                          setState(() => _currentPage = 0);
                        }
                      },
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        _currentPage == 0 ? 'Personal Info' : 'Farm Details',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    _Dot(active: _currentPage == 0),
                    const SizedBox(width: 6),
                    _Dot(active: _currentPage == 1),
                  ],
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [_buildStep1(), _buildStep2()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Form(
        key: _formKey1,
        child: Column(
          children: [
            const SizedBox(height: 8),
            _f(_nameCtrl, 'Full Name', Icons.person_outline),
            const SizedBox(height: 14),
            _f(_phoneCtrl, 'Phone', Icons.phone_outlined,
                type: TextInputType.phone),
            const SizedBox(height: 14),
            _f(_addressCtrl, 'Address', Icons.location_on_outlined),
            const SizedBox(height: 14),
            _f(_emailCtrl, 'Email', Icons.email_outlined,
                type: TextInputType.emailAddress),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passCtrl,
              obscureText: _obscurePass,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePass = !_obscurePass),
                  icon: Icon(_obscurePass
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                ),
              ),
              validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
            ),
            const SizedBox(height: 32),
            PrimaryButton(label: 'Next: Farm Details', onPressed: _nextPage),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    // Watch wilayasProvider — shared, cached, no extra HTTP call if already loaded
    final wilayasAsync = ref.watch(wilayasProvider);

    // Watch communesProvider only when a wilaya is selected
    final communesAsync = _selectedWilaya != null
        ? ref.watch(communesProvider(_selectedWilaya!.id))
        : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Form(
        key: _formKey2,
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Wilaya dropdown ───────────────────────────────────────────
            wilayasAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircularProgressIndicator(
                      color: AppColors.accentGreen, strokeWidth: 2),
                ),
              ),
              error: (e, _) => TextButton.icon(
                onPressed: () => ref.refresh(wilayasProvider),
                icon: const Icon(Icons.refresh, color: AppColors.error),
                label: const Text('Failed to load wilayas — tap to retry',
                    style: TextStyle(color: AppColors.error)),
              ),
              data: (wilayas) => DropdownButtonFormField<Wilaya>(
                value: _selectedWilaya,
                dropdownColor: AppColors.surface,
                isExpanded: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Farm Wilaya',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                items: wilayas
                    .map((w) => DropdownMenuItem(
                          value: w,
                          child: Text(
                            '${w.code.toString().padLeft(2, '0')} — ${w.nameLatin}',
                          ),
                        ))
                    .toList(),
                onChanged: (w) => setState(() {
                  _selectedWilaya = w;
                  _selectedCommune = null; // reset commune on wilaya change
                }),
                validator: (v) => v == null ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 14),

            // ── Commune dropdown — loaded via communesProvider(wilayaId) ──
            if (_selectedWilaya == null)
              DropdownButtonFormField<Commune>(
                value: null,
                decoration: const InputDecoration(
                  labelText: 'Farm Commune',
                  prefixIcon: Icon(Icons.location_city_outlined),
                ),
                items: const [],
                onChanged: null,
                hint: const Text('Select a wilaya first',
                    style: TextStyle(color: AppColors.textMuted)),
              )
            else
              communesAsync!.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.accentGreen, strokeWidth: 2),
                  ),
                ),
                error: (e, _) => TextButton.icon(
                  onPressed: () =>
                      ref.refresh(communesProvider(_selectedWilaya!.id)),
                  icon: const Icon(Icons.refresh, color: AppColors.error),
                  label: const Text('Failed to load communes — tap to retry',
                      style: TextStyle(color: AppColors.error)),
                ),
                data: (communes) => DropdownButtonFormField<Commune>(
                  value: _selectedCommune,
                  dropdownColor: AppColors.surface,
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Farm Commune',
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  items: communes
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.nameLatin),
                          ))
                      .toList(),
                  onChanged: (c) => setState(() => _selectedCommune = c),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),
            // ──────────────────────────────────────────────────────────────

            const SizedBox(height: 14),
            _f(_farmAddressCtrl, 'Farm Exact Address', Icons.signpost_outlined),
            const SizedBox(height: 14),
            TextFormField(
              controller: _landAreaCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Land Area in ha (optional)',
                prefixIcon: Icon(Icons.grass_outlined),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<ActivityType>(
              value: _activityType,
              dropdownColor: AppColors.surface,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Activity Type',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: ActivityType.values
                  .map((a) => DropdownMenuItem(value: a, child: Text(a.label)))
                  .toList(),
              onChanged: (a) => setState(() => _activityType = a!),
            ),
            const SizedBox(height: 32),
            PrimaryButton(
              label: 'Create Farmer Account',
              onPressed: _submit,
              isLoading: _isLoading,
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _f(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (v) => v!.isEmpty ? '$label is required' : null,
    );
  }
}

class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: active ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? AppColors.accentGreen : AppColors.textMuted,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
