import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/confirm_dialog.dart';

class VehicleTypesScreen extends StatefulWidget {
  const VehicleTypesScreen({super.key});

  @override
  State<VehicleTypesScreen> createState() => _VehicleTypesScreenState();
}

class _VehicleTypesScreenState extends State<VehicleTypesScreen> {
  List<VehicleTypeModel> _types = [];
  bool _isLoading = true;
  bool _showForm = false;
  VehicleTypeModel? _editing;

  @override
  void initState() {
    super.initState();
    _loadTypes();
  }

  Future<void> _loadTypes() async {
    setState(() => _isLoading = true);
    try {
      final api = context.read<ApiClient>();
      final types = await api.getVehicleTypes();
      setState(() {
        _types = types;
        _isLoading = false;
      });
    } catch (_) {
      // Use mock data if API fails
      setState(() {
        _types = [
          const VehicleTypeModel(
            id: '1', nameAr: 'اقتصادي', nameEn: 'Economy',
            icon: '🚗', baseFare: 0.5, perKm: 0.3, perMin: 0.05, minFare: 1.5,
            isActive: true, sortOrder: 1,
          ),
          const VehicleTypeModel(
            id: '2', nameAr: 'عادي', nameEn: 'Standard',
            icon: '🚙', baseFare: 0.75, perKm: 0.4, perMin: 0.07, minFare: 2.0,
            isActive: true, sortOrder: 2,
          ),
          const VehicleTypeModel(
            id: '3', nameAr: 'مميز', nameEn: 'Premium',
            icon: '🚘', baseFare: 1.0, perKm: 0.6, perMin: 0.1, minFare: 3.0,
            isActive: true, sortOrder: 3,
          ),
          const VehicleTypeModel(
            id: '4', nameAr: 'فان/XL', nameEn: 'XL/Van',
            icon: '🚐', baseFare: 1.5, perKm: 0.5, perMin: 0.08, minFare: 2.5,
            isActive: false, sortOrder: 4,
          ),
        ];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Vehicle Types',
      actions: [
        ElevatedButton.icon(
          onPressed: () => setState(() {
            _showForm = true;
            _editing = null;
          }),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Vehicle Type'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(160, 36)),
        ),
      ],
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(DozColors.primaryGreen),
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle type cards
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _VehicleTypeGrid(
                      types: _types,
                      onEdit: (t) => setState(() {
                        _editing = t;
                        _showForm = true;
                      }),
                      onDelete: (t) => _confirmDelete(t),
                      onToggle: (t) => _toggleActive(t),
                    ),
                  ),
                ),

                // Side form
                if (_showForm)
                  Container(
                    width: 340,
                    decoration: const BoxDecoration(
                      color: DozColors.surfaceLight,
                      border: Border(
                        left: BorderSide(color: DozColors.borderLight),
                      ),
                    ),
                    child: _VehicleTypeForm(
                      editing: _editing,
                      onSave: (type) {
                        setState(() {
                          if (_editing != null) {
                            final idx =
                                _types.indexWhere((t) => t.id == type.id);
                            if (idx != -1) _types[idx] = type;
                          } else {
                            _types.add(type);
                          }
                          _showForm = false;
                          _editing = null;
                        });
                      },
                      onCancel: () => setState(() {
                        _showForm = false;
                        _editing = null;
                      }),
                    ),
                  ),
              ],
            ),
    );
  }

  void _confirmDelete(VehicleTypeModel type) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Delete Vehicle Type',
      message: 'Delete "${type.nameEn}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirm) {
      setState(() => _types.removeWhere((t) => t.id == type.id));
    }
  }

  void _toggleActive(VehicleTypeModel type) {
    setState(() {
      final idx = _types.indexWhere((t) => t.id == type.id);
      if (idx != -1) {
        _types[idx] = type.copyWith(isActive: !type.isActive);
      }
    });
  }
}

class _VehicleTypeGrid extends StatelessWidget {
  final List<VehicleTypeModel> types;
  final void Function(VehicleTypeModel) onEdit;
  final void Function(VehicleTypeModel) onDelete;
  final void Function(VehicleTypeModel) onToggle;

  const _VehicleTypeGrid({
    required this.types,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 240,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) {
        return _VehicleTypeCard(
          type: types[index],
          onEdit: () => onEdit(types[index]),
          onDelete: () => onDelete(types[index]),
          onToggle: () => onToggle(types[index]),
        );
      },
    );
  }
}

