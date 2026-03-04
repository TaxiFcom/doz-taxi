import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../widgets/confirm_dialog.dart';

class RideDetailDialog extends StatelessWidget {
  final RideModel ride;

  const RideDetailDialog({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 700),
        child: Column(
          children: [
            _DialogHeader(ride: ride),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Map placeholder
                    _MapPlaceholder(ride: ride),
                    const SizedBox(height: 20),

                    // Rider + Driver side by side
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: _PersonCard(
                          title: 'Rider',
                          name: ride.rider?.name ?? 'Unknown Rider',
                          phone: ride.rider?.phone ?? '—',
                          icon: Icons.person,
                          color: DozColors.info,
                        )),
                        const SizedBox(width: 16),
                        Expanded(child: _PersonCard(
                          title: 'Driver',
                          name: ride.driver?.user?.name ?? 'Unassigned',
                          phone: ride.driver?.user?.phone ?? '—',
                          icon: Icons.drive_eta,
                          color: DozColors.primaryGreen,
                          subtitle: ride.driver?.vehicleModel,
                          subSubtitle: ride.driver?.plateNumber,
                        )),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Fare breakdown
                    _FareBreakdown(ride: ride),
                    const SizedBox(height: 20),

                    // Timeline
                    _RideTimeline(ride: ride),
                  ],
                ),
              ),
            ),
            _DialogActions(ride: ride),
          ],
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final RideModel ride;
  const _DialogHeader({required this.ride});

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
          const Icon(Icons.directions_car, color: DozColors.primaryGreen, size: 20),
          const SizedBox(width: 8),
          Text(
            'Ride #${ride.id.substring(0, 12).toUpperCase()}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: DozColors.textPrimaryLight,
            ),
          ),
          const SizedBox(width: 12),
          StatusBadge.forRideStatus(ride.status),
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

class _MapPlaceholder extends StatelessWidget {
  final RideModel ride;
  const _MapPlaceholder({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DozColors.borderLight),
      ),
      child: Stack(
        children: [
          CustomPaint(
            painter: _GridPainter(),
            size: Size.infinite,
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LocationPin(
                  color: DozColors.primaryGreen,
                  label: 'Pickup',
                  address: ride.pickupAddress,
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [DozColors.primaryGreen, DozColors.error],
                      ),
                    ),
                    child: const Icon(Icons.arrow_forward, size: 14,
                        color: Colors.white),
                  ),
                ),
                _LocationPin(
                  color: DozColors.error,
                  label: 'Dropoff',
                  address: ride.dropoffAddress,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationPin extends StatelessWidget {
  final Color color;
  final String label;
  final String address;
  const _LocationPin({required this.color, required this.label, required this.address});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_pin, color: color, size: 28),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 4,
                )
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF90CAA3).withOpacity(0.3)
      ..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PersonCard extends StatelessWidget {
  final String title;
  final String name;
  final String phone;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final String? subSubtitle;

  const _PersonCard({
    required this.title,
    required this.name,
    required this.phone,
    required this.icon,
    required this.color,
    this.subtitle,
    this.subSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DozColors.backgroundLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: DozColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: DozColors.textMutedLight)),
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DozColors.textPrimaryLight)),
                Text(phone, style: const TextStyle(fontSize: 12, color: DozColors.textMutedLight)),
                if (subtitle != null) Text(subtitle!, style: const TextStyle(fontSize: 11, color: DozColors.textMutedLight)),
                if (subSubtitle != null) Text(subSubtitle!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: DozColors.primaryGreen)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FareBreakdown extends StatelessWidget {
  final RideModel ride;
  const _FareBreakdown({required this.ride});

  @override
  Widget build(BuildContext context) {
    final price = ride.finalPrice ?? ride.suggestedPrice;
    final commission = ride.commissionAmount ?? (price * 0.15);
    final driverEarning = price - commission;

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
          const Text('Fare Breakdown', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DozColors.textPrimaryLight)),
          const SizedBox(height: 12),
          _FareRow('Suggested Price', ride.suggestedPrice),
          if (ride.finalPrice != null) _FareRow('Final Price', ride.finalPrice!, isHighlighted: true),
          if (ride.distanceKm != null) _InfoRow('Distance', '${ride.distanceKm!.toStringAsFixed(2)} km'),
          if (ride.durationMin != null) _InfoRow('Duration', '${ride.durationMin} min'),
          const Divider(height: 16, color: DozColors.borderLight),
          _FareRow('Platform Commission (15%)', commission, color: DozColors.error),
          _FareRow('Driver Earnings', driverEarning, color: DozColors.success),
          const Divider(height: 16, color: DozColors.borderLight),
          _InfoRow('Payment Method', _methodLabel(ride.paymentMethod)),
        ],
      ),
    );
  }

  String _methodLabel(PaymentMethod m) {
    switch (m) {
      case PaymentMethod.cash: return 'Cash';
      case PaymentMethod.wallet: return 'Wallet';
      case PaymentMethod.card: return 'Card';
    }
  }
}

