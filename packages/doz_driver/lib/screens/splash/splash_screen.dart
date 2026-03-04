import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:doz_shared/doz_shared.dart';
import '../../providers/auth_provider.dart';
import '../../providers/driver_provider.dart';
import '../../navigation/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
    _initialize();
  }

  Future<void> _initialize() async {
    await Future.wait([Future.delayed(const Duration(seconds: 2)), _checkAuth()]);
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.init();
    if (!mounted) return;
    if (auth.isAuthenticated) {
      await context.read<DriverProvider>().init();
      if (mounted) context.go(AppRoutes.home);
    } else {
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DozColors.primaryDark,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) => Transform.scale(scale: _pulseAnim.value, child: child),
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, gradient: DozColors.primaryGradient,
                    boxShadow: [BoxShadow(color: DozColors.primaryGreen.withOpacity(0.4), blurRadius: 32, spreadRadius: 8)],
                  ),
                  child: const Center(child: Text('D', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: DozColors.primaryDark, height: 1))),
                ),
              ),
              const SizedBox(height: 28),
              Text('DOZ', style: DozTextStyles.heroTitle(isArabic: false).copyWith(color: DozColors.textPrimary, fontSize: 40, letterSpacing: 6)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(color: DozColors.primaryGreenSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: DozColors.primaryGreen.withOpacity(0.3))),
                child: Text('DRIVER', style: DozTextStyles.labelLarge(isArabic: false).copyWith(color: DozColors.primaryGreen, letterSpacing: 4, fontSize: 13)),
              ),
              const SizedBox(height: 64),
              SizedBox(width: 32, height: 32, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(DozColors.primaryGreen.withOpacity(0.6)))),
            ],
          ),
        ),
      ),
    );
  }
}
