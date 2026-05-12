import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/wilaya.dart';
import '../../../core/providers/geo_providers.dart';
import '../../../core/widgets/farm_background.dart';
import '../../../core/widgets/glass_button.dart';
import '../providers/auth_provider.dart';
import '../../../router/app_router.dart';
import '../../../core/constants/app_colors.dart';

class RegisterBuyerScreen extends ConsumerStatefulWidget {
  const RegisterBuyerScreen({super.key});

  @override
  ConsumerState<RegisterBuyerScreen> createState() =>
      _RegisterBuyerScreenState();
}

class _RegisterBuyerScreenState extends ConsumerState<RegisterBuyerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;
  Wilaya? _selectedWilaya;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWilaya == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your wilaya')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).registerBuyer({
        'fullname': _nameCtrl.text.trim(),
        'phoneNumber': _phoneCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'wilayaId': _selectedWilaya!.id,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(ref.read(authProvider).error ?? 'Registration failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wilayasAsync = ref.watch(wilayasProvider);

    return Scaffold(
      body: FarmBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () =>
                        context.go('${AppRoutes.login}?role=BUYER'),
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text('Create Buyer\nAccount',
                      style: Theme.of(context).textTheme.displaySmall),
                  const SizedBox(height: 32),
                  _buildField(_nameCtrl, 'Full Name', Icons.person_outline),
                  const SizedBox(height: 14),
                  _buildField(_phoneCtrl, 'Phone Number', Icons.phone_outlined,
                      type: TextInputType.phone),
                  const SizedBox(height: 14),
                  _buildField(
                      _addressCtrl, 'Address', Icons.location_on_outlined),
                  const SizedBox(height: 14),
                  _buildField(_emailCtrl, 'Email', Icons.email_outlined,
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
                    validator: (v) =>
                        v!.length < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 14),

                  // Wilaya dropdown — driven by GET /geo/wilayas
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
                      label: const Text(
                          'Failed to load wilayas — tap to retry',
                          style: TextStyle(color: AppColors.error)),
                    ),
                    data: (wilayas) => DropdownButtonFormField<Wilaya>(
                      value: _selectedWilaya,
                      dropdownColor: AppColors.surface,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Wilaya',
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
                      onChanged: (w) => setState(() => _selectedWilaya = w),
                      validator: (v) => v == null ? 'Select a wilaya' : null,
                    ),
                  ),

                  const SizedBox(height: 32),
                  PrimaryButton(
                    label: 'Create Account',
                    onPressed: _submit,
                    isLoading: _isLoading,
                    icon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () =>
                          context.go('${AppRoutes.login}?role=BUYER'),
                      child: Text(
                        'Already have an account? Sign in',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.accentGreen,
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType type = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      validator: (v) => v!.isEmpty ? '$label is required' : null,
    );
  }
}
