import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/drivers_provider.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/data_table_widget.dart';
import '../../widgets/search_filter_bar.dart';
import '../../widgets/confirm_dialog.dart';
import 'user_detail_dialog.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DriversProvider>().loadDrivers(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Drivers',
      child: Consumer<DriversProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              // Filter bar
              SearchFilterBar(
                hintText: 'Search by name, phone, plate...',
                onSearch: provider.setSearchQuery,
                chips: [
                  FilterChipData(
                    label: 'All',
                    isSelected:
                        provider.statusFilter == DriverStatusFilter.all,
                    onTap: () =>
                        provider.setStatusFilter(DriverStatusFilter.all),
                  ),
                  FilterChipData(
                    label: 'Pending Approval',
                    isSelected:
                        provider.statusFilter == DriverStatusFilter.pending,
                    onTap: () =>
                        provider.setStatusFilter(DriverStatusFilter.pending),
                  ),
                  FilterChipData(
                    label: 'Active',
                    isSelected:
                        provider.statusFilter == DriverStatusFilter.active,
                    onTap: () =>
                        provider.setStatusFilter(DriverStatusFilter.active),
                  ),
                  FilterChipData(
                    label: 'Blocked',
                    isSelected:
                        provider.statusFilter == DriverStatusFilter.blocked,
                    onTap: () =>
                        provider.setStatusFilter(DriverStatusFilter.blocked),
                  ),
                ],
              ),

              // Pending approval highlight section
              if (provider.pendingDrivers.isNotEmpty)
                _PendingApprovalBanner(
                  count: provider.pendingDrivers.length,
                  onFilter: () => provider
                      .setStatusFilter(DriverStatusFilter.pending),
                ),

              // Main table
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: DozColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: DozColors.borderLight),
                    ),
                    child: AdminDataTable<DriverModel>(
                      columns: const [
                        DataColumn(label: Text('NAME')),
                        DataColumn(label: Text('PHONE')),
                        DataColumn(label: Text('VEHICLE')),
                        DataColumn(label: Text('PLATE')),
                        DataColumn(label: Text('RATING'), numeric: true),
                        DataColumn(label: Text('RIDES'), numeric: true),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('ONLINE')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: provider.drivers,
                      rowBuilder: (driver, index) {
                        final user = driver.user;
                        final isPending =
                            user != null && !user.isVerified && user.isActive;
                        return DataRow(
                          color: WidgetStateProperty.resolveWith((states) {
                            if (isPending) {
                              return DozColors.warningLight.withOpacity(0.3);
                            }
                            return null;
                          }),
                          onSelectChanged: (_) =>
                              _showDriverDetail(context, driver, provider),
                          cells: [
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: isPending
                                        ? DozColors.warningLight
                                        : DozColors.primaryGreenSurface,
                                    child: Text(
                                      (user?.name.isNotEmpty ?? false)
                                          ? user!.name[0].toUpperCase()
                                          : 'D',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: isPending
                                            ? DozColors.warning
                                            : DozColors.primaryGreen,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        user?.name ?? '—',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                      if (isPending)
                                        const Text(
                                          'Pending Approval',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: DozColors.warning,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            DataCell(Text(user?.phone ?? '—')),
                            DataCell(Text(driver.vehicleModel.isEmpty
                                ? '—'
                                : driver.vehicleModel)),
                            DataCell(Text(driver.plateNumber.isEmpty
                                ? '—'
                                : driver.plateNumber)),
                            DataCell(Row(
                              children: [
                                const Icon(Icons.star,
                                    size: 12, color: DozColors.warning),
                                const SizedBox(width: 3),
                                Text(driver.rating.toStringAsFixed(1)),
                              ],
                            )),
                            DataCell(Text(driver.totalRides.toString())),
                            DataCell(StatusBadge.forUserStatus(
                                user?.isActive ?? false)),
                            DataCell(
                                StatusBadge.forOnline(driver.isOnline)),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isPending)
                                    IconButton(
                                      onPressed: () async {
                                        final confirm =
                                            await ConfirmDialog.show(
                                          context,
                                          title: 'Approve Driver',
                                          message:
                                              'Approve ${user?.name} as a driver?',
                                          confirmLabel: 'Approve',
                                          confirmColor: DozColors.success,
                                        );
                                        if (confirm) {
                                          await provider
                                              .approveDriver(driver.id);
                                        }
                                      },
                                      icon: const Icon(
                                          Icons.check_circle_outline,
                                          size: 16),
                                      color: DozColors.success,
                                      tooltip: 'Approve',
                                    ),
                                  IconButton(
                                    onPressed: () =>
                                        _showDriverDetail(
                                            context, driver, provider),
                                    icon: const Icon(
                                        Icons.visibility_outlined,
                                        size: 16),
                                    color: DozColors.info,
                                    tooltip: 'View',
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      final isActive =
                                          user?.isActive ?? false;
                                      final confirm = await ConfirmDialog.show(
                                        context,
                                        title: isActive
                                            ? 'Block Driver'
                                            : 'Unblock Driver',
                                        message: isActive
                                            ? 'Block ${user?.name}?'
                                            : 'Unblock ${user?.name}?',
                                        isDestructive: isActive,
                                        confirmLabel:
                                            isActive ? 'Block' : 'Unblock',
                                      );
                                      if (confirm && user != null) {
                                        await provider.blockDriver(
                                            user.id, isActive);
                                      }
                                    },
                                    icon: Icon(
                                      (user?.isActive ?? false)
                                          ? Icons.block
                                          : Icons.check_circle_outline,
                                      size: 16,
                                    ),
                                    color: (user?.isActive ?? false)
                                        ? DozColors.error
                                        : DozColors.success,
                                    tooltip: (user?.isActive ?? false)
                                        ? 'Block'
                                        : 'Unblock',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      isLoading: provider.isLoading,
                      emptyMessage: 'No drivers found',
                      currentPage: provider.page,
                      totalPages: provider.totalPages,
                      totalItems: provider.total,
                      pageSize: 20,
                      onPageChanged: provider.goToPage,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDriverDetail(
      BuildContext context, DriverModel driver, DriversProvider provider) {
    if (driver.user == null) return;
    showDialog(
      context: context,
      builder: (_) => UserDetailDialog(
        user: driver.user!,
        driver: driver,
        onBlock: (block) =>
            provider.blockDriver(driver.user!.id, block),
        onApprove: driver.user!.isVerified
            ? null
            : () => provider.approveDriver(driver.id),
      ),
    );
  }
}

class _PendingApprovalBanner extends StatelessWidget {
  final int count;
  final VoidCallback onFilter;

  const _PendingApprovalBanner(
      {required this.count, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onFilter,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: DozColors.warningLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DozColors.warning.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.pending_actions,
                size: 18, color: DozColors.warning),
            const SizedBox(width: 10),
            Text(
              '$count driver${count > 1 ? 's' : ''} pending approval',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DozColors.warningDark,
              ),
            ),
            const Spacer(),
            const Text(
              'View all →',
              style: TextStyle(
                fontSize: 12,
                color: DozColors.warning,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
