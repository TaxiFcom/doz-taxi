import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';

/// Settings screen — language, notifications, theme preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _rideNotifications = true;
  bool _promoNotifications = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
          color: DozColors.textPrimary,
        ),
        title: Text(
          isArabic ? 'الإعدادات' : 'Settings',
          style: DozTextStyles.sectionTitle(isArabic: isArabic),
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // Language section
          _SectionHeader(
            title: isArabic ? 'اللغة' : 'Language',
          ),
          Container(
            color: DozColors.surfaceDark,
            child: Column(
              children: [
                _LanguageOption(
                  label: 'العربية',
                  sublabel: 'Arabic',
                  isSelected: isArabic,
                  onTap: () => auth.setLocale('ar'),
                ),
                Divider(
                    height: 1, color: DozColors.borderDark, indent: 60),
                _LanguageOption(
                  label: 'English',
                  sublabel: 'الإنجليزية',
                  isSelected: !isArabic,
                  onTap: () => auth.setLocale('en'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Notifications section
          _SectionHeader(
            title: isArabic ? 'الإشعارات' : 'Notifications',
          ),
          Container(
            color: DozColors.surfaceDark,
            child: Column(
              children: [
                _ToggleSetting(
                  icon: Icons.directions_car_rounded,
                  label: isArabic ? 'تحديثات الرحلة' : 'Ride Updates',
                  value: _rideNotifications,
                  onChanged: (v) =>
                      setState(() => _rideNotifications = v),
                ),
                Divider(
                    height: 1, color: DozColors.borderDark, indent: 60),
                _ToggleSetting(
                  icon: Icons.local_offer_rounded,
                  label: isArabic ? 'العروض والتخفيضات' : 'Promotions',
                  value: _promoNotifications,
                  onChanged: (v) =>
                      setState(() => _promoNotifications = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: DozTextStyles.caption(isArabic: isArabic,
            color: DozColors.textMuted)
            .copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String sublabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.sublabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? DozColors.primaryGreenSurface
              : DozColors.cardDark,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label.substring(0, 2),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isSelected
                  ? DozColors.primaryGreen
                  : DozColors.textMuted,
            ),
          ),
        ),
      ),
      title: Text(
        label,
        style: DozTextStyles.bodyMedium(isArabic: isArabic)
            .copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        sublabel,
        style: DozTextStyles.caption(isArabic: isArabic),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded,
              color: DozColors.primaryGreen, size: 22)
          : const Icon(Icons.radio_button_unchecked_rounded,
              color: DozColors.borderDark, size: 22),
      onTap: onTap,
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleSetting({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: DozColors.textSecondary, size: 22),
      title: Text(
        label,
        style: DozTextStyles.bodyMedium(isArabic: isArabic)
            .copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: DozColors.primaryGreen,
        inactiveThumbColor: DozColors.textDisabled,
        inactiveTrackColor: DozColors.borderDark,
      ),
    );
  }
}
