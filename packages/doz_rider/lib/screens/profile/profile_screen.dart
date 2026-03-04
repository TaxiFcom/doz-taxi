import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';
import '../../navigation/app_router.dart';

/// Profile screen — user info, menu items, logout.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

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
          isArabic ? 'حسابي' : 'My Account',
          style: DozTextStyles.sectionTitle(isArabic: isArabic),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: DozColors.surfaceDark,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  DozAvatar(
                    imageUrl: user?.avatarUrl,
                    name: user?.name ?? 'User',
                    size: 64,
                    onTap: () => context.push(AppRoutes.editProfile),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? (isArabic ? 'مستخدم' : 'User'),
                          style: DozTextStyles.sectionTitle(isArabic: isArabic),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DozFormatters.phone(user?.phone ?? ''),
                          style: DozTextStyles.bodySmall(isArabic: false),
                        ),
                        if (user?.email != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            user!.email!,
                            style: DozTextStyles.bodySmall(isArabic: false, color: DozColors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () => context.push(AppRoutes.editProfile),
                    color: DozColors.primaryGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _MenuSection(
              items: [
                _MenuItem(
                  icon: Icons.history_rounded,
                  label: isArabic ? 'رحلاتي' : 'My Rides',
                  onTap: () => context.push(AppRoutes.rides),
                ),
                _MenuItem(
                  icon: Icons.account_balance_wallet_rounded,
                  label: isArabic ? 'المحفظة' : 'Wallet',
                  onTap: () => context.push(AppRoutes.wallet),
                ),
                _MenuItem(
                  icon: Icons.place_rounded,
                  label: isArabic ? 'الأماكن المحفوظة' : 'Saved Places',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            _MenuSection(
              items: [
                _MenuItem(
                  icon: Icons.language_rounded,
                  label: isArabic ? 'اللغة' : 'Language',
                  onTap: () => context.push(AppRoutes.settings),
                ),
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: isArabic ? 'إشعارات' : 'Notifications',
                  onTap: () => context.push(AppRoutes.settings),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _MenuSection(
              items: [
                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  label: isArabic ? 'مساعدة ودعم' : 'Help & Support',
                  onTap: () => context.push(AppRoutes.support),
                ),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  label: isArabic ? 'حول دوز' : 'About DOZ',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              color: DozColors.surfaceDark,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                leading: const Icon(Icons.logout_rounded, color: DozColors.error, size: 22),
                title: Text(
                  isArabic ? 'تسجيل الخروج' : 'Logout',
                  style: DozTextStyles.bodyMedium(isArabic: isArabic, color: DozColors.error)
                      .copyWith(fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: DozColors.cardDark,
                      title: Text(
                        isArabic ? 'تسجيل الخروج' : 'Logout',
                        style: DozTextStyles.sectionTitle(isArabic: isArabic),
                      ),
                      content: Text(
                        isArabic ? 'هل تريد تسجيل الخروج؟' : 'Are you sure you want to logout?',
                        style: DozTextStyles.bodyMedium(isArabic: isArabic),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(l10n.t('cancel')),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            isArabic ? 'تسجيل الخروج' : 'Logout',
                            style: const TextStyle(color: DozColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<AuthProvider>().logout();
                    if (context.mounted) context.go(AppRoutes.login);
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'DOZ v1.0.0',
              style: DozTextStyles.caption(isArabic: false, color: DozColors.textDisabled),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;

  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DozColors.surfaceDark,
      child: Column(
        children: items.map((item) {
          final isLast = item == items.last;
          return Column(
            children: [
              item,
              if (!isLast) Divider(height: 1, color: DozColors.borderDark, indent: 60, endIndent: 20),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: DozColors.textSecondary, size: 22),
      title: Text(
        label,
        style: DozTextStyles.bodyMedium(isArabic: isArabic).copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, color: DozColors.textMuted, size: 20),
      onTap: onTap,
    );
  }
}
