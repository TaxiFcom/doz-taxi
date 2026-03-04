import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';

/// Settings screen — language, notifications, navigation, sound preferences.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _rideRequestSound = true;
  bool _rideRequestVibration = true;
  bool _chatNotifications = true;
  bool _systemNotifications = true;
  bool _voiceNavigation = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark,
        elevation: 0,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, color: DozColors.textPrimary, size: 20)),
        title: Text(isAr ? 'الإعدادات' : 'Settings', style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(isAr ? 'اللغة' : 'Language', Icons.language, isAr),
            _buildLanguageToggle(auth, isAr),
            const SizedBox(height: 8),
            _sectionHeader(l.t('notifications'), Icons.notifications_outlined, isAr),
            _buildSwitch(label: isAr ? 'صوت طلب الرحلة' : 'Ride Request Sound', subtitle: isAr ? 'تشغيل صوت عند وصول طلب رحلة جديد' : 'Play sound when new ride request arrives', value: _rideRequestSound, onChanged: (v) => setState(() => _rideRequestSound = v), isAr: isAr),
            _buildSwitch(label: isAr ? 'اهتزاز الطلبات' : 'Ride Request Vibration', subtitle: isAr ? 'الاهتزاز عند وصول طلب رحلة جديد' : 'Vibrate when new ride request arrives', value: _rideRequestVibration, onChanged: (v) => setState(() => _rideRequestVibration = v), isAr: isAr),
            _buildSwitch(label: isAr ? 'إشعارات المحادثة' : 'Chat Notifications', subtitle: isAr ? 'إشعارات رسائل الراكب' : 'Notifications for rider messages', value: _chatNotifications, onChanged: (v) => setState(() => _chatNotifications = v), isAr: isAr),
            _buildSwitch(label: isAr ? 'إشعارات النظام' : 'System Notifications', subtitle: isAr ? 'إشعارات تحديثات التطبيق والنظام' : 'App updates and system announcements', value: _systemNotifications, onChanged: (v) => setState(() => _systemNotifications = v), isAr: isAr),
            const SizedBox(height: 8),
            _sectionHeader(isAr ? 'الملاحة' : 'Navigation', Icons.navigation, isAr),
            _buildSwitch(label: isAr ? 'الملاحة الصوتية' : 'Voice Navigation', subtitle: isAr ? 'التعليمات الصوتية أثناء القيادة' : 'Audio instructions while driving', value: _voiceNavigation, onChanged: (v) => setState(() => _voiceNavigation = v), isAr: isAr),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, bool isAr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: DozColors.primaryGreen, size: 18),
          const SizedBox(width: 8),
          Text(title, style: DozTextStyles.labelMedium(isArabic: isAr).copyWith(color: DozColors.primaryGreen)),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle(AuthProvider auth, bool isAr) {
    return Container(
      color: DozColors.surfaceDark,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isAr ? 'اللغة الحالية' : 'Current Language', style: DozTextStyles.bodyMedium(isArabic: isAr)),
                Text(isAr ? 'العربية' : 'English', style: DozTextStyles.caption(isArabic: isAr)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(color: DozColors.cardDark, borderRadius: BorderRadius.circular(24), border: Border.all(color: DozColors.borderDark)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _langOption('AR', isAr, auth.lang == 'ar', () { auth.setLanguage('ar'); }),
                _langOption('EN', isAr, auth.lang == 'en', () { auth.setLanguage('en'); }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _langOption(String label, bool isAr, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isActive ? DozColors.primaryGreen : Colors.transparent, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: DozTextStyles.buttonSmall(isArabic: false).copyWith(color: isActive ? DozColors.primaryDark : DozColors.textMuted)),
      ),
    );
  }

  Widget _buildSwitch({required String label, required String subtitle, required bool value, required ValueChanged<bool> onChanged, required bool isAr}) {
    return Container(
      color: DozColors.surfaceDark,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DozTextStyles.bodyMedium(isArabic: isAr)),
                const SizedBox(height: 2),
                Text(subtitle, style: DozTextStyles.caption(isArabic: isAr)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: DozColors.primaryGreen, activeTrackColor: DozColors.primaryGreenSurface, inactiveThumbColor: DozColors.textMuted, inactiveTrackColor: DozColors.borderDark),
        ],
      ),
    );
  }
}
