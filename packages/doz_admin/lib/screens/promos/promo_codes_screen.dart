import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/confirm_dialog.dart';

class PromoCode {
  final String id;
  final String code;
  final String discountType; // 'percent' | 'fixed'
  final double discountValue;
  final int maxUses;
  final int usedCount;
  final DateTime validFrom;
  final DateTime validUntil;
  bool isActive;

  PromoCode({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.maxUses,
    required this.usedCount,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
  });
}

class PromoCodesScreen extends StatefulWidget {
  const PromoCodesScreen({super.key});

  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen> {
  bool _showForm = false;
  PromoCode? _editing;

  final List<PromoCode> _promos = [
    PromoCode(
      id: '1', code: 'WELCOME20', discountType: 'percent',
      discountValue: 20, maxUses: 100, usedCount: 42,
      validFrom: DateTime(2025, 1, 1),
      validUntil: DateTime(2025, 12, 31), isActive: true,
    ),
    PromoCode(
      id: '2', code: 'SAVE5JOD', discountType: 'fixed',
      discountValue: 5, maxUses: 50, usedCount: 50,
      validFrom: DateTime(2025, 3, 1),
      validUntil: DateTime(2025, 6, 30), isActive: false,
    ),
    PromoCode(
      id: '3', code: 'SUMMER30', discountType: 'percent',
      discountValue: 30, maxUses: 200, usedCount: 68,
      validFrom: DateTime(2025, 6, 1),
      validUntil: DateTime(2025, 8, 31), isActive: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Promo Codes',
      actions: [
        ElevatedButton.icon(
          onPressed: () => setState(() {
            _showForm = true;
            _editing = null;
          }),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('New Promo Code'),
          style: ElevatedButton.styleFrom(minimumSize: const Size(150, 36)),
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: DozColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DozColors.borderLight),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: const BoxDecoration(
                          color: DozColors.backgroundLight,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12)),
                          border: Border(
                            bottom:
                                BorderSide(color: DozColors.borderLight),
                          ),
                        ),
                        child: Row(
                          children: const [
                            _ColHeader('CODE', flex: 2),
                            _ColHeader('DISCOUNT', flex: 1),
                            _ColHeader('USES', flex: 1),
                            _ColHeader('VALID FROM', flex: 2),
                            _ColHeader('VALID UNTIL', flex: 2),
                            _ColHeader('STATUS', flex: 1),
                            _ColHeader('ACTIONS', flex: 1),
                          ],
                        ),
                      ),
                      ..._promos.map((promo) => _PromoRow(
                            promo: promo,
                            onEdit: () => setState(() {
                              _editing = promo;
                              _showForm = true;
                            }),
                            onDelete: () async {
                              final confirm = await ConfirmDialog.show(
                                context,
                                title: 'Delete Promo Code',
                                message:
                                    'Delete promo code "${promo.code}"?',
                                confirmLabel: 'Delete',
                                isDestructive: true,
                              );
                              if (confirm) {
                                setState(() => _promos.remove(promo));
                              }
                            },
                            onToggle: () => setState(
                                () => promo.isActive = !promo.isActive),
                          )),
                    ],
                  ),
                ),
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
              child: _PromoCodeForm(
                editing: _editing,
                onSave: (promo) {
                  setState(() {
                    if (_editing != null) {
                      final idx = _promos.indexOf(_editing!);
                      if (idx != -1) _promos[idx] = promo;
                    } else {
                      _promos.add(promo);
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
}

class _ColHeader extends StatelessWidget {
  final String text;
  final int flex;
  const _ColHeader(this.text, {required this.flex});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: DozColors.textMutedLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PromoRow extends StatelessWidget {
  final PromoCode promo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _PromoRow({
    required this.promo,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (promo.usedCount / promo.maxUses).clamp(0.0, 1.0);
    final isExpired = DateTime.now().isAfter(promo.validUntil);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DozColors.borderLightSubtle)),
      ),
      child: Row(
        children: [
          // Code
          Expanded(
            flex: 2,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: DozColors.backgroundLight,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: DozColors.borderLight),
              ),
              child: Text(
                promo.code,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'RobotoMono',
                  color: DozColors.textPrimaryLight,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          // Discount
          Expanded(
            flex: 1,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: DozColors.primaryGreenSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                promo.discountType == 'percent'
                    ? '${promo.discountValue.toInt()}%'
                    : '${promo.discountValue.toStringAsFixed(3)} JOD',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: DozColors.primaryGreen,
                ),
              ),
            ),
          ),
          // Uses
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${promo.usedCount}/${promo.maxUses}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DozColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 3),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: DozColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      pct >= 1.0
                          ? DozColors.error
                          : DozColors.primaryGreen,
                    ),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
          // Valid from
          Expanded(
            flex: 2,
            child: Text(
              DozFormatters.dateShort(promo.validFrom),
              style: const TextStyle(
                  fontSize: 12, color: DozColors.textMutedLight),
            ),
          ),
          // Valid until
          Expanded(
            flex: 2,
            child: Text(
              DozFormatters.dateShort(promo.validUntil),
              style: TextStyle(
                fontSize: 12,
                color: isExpired
                    ? DozColors.error
                    : DozColors.textMutedLight,
                fontWeight: isExpired ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          // Status
          Expanded(
            flex: 1,
            child: Switch(
              value: promo.isActive && !isExpired,
              onChanged: isExpired ? null : (_) => onToggle(),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          // Actions
          Expanded(
            flex: 1,
            child: Row(
              children: [
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
          ),
        ],
      ),
    );
  }
}

class _PromoCodeForm extends StatefulWidget {
  final PromoCode? editing;
  final void Function(PromoCode) onSave;
  final VoidCallback onCancel;

  const _PromoCodeForm({
    required this.editing,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<_PromoCodeForm> createState() => _PromoCodeFormState();
}

class _PromoCodeFormState extends State<_PromoCodeForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _codeCtrl;
  late TextEditingController _valueCtrl;
  late TextEditingController _maxUsesCtrl;
  String _discountType = 'percent';
  DateTime _validFrom = DateTime.now();
  DateTime _validUntil = DateTime.now().add(const Duration(days: 30));
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _codeCtrl = TextEditingController(text: e?.code ?? '');
    _valueCtrl =
        TextEditingController(text: e?.discountValue.toString() ?? '');
    _maxUsesCtrl =
        TextEditingController(text: e?.maxUses.toString() ?? '100');
    _discountType = e?.discountType ?? 'percent';
    _validFrom = e?.validFrom ?? DateTime.now();
    _validUntil = e?.validUntil ?? DateTime.now().add(const Duration(days: 30));
    _isActive = e?.isActive ?? true;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _valueCtrl.dispose();
    _maxUsesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: DozColors.borderLight)),
          ),
          child: Row(
            children: [
              Text(
                widget.editing != null ? 'Edit Promo Code' : 'New Promo Code',
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
                  _FormLabel('Promo Code'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _codeCtrl,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      hintText: 'e.g. WELCOME20',
                    ),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _FormLabel('Discount Type'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: _TypeBtn(
                          label: 'Percentage (%)',
                          isSelected: _discountType == 'percent',
                          onTap: () =>
                              setState(() => _discountType = 'percent'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TypeBtn(
                          label: 'Fixed (JOD)',
                          isSelected: _discountType == 'fixed',
                          onTap: () =>
                              setState(() => _discountType = 'fixed'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _FormLabel(
                      _discountType == 'percent'
                          ? 'Discount Value (%)'
                          : 'Discount Value (JOD)'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _valueCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText:
                          _discountType == 'percent' ? 'e.g. 20' : 'e.g. 5.000',
                    ),
                    validator: (v) =>
                        (v?.isEmpty ?? true) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  _FormLabel('Max Uses'),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _maxUsesCtrl,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _FormLabel('Valid From'),
                  const SizedBox(height: 6),
                  _DatePicker(
                    date: _validFrom,
                    onPick: (d) => setState(() => _validFrom = d),
                  ),
                  const SizedBox(height: 14),
                  _FormLabel('Valid Until'),
                  const SizedBox(height: 6),
                  _DatePicker(
                    date: _validUntil,
                    onPick: (d) => setState(() => _validUntil = d),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const _FormLabel('Active'),
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
                      widget.onSave(PromoCode(
                        id: widget.editing?.id ??
                            DateTime.now().millisecondsSinceEpoch.toString(),
                        code: _codeCtrl.text.toUpperCase(),
                        discountType: _discountType,
                        discountValue:
                            double.tryParse(_valueCtrl.text) ?? 0,
                        maxUses: int.tryParse(_maxUsesCtrl.text) ?? 100,
                        usedCount: widget.editing?.usedCount ?? 0,
                        validFrom: _validFrom,
                        validUntil: _validUntil,
                        isActive: _isActive,
                      ));
                    }
                  },
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: DozColors.textSecondaryLight,
      ),
    );
  }
}

class _TypeBtn extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeBtn({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? DozColors.primaryGreen : DozColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? DozColors.primaryGreen
                : DozColors.borderLight,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : DozColors.textSecondaryLight,
            ),
          ),
        ),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime date;
  final void Function(DateTime) onPick;

  const _DatePicker({required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2024),
          lastDate: DateTime(2030),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: DozColors.primaryGreen,
              ),
            ),
            child: child!,
          ),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: DozColors.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: DozColors.borderLight),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 14, color: DozColors.textMutedLight),
            const SizedBox(width: 8),
            Text(
              DozFormatters.dateShort(date),
              style: const TextStyle(
                fontSize: 13,
                color: DozColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
