import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/users_provider.dart';
import '../../widgets/admin_scaffold.dart';
import '../../widgets/data_table_widget.dart';
import '../../widgets/search_filter_bar.dart';
import '../../widgets/confirm_dialog.dart';
import 'user_detail_dialog.dart';

class RidersScreen extends StatefulWidget {
  const RidersScreen({super.key});

  @override
  State<RidersScreen> createState() => _RidersScreenState();
}

class _RidersScreenState extends State<RidersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UsersProvider>().loadRiders(reset: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      title: 'Riders',
      child: Consumer<UsersProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              SearchFilterBar(
                hintText: 'Search by name, phone, email...',
                onSearch: provider.setRiderSearch,
                chips: [
                  FilterChipData(
                    label: 'All',
                    isSelected: provider.riderActiveFilter == null,
                    onTap: () => provider.setRiderActiveFilter(null),
                  ),
                  FilterChipData(
                    label: 'Active',
                    isSelected: provider.riderActiveFilter == true,
                    onTap: () => provider.setRiderActiveFilter(true),
                  ),
                  FilterChipData(
                    label: 'Blocked',
                    isSelected: provider.riderActiveFilter == false,
                    onTap: () => provider.setRiderActiveFilter(false),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: DozColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: DozColors.borderLight),
                    ),
                    child: AdminDataTable<UserModel>(
                      columns: const [
                        DataColumn(label: Text('NAME')),
                        DataColumn(label: Text('PHONE')),
                        DataColumn(label: Text('EMAIL')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('JOINED')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: provider.riders,
                      rowBuilder: (user, index) => DataRow(
                        onSelectChanged: (_) =>
                            _showUserDetail(context, user, provider),
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor:
                                      DozColors.primaryGreenSurface,
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: DozColors.primaryGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Text(user.phone)),
                          DataCell(Text(user.email ?? '—')),
                          DataCell(StatusBadge.forUserStatus(user.isActive)),
                          DataCell(Text(
                            DozFormatters.dateShort(user.createdAt),
                            style: const TextStyle(fontSize: 11),
                          )),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () =>
                                      _showUserDetail(context, user, provider),
                                  icon: const Icon(Icons.visibility_outlined,
                                      size: 16),
                                  color: DozColors.info,
                                  tooltip: 'View',
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final confirm = await ConfirmDialog.show(
                                      context,
                                      title:
                                          user.isActive ? 'Block Rider' : 'Unblock Rider',
                                      message: user.isActive
                                          ? 'Block ${user.name}? They will not be able to use the app.'
                                          : 'Unblock ${user.name}?',
                                      confirmLabel:
                                          user.isActive ? 'Block' : 'Unblock',
                                      isDestructive: user.isActive,
                                    );
                                    if (confirm) {
                                      await provider.blockUser(
                                          user.id, user.isActive);
                                    }
                                  },
                                  icon: Icon(
                                    user.isActive
                                        ? Icons.block
                                        : Icons.check_circle_outline,
                                    size: 16,
                                  ),
                                  color: user.isActive
                                      ? DozColors.error
                                      : DozColors.success,
                                  tooltip: user.isActive ? 'Block' : 'Unblock',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      isLoading: provider.ridersLoading,
                      emptyMessage: 'No riders found',
                      currentPage: provider.riderPage,
                      totalPages: provider.riderTotalPages,
                      totalItems: provider.riderTotal,
                      pageSize: 20,
                      onPageChanged: provider.goToRiderPage,
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

  void _showUserDetail(
      BuildContext context, UserModel user, UsersProvider provider) {
    showDialog(
      context: context,
      builder: (_) => UserDetailDialog(
        user: user,
        onBlock: (block) => provider.blockUser(user.id, block),
      ),
    );
  }
}
