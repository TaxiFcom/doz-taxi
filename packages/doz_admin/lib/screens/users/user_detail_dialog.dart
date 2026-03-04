import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../widgets/confirm_dialog.dart';

class UserDetailDialog extends StatelessWidget {
  final UserModel user;
  final DriverModel? driver;
  final Future<bool> Function(bool block) onBlock;
  final Future<bool> Function()? onApprove;

  const UserDetailDialog({
    super.key,
    required this.user,
    this.driver,
    required this.onBlock,
    this.onApprove,
  });

  @override
  Widget build(BuildContext context) {
    final isDriver = driver != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 540, maxHeight: 600),
        child: Column(
          children: [
            _Header(user: user, isDriver: isDriver),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile section
                    _ProfileSection(user: user),
                    const SizedBox(height: 20),

                    // Stats row
                    _StatsRow(user: user, driver: driver),
                    const SizedBox(height: 20),

                    // Vehicle info (driver only)
                    if (driver != null) ...[
                      _VehicleSection(driver: driver!),
                      const SizedBox(height: 20),
                    ],

                    // Account info
                    _AccountInfo(user: user),
                  ],
                ),
              ),
            ),
            _Actions(
              user: user,
              onBlock: onBlock,
              onApprove: onApprove,
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final UserModel user;
  final bool isDriver;
  const _Header({required this.user, required this.isDriver});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: DozColors.backgroundLight,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        border: Border(bottom: BorderSide(color: DozColors.borderLight)),
      ),
      child: Row(
        children: [
          Icon(
            isDriver ? Icons.drive_eta : Icons.person,
            color: DozColors.primaryGreen,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isDriver ? 'Driver Profile' : 'Rider Profile',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DozColors.textPrimaryLight,
            ),
          ),
          const SizedBox(width: 10),
          StatusBadge.forUserStatus(user.isActive),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 20),
            color: DozColors.textMutedLight,
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final UserModel user;
  const _ProfileSection({required this.user});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: DozColors.primaryGreenSurface,
          child: Text(
            user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: DozColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: DozColors.textPrimaryLight,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone,
                      size: 13, color: DozColors.textMutedLight),
                  const SizedBox(width: 4),
                  Text(
                    user.phone,
                    style: const TextStyle(
                        fontSize: 13, color: DozColors.textMutedLight),
                  ),
                ],
              ),
              if (user.email != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.email,
                        size: 13, color: DozColors.textMutedLight),
                    const SizedBox(width: 4),
                    Text(
                      user.email!,
                      style: const TextStyle(
                          fontSize: 13, color: DozColors.textMutedLight),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final UserModel user;
  final DriverModel? driver;
  const _StatsRow({required this.user, this.driver});

  @override
  Widget build(BuildContext context) {
    final stats = driver != null
        ? [
            ('Rides', driver!.totalRides.toString()),
            ('Rating', driver!.rating.toStringAsFixed(1)),
            ('Earnings', '${driver!.totalEarnings.toStringAsFixed(0)} JOD'),
            ('Status',
                driver!.isOnline ? 'Online' : 'Offline'),
          ]
        : [
            ('Rides', '—'),
            ('Wallet', '0 JOD'),
            ('Language', user.lang.toUpperCase()),
            ('Verified', user.isVerified ? 'Yes' : 'No'),
          ];

    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
                right: stats.last == s ? 0 : 12),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: DozColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: DozColors.borderLight),
            ),
            child: Column(
              children: [
                Text(
                  s.$2,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: DozColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.$1,
                  style: const TextStyle(
                    fontSize: 11,
                    color: DozColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _VehicleSection extends StatelessWidget {
  final DriverModel driver;
  const _VehicleSection({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DozColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DozColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.commute, size: 16, color: DozColors.primaryGreen),
              SizedBox(width: 8),
              Text(
                'Vehicle Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: DozColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: DozColors.borderLight),
          const SizedBox(height: 12),
          _VehicleRow('Vehicle Type', driver.vehicleType),
          _VehicleRow('Vehicle Model', driver.vehicleModel),
          _VehicleRow('Vehicle Color', driver.vehicleColor),
          _VehicleRow('Plate Number', driver.plateNumber),
          _VehicleRow('License Number', driver.licenseNumber),
        ],
      ),
    );
  }
}

class _VehicleRow extends StatelessWidget {
  final String label;
  final String value;
  const _VehicleRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: DozColors.textMutedLight)),
          Text(
            value.isEmpty ? '—' : value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DozColors.textPrimaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountInfo extends StatelessWidget {
  final UserModel user;
  const _AccountInfo({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DozColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DozColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: DozColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: DozColors.borderLight),
          const SizedBox(height: 12),
          _VehicleRow('User ID', user.id.substring(0, 16) + '...'),
          _VehicleRow('Joined', DozFormatters.date(user.createdAt, lang: 'en')),
          _VehicleRow('Language', user.lang == 'ar' ? 'Arabic' : 'English'),
          _VehicleRow('Verified', user.isVerified ? 'Yes' : 'No'),
          _VehicleRow('Role', user.role.name.capitalize()),
        ],
      ),
    );
  }
}

class _Actions extends StatefulWidget {
  final UserModel user;
  final Future<bool> Function(bool) onBlock;
  final Future<bool> Function()? onApprove;

  const _Actions({
    required this.user,
    required this.onBlock,
    this.onApprove,
  });

  @override
  State<_Actions> createState() => _ActionsState();
}

class _ActionsState extends State<_Actions> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: DozColors.backgroundLight,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border(top: BorderSide(color: DozColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (widget.onApprove != null) ...[
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);
                      await widget.onApprove!();
                      setState(() => _loading = false);
                      if (context.mounted) Navigator.pop(context);
                    },
              icon: const Icon(Icons.check_circle_outline, size: 16),
              label: const Text('Approve Driver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: DozColors.success,
                foregroundColor: Colors.white,
              ),
            ),
          ],
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _loading
                ? null
                : () async {
                    final confirm = await ConfirmDialog.show(
                      context,
                      title: widget.user.isActive
                          ? 'Block User'
                          : 'Unblock User',
                      message: widget.user.isActive
                          ? 'Block ${widget.user.name}?'
                          : 'Unblock ${widget.user.name}?',
                      isDestructive: widget.user.isActive,
                      confirmLabel:
                          widget.user.isActive ? 'Block' : 'Unblock',
                    );
                    if (confirm) {
                      setState(() => _loading = true);
                      await widget.onBlock(widget.user.isActive);
                      setState(() => _loading = false);
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
            icon: Icon(
              widget.user.isActive ? Icons.block : Icons.check_circle_outline,
              size: 16,
            ),
            label:
                Text(widget.user.isActive ? 'Block User' : 'Unblock User'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  widget.user.isActive ? DozColors.error : DozColors.success,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCapitalize on String {
  String capitalize() =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
}
