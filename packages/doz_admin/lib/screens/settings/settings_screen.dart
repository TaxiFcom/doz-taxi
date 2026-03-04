import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/admin_scaffold.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late double _commissionRate;
  late String _defaultLanguage;
  late bool _notificationsEnabled;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<SettingsProvider>().loadSettings();
      final settings = context.read<SettingsProvider>().settings;
      setState(() {
        _commissionRate = settings.commissionRate;
        _defaultLanguage = settings.defaultLanguage;
        _notificationsEnabled = settings.notificationsEnabled;
      });
    });
  }

  void _markChanged() => setState(() => _hasChanges = true);

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Settings',
      actions: [
        if (_hasChanges)
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save, size: 16),
            label: const Text('Save Changes'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(140, 36)),
          ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(DozColors.primaryGreen)));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.successMessage != null)
                  _MessageBanner(message: provider.successMessage!, isError: false, onDismiss: provider.clearMessages),
                if (provider.error != null)
                  _MessageBanner(message: provider.error!, isError: true, onDismiss: provider.clearMessages),
                _SettingsSection(
                  title: 'Business Settings',
                  icon: Icons.business,
                  children: [
                    _SliderSetting(
                      label: 'Commission Rate',
                      description: 'Platform commission on every completed ride',
                      value: _commissionRate,
                      min: 0.05,
                      max: 0.35,
                      onChanged: (v) { setState(() => _commissionRate = v); _markChanged(); },
                      displayValue: '${(_commissionRate * 100).toStringAsFixed(0)}%',
                    ),
                    const Divider(height: 24, color: DozColors.borderLightSubtle),
                    _DropdownSetting(
                      label: 'Default Language',
                      description: 'Default language for new users',
                      value: _defaultLanguage,
                      options: const [('Arabic', 'ar'), ('English', 'en')],
                      onChanged: (v) { setState(() => _defaultLanguage = v); _markChanged(); },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _SettingsSection(
                  title: 'Notifications',
                  icon: Icons.notifications_outlined,
                  children: [
                    _SwitchSetting(label: 'Push Notifications', description: 'Send push notifications to users', value: _notificationsEnabled, onChanged: (v) { setState(() => _notificationsEnabled = v); _markChanged(); }),
                    const Divider(height: 24, color: DozColors.borderLightSubtle),
                    _SwitchSetting(label: 'Ride Status Notifications', description: 'Notify riders on ride status changes', value: true, onChanged: (_) => _markChanged()),
                    const Divider(height: 24, color: DozColors.borderLightSubtle),
                    _SwitchSetting(label: 'New Driver Registration Alerts', description: 'Alert admin when a new driver registers', value: true, onChanged: (_) => _markChanged()),
                  ],
                ),
                const SizedBox(height: 20),
                _SettingsSection(
                  title: 'Application',
                  icon: Icons.info_outline,
                  children: [
                    _InfoRow(label: 'App Version', value: '1.0.0'),
                    const Divider(height: 24, color: DozColors.borderLightSubtle),
                    _InfoRow(label: 'API Endpoint', value: AppConstants.baseUrl),
                    const Divider(height: 24, color: DozColors.borderLightSubtle),
                    _InfoRow(label: 'Support Email', value: AppConstants.supportEmail),
                    const Divider(height: 24, color: DozColors.borderLightSubtle),
                    _InfoRow(label: 'Currency', value: AppConstants.defaultCurrency),
                  ],
                ),
                const SizedBox(height: 20),
                _SettingsSection(
                  title: 'Danger Zone',
                  icon: Icons.warning_amber,
                  headerColor: DozColors.error,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Clear App Cache', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DozColors.textPrimaryLight)),
                              SizedBox(height: 4),
                              Text('Clear cached data from the server', style: TextStyle(fontSize: 12, color: DozColors.textMutedLight)),
                            ],
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(foregroundColor: DozColors.error, side: const BorderSide(color: DozColors.error)),
                          child: const Text('Clear Cache'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _save() async {
    final provider = context.read<SettingsProvider>();
    await provider.saveSettings(AdminSettings(
      commissionRate: _commissionRate,
      defaultLanguage: _defaultLanguage,
      notificationsEnabled: _notificationsEnabled,
    ));
    setState(() => _hasChanges = false);
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final Color? headerColor;
  const _SettingsSection({required this.title, required this.icon, required this.children, this.headerColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: DozColors.surfaceLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: DozColors.borderLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(icon, size: 18, color: headerColor ?? DozColors.primaryGreen),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: headerColor ?? DozColors.textPrimaryLight)),
              ],
            ),
          ),
          const Divider(height: 1, color: DozColors.borderLight),
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children)),
        ],
      ),
    );
  }
}

class _SliderSetting extends StatelessWidget {
  final String label, description, displayValue;
  final double value, min, max;
  final void Function(double) onChanged;
  const _SliderSetting({required this.label, required this.description, required this.value, required this.min, required this.max, required this.onChanged, required this.displayValue});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DozColors.textPrimaryLight)),
              Text(description, style: const TextStyle(fontSize: 12, color: DozColors.textMutedLight)),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: DozColors.primaryGreenSurface, borderRadius: BorderRadius.circular(20)),
              child: Text(displayValue, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: DozColors.primaryGreen))),
          ],
        ),
        Slider(value: value, min: min, max: max, divisions: ((max - min) / 0.01).round(), activeColor: DozColors.primaryGreen, onChanged: onChanged),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${(min * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: DozColors.textMutedLight)),
          Text('${(max * 100).toInt()}%', style: const TextStyle(fontSize: 11, color: DozColors.textMutedLight)),
        ]),
      ],
    );
  }
}

class _DropdownSetting extends StatelessWidget {
  final String label, description, value;
  final List<(String, String)> options;
  final void Function(String) onChanged;
  const _DropdownSetting({required this.label, required this.description, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DozColors.textPrimaryLight)),
          Text(description, style: const TextStyle(fontSize: 12, color: DozColors.textMutedLight)),
        ])),
        DropdownButton<String>(
          value: value,
          underline: const SizedBox(),
          onChanged: (v) { if (v != null) onChanged(v); },
          items: options.map((o) => DropdownMenuItem(value: o.$2, child: Text(o.$1, style: const TextStyle(fontSize: 13)))).toList(),
        ),
      ],
    );
  }
}

class _SwitchSetting extends StatelessWidget {
  final String label, description;
  final bool value;
  final void Function(bool) onChanged;
  const _SwitchSetting({required this.label, required this.description, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: DozColors.textPrimaryLight)),
          Text(description, style: const TextStyle(fontSize: 12, color: DozColors.textMutedLight)),
        ])),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: DozColors.textSecondaryLight))),
        Text(value, style: const TextStyle(fontSize: 13, color: DozColors.textMutedLight)),
      ],
    );
  }
}

class _MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;
  const _MessageBanner({required this.message, required this.isError, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isError ? DozColors.errorLight : DozColors.successLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: (isError ? DozColors.error : DozColors.success).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(isError ? Icons.error_outline : Icons.check_circle_outline, size: 16, color: isError ? DozColors.error : DozColors.success),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: TextStyle(fontSize: 13, color: isError ? DozColors.error : DozColors.success))),
          IconButton(onPressed: onDismiss, icon: const Icon(Icons.close, size: 16), color: isError ? DozColors.error : DozColors.success, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        ],
      ),
    );
  }
}
