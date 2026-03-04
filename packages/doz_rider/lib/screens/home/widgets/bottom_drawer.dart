import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../../providers/ride_provider.dart';
import '../../../navigation/app_router.dart';
import 'search_bar_widget.dart';

/// Pull-up bottom drawer on the home screen.
/// Shows "Where to?" bar, recent places, and saved locations.
class HomeBottomDrawer extends StatelessWidget {
  final DraggableScrollableController controller;
  final VoidCallback onSearchTap;

  const HomeBottomDrawer({
    super.key,
    required this.controller,
    required this.onSearchTap,
  });

  static const List<Map<String, dynamic>> _recentPlaces = [
    {
      'icon': Icons.history_rounded,
      'name': 'وسط البلد',
      'nameEn': 'Downtown Amman',
      'address': 'شارع الرينبو، عمّان',
      'addressEn': 'Rainbow St, Amman',
    },
    {
      'icon': Icons.history_rounded,
      'name': 'مجمع الجاردنز',
      'nameEn': 'Gardens Mall',
      'address': 'الجاردنز، عمّان',
      'addressEn': 'Al Gardens, Amman',
    },
    {
      'icon': Icons.history_rounded,
      'name': 'مطار الملكة علياء',
      'nameEn': 'Queen Alia Airport',
      'address': 'الزيزياء، الأردن',
      'addressEn': 'Zizya, Jordan',
    },
  ];

  static const List<Map<String, dynamic>> _savedPlaces = [
    {
      'icon': Icons.home_rounded,
      'name': 'المنزل',
      'nameEn': 'Home',
      'address': 'أضف عنوان المنزل',
      'addressEn': 'Add home address',
      'color': DozColors.primaryGreen,
    },
    {
      'icon': Icons.work_rounded,
      'name': 'العمل',
      'nameEn': 'Work',
      'address': 'أضف عنوان العمل',
      'addressEn': 'Add work address',
      'color': DozColors.info,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isArabic = l10n.isArabic;

    return DraggableScrollableSheet(
      controller: controller,
      initialChildSize: 0.22,
      minChildSize: 0.12,
      maxChildSize: 0.7,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: DozColors.surfaceDark,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: DozColors.borderDark),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              children: [
                // Handle
                const SizedBox(height: 8),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DozColors.borderDark,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),

                // "Where to?" bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchBarWidget(onTap: onSearchTap),
                ),

                const SizedBox(height: 16),

                // Saved places
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _savedPlaces
                        .map((p) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 8),
                                child: _SavedPlaceChip(
                                  icon: p['icon'] as IconData,
                                  label: isArabic
                                      ? p['name'] as String
                                      : p['nameEn'] as String,
                                  color: p['color'] as Color,
                                  onTap: () {
                                    // TODO: set saved place as destination
                                  },
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Recent places
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      isArabic ? 'الأماكن الأخيرة' : 'Recent Places',
                      style: DozTextStyles.labelLarge(isArabic: isArabic),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                ..._recentPlaces.map(
                  (p) => _RecentPlaceItem(
                    icon: p['icon'] as IconData,
                    name: isArabic
                        ? p['name'] as String
                        : p['nameEn'] as String,
                    address: isArabic
                        ? p['address'] as String
                        : p['addressEn'] as String,
                    onTap: () {
                      context.push(
                        AppRoutes.locationSearch,
                        extra: {'isPickup': false},
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SavedPlaceChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SavedPlaceChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: DozColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DozColors.borderDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: DozTextStyles.bodySmall(
                isArabic: isArabic,
                color: DozColors.textSecondary,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentPlaceItem extends StatelessWidget {
  final IconData icon;
  final String name;
  final String address;
  final VoidCallback onTap;

  const _RecentPlaceItem({
    required this.icon,
    required this.name,
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = AppLocalizations.of(context).isArabic;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: DozColors.cardDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DozColors.borderDark),
        ),
        child: Icon(icon, color: DozColors.textMuted, size: 20),
      ),
      title: Text(
        name,
        style: DozTextStyles.bodyMedium(isArabic: isArabic)
            .copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        address,
        style: DozTextStyles.caption(isArabic: isArabic),
      ),
      trailing: const Icon(
        Icons.north_east_rounded,
        color: DozColors.textMuted,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}

