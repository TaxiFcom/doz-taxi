import 'package:flutter/material.dart';
import 'package:doz_shared/doz_shared.dart';

/// Nearby drivers marker widget (placeholder — real data from WebSocket).
class NearbyDriversWidget extends StatelessWidget {
  final List<DriverModel> drivers;

  const NearbyDriversWidget({super.key, required this.drivers});

  @override
  Widget build(BuildContext context) {
    // This widget's actual content is rendered as Google Maps markers
    // in MapView — this is a placeholder used for overlay indicators.
    return const SizedBox.shrink();
  }
}
