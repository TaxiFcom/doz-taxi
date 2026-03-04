import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../navigation/app_router.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _vehicleModelController = TextEditingController();
  final _vehicleColorController = TextEditingController();
  final _plateController = TextEditingController();
  final _licenseController = TextEditingController();

  String _vehicleType = 'economy';

  final List<Map<String, String>> _vehicleTypes = [
    {'value': 'economy', 'ar': 'اقتصادي', 'en': 'Economy'},
    {'value': 'comfort', 'ar': 'مريح', 'en': 'Comfort'},
    {'value': 'premium', 'ar': 'بريميوم', 'en': 'Premium'},
    {'value': 'lux', 'ar': 'فاخر', 'en': 'Lux'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _vehicleModelController.dispose();
    _vehicleColorController.dispose();
    _plateController.dispose();
    _licenseController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      vehicleType: _vehicleType,
      vehicleModel: _vehicleModelController.text.trim(),
      vehicleColor: _vehicleColorController.text.trim(),
      plateNumber: _plateController.text.trim(),
      licenseNumber: _licenseController.text.trim(),
    );

    if (success && mounted) {
      await context.read<DriverProvider>().init();
      if (mounted) context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: DozColors.textPrimary, size: 20),
        ),
        title: Text(
          l.t('register'),
          style: DozTextStyles.sectionTitle(isArabic: isAr),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Personal Info Section ──────────────────────────────────────
              _sectionHeader(l.t('profile'), Icons.person_outline, isAr),
              const SizedBox(height: 16),
              _buildLabel(l.t('fullName'), isAr),
              const SizedBox(height: 8),
              DozTextField(
                controller: _nameController,
                hint: l.t('enterName'),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l.t('required_');
                  if (v.trim().length < 2) return l.t('nameTooShort');
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildLabel(l.t('email') + ' (${l.t('optional')})', isAr),
              const SizedBox(height: 8),
              DozTextField(
                controller: _emailController,
                hint: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    if (!v.contains('@')) return l.t('invalidEmail');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              // ── Vehicle Info Section ───────────────────────────────────────
              _sectionHeader(l.t('vehicleInfo'), Icons.directions_car_outlined, isAr),
              const SizedBox(height: 16),
              _buildLabel(l.t('selectVehicleType'), isAr),
              const SizedBox(height: 8),
              _buildVehicleTypeDropdown(isAr),
              const SizedBox(height: 16),
              _buildLabel(isAr ? 'موديل المركبة' : 'Vehicle Model', isAr),
              const SizedBox(height: 8),
              DozTextField(
                controller: _vehicleModelController,
                hint: isAr ? 'مثال: Toyota Camry 2022' : 'e.g. Toyota Camry 2022',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l.t('required_');
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildLabel(isAr ? 'لون المركبة' : 'Vehicle Color', isAr),
              const SizedBox(height: 8),
              DozTextField(
                controller: _vehicleColorController,
                hint: isAr ? 'مثال: أبيض' : 'e.g. White',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l.t('required_');
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildLabel(isAr ? 'رقم اللوحة' : 'Plate Number', isAr),
              const SizedBox(height: 8),
              DozTextField(
                controller: _plateController,
                hint: isAr ? 'مثال: أ ب ج 1234' : 'e.g. ABC 1234',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l.t('required_');
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildLabel(isAr ? 'رقم الرخصة' : 'License Number', isAr),
              const SizedBox(height: 8),
              DozTextField(
                controller: _licenseController,
                hint: isAr ? 'رقم رخصة القيادة' : 'Driver license number',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return l.t('required_');
                  return null;
                },
              ),
              const SizedBox(height: 24),
              // Review notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DozColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DozColors.info.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: DozColors.info,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isAr
                            ? 'سيتم مراجعة طلبك من قِبل فريق DOZ قبل تفعيل حسابك'
                            : 'Your application will be reviewed by DOZ team before activation',
                        style: DozTextStyles.bodySmall(
                          isArabic: isAr,
                          color: DozColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Error
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  if (auth.errorMessage != null) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: DozColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: DozColors.error.withOpacity(0.3)),
                        ),
                        child: Text(
                          auth.errorMessage!,
                          style: DozTextStyles.bodySmall(
                            isArabic: isAr,
                            color: DozColors.error,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              // Submit button
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return DozButton(
                    label: l.t('submit'),
                    loading: auth.isLoading,
                    onPressed: _submit,
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, bool isAr) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: DozColors.primaryGreenSurface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: DozColors.primaryGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: DozTextStyles.sectionTitle(isArabic: isAr),
        ),
      ],
    );
  }

  Widget _buildLabel(String text, bool isAr) {
    return Text(
      text,
      style: DozTextStyles.labelLarge(isArabic: isAr),
    );
  }

  Widget _buildVehicleTypeDropdown(bool isAr) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DozColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DozColors.borderDark),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _vehicleType,
          isExpanded: true,
          dropdownColor: DozColors.cardDark,
          icon: const Icon(Icons.expand_more,
              color: DozColors.textMuted),
          style: DozTextStyles.bodyMedium(),
          items: _vehicleTypes.map((vt) {
            return DropdownMenuItem(
              value: vt['value'],
              child: Text(
                isAr ? vt['ar']! : vt['en']!,
                style: DozTextStyles.bodyMedium(),
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) setState(() => _vehicleType = v);
          },
        ),
      ),
    );
  }
}
