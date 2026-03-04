import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../providers/auth_provider.dart';
import '../navigation/app_router.dart';

class AdminSidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback onToggle;
  final String? currentRoute;

  const AdminSidebar({
    super.key,
    required this.isCollapsed,
    required this.onToggle,
    this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final route = currentRoute ?? GoRouterState.of(context).matchedLocation;
    final width = isCollapsed ? 64.0 : 240.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: width,
      decoration: const BoxDecoration(
        color: DozColors.surfaceLight,
        border: Border(
          right: BorderSide(color: DozColors.borderLight, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Logo area
          _buildLogo(context),
          const Divider(height: 1, thickness: 1, color: DozColors.borderLight),

          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: kNavItems.map((item) {
                final isActive = route.startsWith(item.route);
                return _NavItem(
                  item: item,
                  isActive: isActive,
                  isCollapsed: isCollapsed,
                  onTap: () => context.go(item.route),
                );
              }).toList(),
            ),
          ),

          // Bottom section
          const Divider(height: 1, thickness: 1, color: DozColors.borderLight),
          _buildBottomSection(context, auth),
        ],
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(
        horizontal: isCollapsed ? 12 : 16,
      ),
      child: Row(
        children: [
          // DOZ Logo mark
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: DozColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'D',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          if (!isCollapsed) ...[
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DOZ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: DozColors.textPrimaryLight,
                    letterSpacing: 1.5,
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  'Admin Panel',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: DozColors.textMutedLight,
                    letterSpacing: 0.3,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: onToggle,
              icon: const Icon(Icons.menu_open, size: 20),
              color: DozColors.textMutedLight,
              tooltip: 'Collapse sidebar',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, AuthProvider auth) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          if (isCollapsed)
            IconButton(
              onPressed: onToggle,
              icon: const Icon(Icons.menu, size: 20),
              color: DozColors.textMutedLight,
              tooltip: 'Expand sidebar',
            )
          else
            ListTile(
              leading: CircleAvatar(
                radius: 16,
                backgroundColor: DozColors.primaryGreenSurface,
                child: Text(
                  (auth.currentUser?.name.isNotEmpty ?? false)
                      ? auth.currentUser!.name[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: DozColors.primaryGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              title: Text(
                auth.currentUser?.name ?? 'Admin',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: DozColors.textPrimaryLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                auth.currentUser?.email ?? '',
                style: const TextStyle(
                  fontSize: 11,
                  color: DozColors.textMutedLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
          const SizedBox(height: 4),
          _LogoutButton(isCollapsed: isCollapsed),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavItem item;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  String _getLabel(BuildContext context) {
    // Map localization keys to English labels
    const labels = {
      'dashboard': 'Dashboard',
      'rides': 'Rides',
      'riders': 'Riders',
      'drivers': 'Drivers',
      'payments': 'Payments',
      'revenueReport': 'Revenue',
      'vehicleTypes': 'Vehicle Types',
      'promoCodes': 'Promo Codes',
      'support': 'Support',
      'settings': 'Settings',
    };
    return labels[item.labelKey] ?? item.labelKey;
  }

  @override
  Widget build(BuildContext context) {
    final label = _getLabel(context);
    if (isCollapsed) {
      return Tooltip(
        message: label,
        preferBelow: false,
        child: InkWell(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isActive
                  ? DozColors.primaryGreenSurface
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isActive ? item.activeIcon : item.icon,
              size: 20,
              color:
                  isActive ? DozColors.primaryGreen : DozColors.textMutedLight,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color:
                isActive ? DozColors.primaryGreenSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                size: 18,
                color: isActive
                    ? DozColors.primaryGreen
                    : DozColors.textMutedLight,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? DozColors.primaryGreen
                        : DozColors.textSecondaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isActive)
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: DozColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final bool isCollapsed;
  const _LogoutButton({required this.isCollapsed});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (isCollapsed) {
      return Tooltip(
        message: 'Logout',
        child: IconButton(
          onPressed: () => _confirmLogout(context, auth),
          icon: const Icon(Icons.logout, size: 18),
          color: DozColors.error,
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _confirmLogout(context, auth),
        icon: const Icon(Icons.logout, size: 16, color: DozColors.error),
        label: const Text(
          'Logout',
          style: TextStyle(color: DozColors.error, fontSize: 13),
        ),
        style: TextButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DozColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
