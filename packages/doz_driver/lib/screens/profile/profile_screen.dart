import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../navigation/app_router.dart';

/// Driver profile screen with stats and navigation menu.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final auth = context.watch<AuthProvider>();
    final driver = context.watch<DriverProvider>();
    final user = auth.user;
    final driverModel = driver.driverModel;

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark,
        elevation: 0,
        leading: IconButton(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_ios_new, color: DozColors.textPrimary, size: 20)),
        title: Text(l.t('profile'), style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: DozColors.surfaceDark,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Stack(
                    children: [
                      DozAvatar(imageUrl: user?.avatarUrl, name: user?.name ?? '', size: 88),
                      Positioned(
                        bottom: 0, right: 0,
                        child: GestureDetector(
                          onTap: () => context.push(AppRoutes.editProfile),
                          child: Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(color: DozColors.primaryGreen, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: DozColors.primaryDark, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(user?.name ?? '', style: DozTextStyles.sectionTitle(isArabic: isAr)),
                  const SizedBox(height: 4),
                  Text(user?.phone ?? '', style: DozTextStyles.bodySmall(isArabic: false, color: DozColors.textMuted)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statBadge(Icons.star, Colors.amber, DozFormatters.rating(driverModel?.rating ?? 5.0), isAr ? 'التقييم' : 'Rating', isAr),
                      Container(width: 1, height: 36, color: DozColors.borderDark),
                      _statBadge(Icons.directions_car, DozColors.info, '${driverModel?.totalRides ?? 0}', l.t('ridesCompleted'), isAr),
                      Container(width: 1, height: 36, color: DozColors.borderDark),
                      _statBadge(Icons.calendar_today, DozColors.primaryGreen,
                        user != null ? '${DateTime.now().difference(user.createdAt).inDays}d' : '—',
                        isAr ? 'عضو منذ' : 'Days Active', isAr),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (driverModel != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: DozColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: DozColors.borderDark),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: DozColors.primaryGreenSurface, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.directions_car, color: DozColors.primaryGreen, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(driverModel.vehicleModel, style: DozTextStyles.labelLarge(isArabic: isAr)),
                          Text('${driverModel.vehicleColor} · ${DozFormatters.plateNumber(driverModel.plateNumber)}',
                            style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.textMuted)),
                        ],
                      ),
                    ),
                    DozStatusBadge(
                      label: driverModel.isOnline ? (isAr ? 'متاح' : 'Online') : (isAr ? 'غير متاح' : 'Offline'),
                      backgroundColor: driverModel.isOnline ? DozColors.success : DozColors.textMuted,
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Container(
              color: DozColors.surfaceDark,
              child: Column(
                children: [
                  _menuItem(context, icon: Icons.person_outline, label: l.t('editProfile'), route: AppRoutes.editProfile, isAr: isAr),
                  _menuItem(context, icon: Icons.directions_car_outlined, label: l.t('vehicleInfo'), route: AppRoutes.vehicleInfo, isAr: isAr),
                  _menuItem(context, icon: Icons.description_outlined, label: isAr ? 'المستندات' : 'Documents', route: AppRoutes.documents, isAr: isAr),
                  _menuItem(context, icon: Icons.attach_money, label: l.t('earnings'), route: AppRoutes.earnings, isAr: isAr),
                  _menuItem(context, icon: Icons.account_balance_wallet_outlined, label: isAr ? 'المحفظة' : 'Wallet', route: AppRoutes.wallet, isAr: isAr),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: DozColors.surfaceDark,
              child: Column(
                children: [
                  _menuItem(context, icon: Icons.language, label: l.t('language'), route: AppRoutes.settings, isAr: isAr),
                  _menuItem(context, icon: Icons.settings_outlined, label: isAr ? 'الإعدادات' : 'Settings', route: AppRoutes.settings, isAr: isAr),
                  _menuItem(context, icon: Icons.help_outline, label: l.t('helpCenter'), route: null, isAr: isAr),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: DozColors.surfaceDark,
              child: _menuItem(context, icon: Icons.logout, label: l.t('logout'), route: null, isAr: isAr,
                color: DozColors.error, onTap: () => _showLogoutDialog(context, auth, l, isAr)),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(IconData icon, Color color, String value, String label, bool isAr) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: DozTextStyles.labelLarge(isArabic: false).copyWith(color: DozColors.textPrimary)),
        Text(label, style: DozTextStyles.caption(isArabic: isAr)),
      ],
    );
  }

  Widget _menuItem(BuildContext context, {required IconData icon, required String label, required String? route, required bool isAr, Color? color, VoidCallback? onTap}) {
    final c = color ?? DozColors.textPrimary;
    return InkWell(
      onTap: onTap ?? (route != null ? () => context.push(route) : null),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: DozColors.borderDarkSubtle))),
        child: Row(
          children: [
            Icon(icon, color: c, size: 22),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: DozTextStyles.bodyMedium(isArabic: isAr, color: c))),
            if (color == null) const Icon(Icons.arrow_forward_ios, color: DozColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth, AppLocalizations l, bool isAr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: DozColors.cardDark,
        title: Text(l.t('logout'), style: DozTextStyles.sectionTitle(isArabic: isAr)),
        content: Text(l.t('confirmLogout'), style: DozTextStyles.bodyMedium(isArabic: isAr)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.t('cancel'), style: DozTextStyles.buttonSmall(isArabic: isAr))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await auth.logout();
              if (context.mounted) context.go(AppRoutes.login);
            },
            child: Text(l.t('logout'), style: DozTextStyles.buttonSmall(isArabic: isAr, color: DozColors.error)),
          ),
        ],
      ),
    );
  }
}
