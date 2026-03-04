import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Generic confirmation dialog.
class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;
  final Color? confirmColor;
  final bool isDestructive;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel = 'Confirm',
    this.cancelLabel = 'Cancel',
    this.confirmColor,
    this.isDestructive = false,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        confirmColor: confirmColor,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final btnColor =
        confirmColor ?? (isDestructive ? DozColors.error : DozColors.primaryGreen);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

/// Status badge widget for ride/user status.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  static Widget forRideStatus(RideStatus status) {
    Color color, bg;
    String label;
    switch (status) {
      case RideStatus.pending:
        color = DozColors.warning;
        bg = DozColors.warningLight;
        label = 'Pending';
        break;
      case RideStatus.bidding:
        color = DozColors.statusBidding;
        bg = const Color(0xFFEDE9FE);
        label = 'Bidding';
        break;
      case RideStatus.accepted:
        color = DozColors.info;
        bg = DozColors.infoLight;
        label = 'Accepted';
        break;
      case RideStatus.driverArriving:
        color = DozColors.statusArriving;
        bg = const Color(0xFFCFFAFE);
        label = 'Arriving';
        break;
      case RideStatus.inProgress:
        color = DozColors.primaryGreen;
        bg = DozColors.primaryGreenSurface;
        label = 'In Progress';
        break;
      case RideStatus.completed:
        color = DozColors.success;
        bg = DozColors.successLight;
        label = 'Completed';
        break;
      case RideStatus.cancelled:
        color = DozColors.error;
        bg = DozColors.errorLight;
        label = 'Cancelled';
        break;
    }
    return StatusBadge(label: label, color: color, bgColor: bg);
  }

  static Widget forUserStatus(bool isActive) {
    return StatusBadge(
      label: isActive ? 'Active' : 'Blocked',
      color: isActive ? DozColors.success : DozColors.error,
      bgColor: isActive ? DozColors.successLight : DozColors.errorLight,
    );
  }

  static Widget forOnline(bool isOnline) {
    return StatusBadge(
      label: isOnline ? 'Online' : 'Offline',
      color: isOnline ? DozColors.success : DozColors.textMutedLight,
      bgColor:
          isOnline ? DozColors.successLight : const Color(0xFFF3F4F6),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
