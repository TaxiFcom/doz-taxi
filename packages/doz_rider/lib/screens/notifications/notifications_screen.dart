import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:doz_shared/doz_shared.dart';

/// Notifications screen with read/unread states.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _notifications = _mockNotifications();
      _loading = false;
    });
  }

  List<NotificationModel> _mockNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: '1', userId: 'user1',
        type: NotificationType.bidReceived,
        titleAr: 'عرض جديد', titleEn: 'New Bid',
        bodyAr: 'سائق قدّم عرضاً بـ 4.500 دينار لرحلتك',
        bodyEn: 'A driver bid 4.500 JOD for your ride',
        isRead: false, createdAt: now.subtract(const Duration(minutes: 5)),
      ),
      NotificationModel(
        id: '2', userId: 'user1',
        type: NotificationType.rideUpdate,
        titleAr: 'السائق في الطريق', titleEn: 'Driver on the way',
        bodyAr: 'سيصل سائقك خلال 3 دقائق',
        bodyEn: 'Your driver will arrive in 3 minutes',
        isRead: false, createdAt: now.subtract(const Duration(hours: 1)),
      ),
      NotificationModel(
        id: '3', userId: 'user1',
        type: NotificationType.payment,
        titleAr: 'تم الدفع', titleEn: 'Payment Processed',
        bodyAr: 'تم خصم 5.200 دينار من محفظتك',
        bodyEn: '5.200 JOD was deducted from your wallet',
        isRead: true, createdAt: now.subtract(const Duration(hours: 3)),
      ),
      NotificationModel(
        id: '4', userId: 'user1',
        type: NotificationType.promo,
        titleAr: 'عرض خاص!', titleEn: 'Special Offer!',
        bodyAr: 'خصم 20% على رحلتك القادمة. استخدم الكود: DOZ20',
        bodyEn: '20% off your next ride. Use code: DOZ20',
        isRead: true, createdAt: now.subtract(const Duration(days: 1)),
      ),
      NotificationModel(
        id: '5', userId: 'user1',
        type: NotificationType.system,
        titleAr: 'تحديث التطبيق', titleEn: 'App Update',
        bodyAr: 'تحديث جديد متاح. استمتع بمزايا وتحسينات جديدة',
        bodyEn: 'A new update is available with new features',
        isRead: true, createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  void _markAsRead(String id) {
    setState(() {
      final idx = _notifications.indexWhere((n) => n.id == id);
      if (idx >= 0) _notifications[idx] = _notifications[idx].copyWith(isRead: true);
    });
  }

  void _markAllAsRead() {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

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
        title: Column(
          children: [
            Text(
              isArabic ? 'الإشعارات' : 'Notifications',
              style: DozTextStyles.sectionTitle(isArabic: isArabic),
            ),
            if (unreadCount > 0)
              Text(
                '$unreadCount ${isArabic ? 'غير مقروء' : 'unread'}',
                style: DozTextStyles.caption(isArabic: isArabic, color: DozColors.primaryGreen),
              ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                isArabic ? 'قراءة الكل' : 'Read all',
                style: DozTextStyles.bodySmall(isArabic: isArabic, color: DozColors.primaryGreen),
              ),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: DozLoading())
          : _notifications.isEmpty
              ? DozEmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: isArabic ? 'لا توجد إشعارات' : 'No notifications',
                  subtitle: isArabic ? 'ستظهر هنا إشعاراتك' : 'Your notifications will appear here',
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (_, i) {
                    final notif = _notifications[i];
                    return Dismissible(
                      key: Key(notif.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: AlignmentDirectional.centerEnd,
                        color: DozColors.primaryGreen,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.check_rounded, color: DozColors.primaryDark),
                      ),
                      onDismissed: (_) => _markAsRead(notif.id),
                      child: _NotificationItem(
                        notification: notif,
                        onTap: () => _markAsRead(notif.id),
                      ),
                    );
                  },
                ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationItem({required this.notification, required this.onTap});

  IconData _getIcon() {
    switch (notification.type) {
      case NotificationType.rideUpdate: return Icons.directions_car_rounded;
      case NotificationType.bidReceived:
      case NotificationType.bidAccepted: return Icons.gavel_rounded;
      case NotificationType.payment: return Icons.account_balance_wallet_rounded;
      case NotificationType.promo: return Icons.local_offer_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColor() {
    switch (notification.type) {
      case NotificationType.rideUpdate: return DozColors.statusArriving;
      case NotificationType.bidReceived:
      case NotificationType.bidAccepted: return DozColors.statusBidding;
      case NotificationType.payment: return DozColors.success;
      case NotificationType.promo: return DozColors.warning;
      default: return DozColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: isUnread ? DozColors.primaryGreenSurface : Colors.transparent,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _getColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_getIcon(), color: _getColor(), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                isArabic ? notification.titleAr : notification.titleEn,
                                style: DozTextStyles.bodyMedium(isArabic: isArabic)
                                    .copyWith(fontWeight: isUnread ? FontWeight.w700 : FontWeight.w500),
                              ),
                            ),
                            if (isUnread)
                              Container(
                                width: 8, height: 8,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: DozColors.primaryGreen,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isArabic ? notification.bodyAr : notification.bodyEn,
                          style: DozTextStyles.bodySmall(isArabic: isArabic, color: DozColors.textMuted),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DozFormatters.timeAgo(notification.createdAt, lang: isArabic ? 'ar' : 'en'),
                          style: DozTextStyles.caption(isArabic: isArabic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: DozColors.borderDark),
          ],
        ),
      ),
    );
  }
}
