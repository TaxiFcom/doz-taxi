import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../../providers/driver_provider.dart';

/// Large animated online/offline toggle button.
class StatusToggle extends StatefulWidget {
  const StatusToggle({super.key});

  @override
  State<StatusToggle> createState() => _StatusToggleState();
}

class _StatusToggleState extends State<StatusToggle> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _toggle(DriverProvider driver) async {
    await _scaleController.forward();
    await _scaleController.reverse();
    if (driver.isOffline) {
      await driver.goOnline();
    } else {
      await driver.goOffline();
    }
  }

  @override
  Widget build(BuildContext context) {
    final driver = context.watch<DriverProvider>();
    final l = AppLocalizations.of(context);
    final isAr = l.isArabic;
    final isOnline = driver.isOnline;
    final isLoading = driver.status == DriverStatus.goingOnline || driver.isLoading;

    return GestureDetector(
      onTap: isLoading ? null : () => _toggle(driver),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: isOnline
            ? AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Transform.scale(scale: _pulseAnim.value, child: child),
                child: _buildButton(isOnline, isLoading, isAr, l),
              )
            : _buildButton(isOnline, isLoading, isAr, l),
      ),
    );
  }

  Widget _buildButton(bool isOnline, bool isLoading, bool isAr, AppLocalizations l) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (isOnline)
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(shape: BoxShape.circle, color: DozColors.primaryGreen.withOpacity(0.15)),
          ),
        Container(
          width: 96, height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isOnline
                ? DozColors.primaryGradient
                : const LinearGradient(colors: [Color(0xFF374151), Color(0xFF1F2937)]),
            boxShadow: [
              BoxShadow(
                color: isOnline ? DozColors.primaryGreen.withOpacity(0.5) : Colors.black.withOpacity(0.4),
                blurRadius: 24,
                spreadRadius: isOnline ? 4 : 0,
              ),
            ],
          ),
          child: isLoading
              ? const Center(child: SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 3, valueColor: AlwaysStoppedAnimation<Color>(DozColors.primaryDark))))
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isOnline ? Icons.power_settings_new : Icons.power_settings_new_outlined,
                        color: isOnline ? DozColors.primaryDark : DozColors.textMuted, size: 28),
                    const SizedBox(height: 4),
                    Text(isOnline ? l.t('youAreOnline') : l.t('goOnline'),
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: isOnline ? DozColors.primaryDark : DozColors.textMuted),
                        textAlign: TextAlign.center),
                  ],
                ),
        ),
      ],
    );
  }
}
