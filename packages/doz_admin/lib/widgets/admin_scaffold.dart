import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../providers/auth_provider.dart';
import 'sidebar.dart';

/// Main layout wrapper for all admin screens.
/// Provides sidebar + top bar + content area.
class AdminScaffold extends StatefulWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;

  const AdminScaffold({
    super.key,
    required this.title,
    required this.child,
    this.actions,
  });

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  bool _sidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Auto-collapse on tablet
    if (screenWidth < 1100 && !_sidebarCollapsed) {
      _sidebarCollapsed = true;
    }

    return Scaffold(
      backgroundColor: DozColors.backgroundLight,
      body: Row(
        children: [
          // Sidebar
          AdminSidebar(
            isCollapsed: _sidebarCollapsed,
            onToggle: () =>
                setState(() => _sidebarCollapsed = !_sidebarCollapsed),
            currentRoute: GoRouterState.of(context).matchedLocation,
          ),

          // Main content
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  title: widget.title,
                  actions: widget.actions,
                  onMenuToggle: () =>
                      setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                ),
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final VoidCallback onMenuToggle;

  const _TopBar({
    required this.title,
    this.actions,
    required this.onMenuToggle,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: DozColors.surfaceLight,
        border: Border(
          bottom: BorderSide(color: DozColors.borderLight, width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: DozColors.textPrimaryLight,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          if (actions != null) ...actions!,
          const SizedBox(width: 12),
          // Notification bell
          IconButton(
            onPressed: () {},
            icon: Badge(
              backgroundColor: DozColors.error,
              smallSize: 8,
              child: const Icon(Icons.notifications_outlined, size: 22),
            ),
            color: DozColors.textMutedLight,
            tooltip: 'Notifications',
          ),
          const SizedBox(width: 8),
          // Admin avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: DozColors.primaryGreenSurface,
            child: Text(
              (auth.currentUser?.name.isNotEmpty ?? false)
                  ? auth.currentUser!.name[0].toUpperCase()
                  : 'A',
              style: const TextStyle(
                color: DozColors.primaryGreen,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
