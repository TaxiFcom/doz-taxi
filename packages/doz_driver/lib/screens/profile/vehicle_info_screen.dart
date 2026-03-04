import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/driver_provider.dart';

/// Vehicle info screen — view and edit vehicle details.
class VehicleInfoScreen extends StatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  State<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends State<VehicleInfoScreen> {
  bool _isEditing = false;
  late TextEditingController _modelController;
  late TextEditingController _colorController;
  late TextEditingController _plateController;
  String _vehicleType = 'economy';

  final List<Map<String, String>> _vehicleTypes = [
    {'value': 'economy', 'ar': 'اقتصادي', 'en': 'Economy'},
    {'value': 'comfort', 'ar': 'مريح', 'en': 'Comfort'},
    {'value': 'premium', 'ar': 'بريميوم', 'en': 'Premium'},
    {'value': 'lux', 'ar': 'فاخر', 'en': 'Lux'},
  ];

  @override
  void initState() {
    super.initState();
    final driver = context.read<DriverProvider>().driverModel;
    _vehicleType = driver?.vehicleType ?? 'economy';
    _modelController = TextEditingController(text: driver?.vehicleModel ?? '');
    _colorController = TextEditingController(text: driver?.vehicleColor ?? '');
    _plateController = TextEditingController(text: driver?.plateNumber ?? '');
  }

  @override
  void dispose() {
    _modelController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final driver = context.watch<DriverProvider>();

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark,
        elevation: 0,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, color: DozColors.textPrimary, size: 20)),
        title: Text(l.t('vehicleInfo'), style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(_isEditing ? l.t('cancel') : l.t('edit'), style: DozTextStyles.buttonSmall(isArabic: isAr, color: DozColors.primaryGreen)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 160, height: 100,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: DozColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DozColors.primaryGreen.withOpacity(0.3)),
                ),
                child: const Icon(Icons.directions_car, color: DozColors.primaryGreen, size: 56),
              ),
            ),
            _vehicleField(label: l.t('selectVehicleType'), value: _vehicleTypes.firstWhere((v) => v['value'] == _vehicleType, orElse: () => _vehicleTypes.first)[isAr ? 'ar' : 'en']!, isEditing: _isEditing, editWidget: _buildVehicleTypeDropdown(isAr), isAr: isAr),
            const SizedBox(height: 16),
            _vehicleField(label: isAr ? 'الموديل' : 'Model', value: driver.driverModel?.vehicleModel ?? '', isEditing: _isEditing, editWidget: DozTextField(controller: _modelController), isAr: isAr),
            const SizedBox(height: 16),
            _vehicleField(label: isAr ? 'اللون' : 'Color', value: driver.driverModel?.vehicleColor ?? '', isEditing: _isEditing, editWidget: DozTextField(controller: _colorController), isAr: isAr),
            const SizedBox(height: 16),
            _vehicleField(label: isAr ? 'رقم اللوحة' : 'Plate Number', value: DozFormatters.plateNumber(driver.driverModel?.plateNumber ?? ''), isEditing: _isEditing, editWidget: DozTextField(controller: _plateController), isAr: isAr),
            if (_isEditing) ...[
              const SizedBox(height: 32),
              DozButton(
                label: l.t('save'),
                onPressed: () {
                  setState(() => _isEditing = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.t('profileUpdated')), backgroundColor: DozColors.success));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _vehicleField({required String label, required String value, required bool isEditing, required Widget editWidget, required bool isAr}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: DozTextStyles.labelMedium(isArabic: isAr)),
        const SizedBox(height: 8),
        isEditing ? editWidget : Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: DozColors.cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: DozColors.borderDark)),
          child: Text(value.isEmpty ? (isAr ? 'غير محدد' : 'Not set') : value, style: DozTextStyles.bodyMedium()),
        ),
      ],
    );
  }

  Widget _buildVehicleTypeDropdown(bool isAr) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: DozColors.cardDark, borderRadius: BorderRadius.circular(12), border: Border.all(color: DozColors.borderDark)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _vehicleType,
          isExpanded: true,
          dropdownColor: DozColors.cardDark,
          icon: const Icon(Icons.expand_more, color: DozColors.textMuted),
          style: DozTextStyles.bodyMedium(),
          items: _vehicleTypes.map((vt) => DropdownMenuItem(value: vt['value'], child: Text(isAr ? vt['ar']! : vt['en']!, style: DozTextStyles.bodyMedium()))).toList(),
          onChanged: (v) { if (v != null) setState(() => _vehicleType = v); },
        ),
      ),
    );
  }
}
