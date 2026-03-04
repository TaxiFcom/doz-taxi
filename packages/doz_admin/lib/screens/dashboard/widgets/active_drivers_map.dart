import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Placeholder map widget showing active drivers count.
class ActiveDriversMap extends StatelessWidget {
  final int activeDrivers;

  const ActiveDriversMap({super.key, required this.activeDrivers});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: DozColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: DozColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Active Drivers',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: DozColors.textPrimaryLight,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: DozColors.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: DozColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '$activeDrivers online',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: DozColors.success,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Simulated map grid
                  CustomPaint(
                    painter: _MapGridPainter(),
                    child: Container(),
                  ),
                  // Driver markers
                  ...List.generate(
                    activeDrivers.clamp(0, 8),
                    (i) => Positioned(
                      left: 20.0 + (i % 4) * 80,
                      top: 20.0 + (i ~/ 4) * 60,
                      child: _DriverMarker(index: i),
                    ),
                  ),
                  // Amman label
                  const Positioned(
                    bottom: 8,
                    right: 12,
                    child: Text(
                      'Amman, Jordan',
                      style: TextStyle(
                        fontSize: 10,
                        color: DozColors.textMutedLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverMarker extends StatelessWidget {
  final int index;
  const _DriverMarker({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: DozColors.primaryGreen,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: DozColors.primaryGreen.withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(Icons.directions_car, size: 12, color: Colors.white),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB2DFDB).withOpacity(0.5)
      ..strokeWidth = 0.5;

    // Draw grid lines
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