class _FareRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isHighlighted;
  final Color? color;
  const _FareRow(this.label, this.amount, {this.isHighlighted = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: DozColors.textSecondaryLight, fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400)),
          Text('${amount.toStringAsFixed(3)} JOD', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color ?? (isHighlighted ? DozColors.textPrimaryLight : DozColors.textSecondaryLight), fontFamily: 'Inter')),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: DozColors.textSecondaryLight)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: DozColors.textPrimaryLight)),
        ],
      ),
    );
  }
}

class _RideTimeline extends StatelessWidget {
  final RideModel ride;
  const _RideTimeline({required this.ride});

  @override
  Widget build(BuildContext context) {
    final events = <_TimelineEvent>[];
    events.add(_TimelineEvent(label: 'Created', time: ride.createdAt, isCompleted: true, color: DozColors.primaryGreen));
    if (ride.acceptedAt != null) events.add(_TimelineEvent(label: 'Driver Accepted', time: ride.acceptedAt!, isCompleted: true, color: DozColors.info));
    if (ride.arrivedAt != null) events.add(_TimelineEvent(label: 'Driver Arrived', time: ride.arrivedAt!, isCompleted: true, color: DozColors.statusArriving));
    if (ride.startedAt != null) events.add(_TimelineEvent(label: 'Ride Started', time: ride.startedAt!, isCompleted: true, color: DozColors.warning));
    if (ride.completedAt != null) events.add(_TimelineEvent(label: 'Completed', time: ride.completedAt!, isCompleted: true, color: DozColors.success));
    if (ride.cancelledAt != null) events.add(_TimelineEvent(label: 'Cancelled', time: ride.cancelledAt!, isCompleted: true, color: DozColors.error));
    if (events.isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: DozColors.backgroundLight, borderRadius: BorderRadius.circular(10), border: Border.all(color: DozColors.borderLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Timeline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: DozColors.textPrimaryLight)),
          const SizedBox(height: 12),
          ...events.asMap().entries.map((e) => _TimelineTile(event: e.value, isLast: e.key == events.length - 1)),
        ],
      ),
    );
  }
}

class _TimelineEvent {
  final String label;
  final DateTime time;
  final bool isCompleted;
  final Color color;
  const _TimelineEvent({required this.label, required this.time, required this.isCompleted, required this.color});
}

class _TimelineTile extends StatelessWidget {
  final _TimelineEvent event;
  final bool isLast;
  const _TimelineTile({required this.event, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(width: 12, height: 12, decoration: BoxDecoration(color: event.color, shape: BoxShape.circle)),
              if (!isLast) Expanded(child: Container(width: 2, color: DozColors.borderLight, margin: const EdgeInsets.symmetric(vertical: 2))),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(event.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: DozColors.textSecondaryLight)),
                  Text('${DozFormatters.dateShort(event.time)} ${DozFormatters.time(event.time, lang: 'en')}', style: const TextStyle(fontSize: 11, color: DozColors.textMutedLight)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogActions extends StatelessWidget {
  final RideModel ride;
  const _DialogActions({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: DozColors.backgroundLight,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
        border: Border(top: BorderSide(color: DozColors.borderLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          const SizedBox(width: 8),
          if (ride.status == RideStatus.inProgress || ride.status == RideStatus.accepted)
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cancel_outlined, size: 16),
              label: const Text('Force Cancel'),
              style: ElevatedButton.styleFrom(backgroundColor: DozColors.error, foregroundColor: Colors.white),
            ),
        ],
      ),
    );
  }
}