class _VehicleTypeCard extends StatelessWidget {
  final VehicleTypeModel type;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _VehicleTypeCard({
    required this.type,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DozColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: type.isActive
              ? DozColors.primaryGreen.withOpacity(0.3)
              : DozColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                type.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const Spacer(),
              Switch(
                value: type.isActive,
                onChanged: (_) => onToggle(),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            type.nameEn,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: DozColors.textPrimaryLight,
            ),
          ),
          Text(
            type.nameAr,
            style: const TextStyle(
              fontSize: 13,
              color: DozColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _FareChip(label: 'Base', value: type.baseFare),
              const SizedBox(width: 6),
              _FareChip(label: '/km', value: type.perKm),
              const SizedBox(width: 6),
              _FareChip(label: '/min', value: type.perMin),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: type.isActive
                      ? DozColors.successLight
                      : DozColors.borderLightSubtle,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  type.isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: type.isActive
                        ? DozColors.success
                        : DozColors.textMutedLight,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                color: DozColors.info,
                tooltip: 'Edit',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 16),
                color: DozColors.error,
                tooltip: 'Delete',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FareChip extends StatelessWidget {
  final String label;
  final double value;
  const _FareChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: DozColors.backgroundLight,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: DozColors.borderLight),
      ),
      child: Text(
        '$label: ${value.toStringAsFixed(3)}',
        style: const TextStyle(
          fontSize: 10,
          color: DozColors.textMutedLight,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

class _VehicleTypeForm extends StatefulWidget {
  final VehicleTypeModel? editing;
  final void Function(VehicleTypeModel) onSave;
  final VoidCallback onCancel;

  const _VehicleTypeForm({
    required this.editing,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_VehicleTypeForm> createState() => _VehicleTypeFormState();
}

class _VehicleTypeFormState extends State<_VehicleTypeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameArCtrl;
  late final TextEditingController _nameEnCtrl;
  late final TextEditingController _iconCtrl;
  late final TextEditingController _baseFareCtrl;
  late final TextEditingController _perKmCtrl;
  late final TextEditingController _perMinCtrl;
  late final TextEditingController _minFareCtrl;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _nameArCtrl = TextEditingController(text: e?.nameAr ?? '');
    _nameEnCtrl = TextEditingController(text: e?.nameEn ?? '');
    _iconCtrl = TextEditingController(text: e?.icon ?? '🚗');
    _baseFareCtrl =
        TextEditingController(text: e?.baseFare.toString() ?? '');
    _perKmCtrl = TextEditingController(text: e?.perKm.toString() ?? '');
    _perMinCtrl = TextEditingController(text: e?.perMin.toString() ?? '');
    _minFareCtrl =
        TextEditingController(text: e?.minFare.toString() ?? '');
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameArCtrl.dispose();
    _nameEnCtrl.dispose();
    _iconCtrl.dispose();
    _baseFareCtrl.dispose();
    _perKmCtrl.dispose();
    _perMinCtrl.dispose();
    _minFareCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editing != null;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: DozColors.borderLight),
            ),
          ),
          child: Row(
            children: [
              Text(
                isEditing ? 'Edit Vehicle Type' : 'Add Vehicle Type',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DozColors.textPrimaryLight,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close, size: 18),
                color: DozColors.textMutedLight,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FormField(
                    label: 'Name (English)',
                    controller: _nameEnCtrl,
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    label: 'Name (Arabic)',
                    controller: _nameArCtrl,
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    label: 'Icon (emoji)',
                    controller: _iconCtrl,
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    label: 'Base Fare (JOD)',
                    controller: _baseFareCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    label: 'Per KM (JOD)',
                    controller: _perKmCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    label: 'Per Minute (JOD)',
                    controller: _perMinCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 14),
                  _FormField(
                    label: 'Min Fare (JOD)',
                    controller: _minFareCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: DozColors.textSecondaryLight,
                        ),
                      ),
                      Switch(
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSave(VehicleTypeModel(
                        id: widget.editing?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        nameAr: _nameArCtrl.text,
                        nameEn: _nameEnCtrl.text,
                        icon: _iconCtrl.text,
                        baseFare: double.tryParse(_baseFareCtrl.text) ?? 0,
                        perKm: double.tryParse(_perKmCtrl.text) ?? 0,
                        perMin: double.tryParse(_perMinCtrl.text) ?? 0,
                        minFare: double.tryParse(_minFareCtrl.text) ?? 0,
                        isActive: _isActive,
                      ));
                    }
                  },
                  child: Text(isEditing ? 'Update' : 'Add'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: DozColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
        ),
      ],
    );
  }
}
