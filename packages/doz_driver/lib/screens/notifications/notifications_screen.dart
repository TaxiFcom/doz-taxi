import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/notifications_provider.dart';

/// Notifications screen — shows all driver notifications.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final notifs = context.watch<NotificationsProvider>();

    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      appBar: AppBar(
        backgroundColor: DozColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new, color: DozColors.textPrimary, size: 20),
        ),
        title: Text(l.t('notificationsTitle'), style: DozTextStyles.sectionTitle(isArabic: isAr)),
        centerTitle: true,
        actions: [
          if (notifs.unreadCount > 0)
            TextButton(
              onPressed: notifs.markAllRead,
              child: Text(l.t('markAllRead'), style: DozTextStyles.buttonSmall(isArabic: isAr, color: DozColors.primaryGreen)),
            ),
        ],
      ),
      body: notifs.isLoading
          ? const Center(child: DozLoading())
          : notifs.notifications.isEmpty
              ? Center(child: DozEmptyState(
                  icon: Icons.notifications_none,
                  title: l.t('noNotifications'),
                  subtitle: isAr ? 'ستظهر إشعاراتك هنا' : 'Your notifications will appear here',
                ))
              : RefreshIndicator(
                  color: DozColors.primaryGreen,
                  backgroundColor: DozColors.cardDark,
                  onRefresh: notifs.loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifs.notifications.length,
                    itemBuilder: (context, i) {
                      final n = notifs.notifications[i];
                      return _NotificationCard(notification: n, isAr: isAr, onTap: () => notifs.markRead(n.id));
                    },
                  ),
                ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final bool isAr;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.isAr, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final iconData = _getIcon();
    final iconColor = _getIconColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? DozColors.cardDark : DozColors.surfaceDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isUnread ? DozColors.primaryGreen.withOpacity(0.3) : DozColors.borderDark),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: iconColor.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(notification.localizedTitle(isAr ? 'ar' : 'en'),
                        style: DozTextStyles.labelLarge(isArabic: isAr).copyWith(color: isUnread ? DozColors.textPrimary : DozColors.textSecondary))),
                      if (isUnread) Container(width: 8, height: 8, decoration: const BoxDecoration(color: DozColors.primaryGreen, shape: BoxShape.circle)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(notification.localizedBody(isAr ? 'ar' : 'en'),
                    style: DozTextStyles.bodySmall(isArabic: isAr, color: DozColors.textMuted), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(DozFormatters.timeAgo(notification.createdAt, lang: isAr ? 'ar' : 'en'), style: DozTextStyles.caption(isArabic: isAr)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.bidAccepted: return Icons.check_circle_outline;
      case NotificationType.rideUpdate: return Icons.directions_car_outlined;
      case NotificationType.payment: return Icons.account_balance_wallet_outlined;
      case NotificationType.promo: return Icons.local_offer_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getIconColor() {
    switch (notification.type) {
      case NotificationType.bidAccepted: return DozColors.success;
      case NotificationType.rideUpdate: return DozColors.primaryGreen;
      case NotificationType.payment: return DozColors.info;
      case NotificationType.promo: return DozColors.warning;
      default: return DozColors.textMuted;
    }
  }
}
