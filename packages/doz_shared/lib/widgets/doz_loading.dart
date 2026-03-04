import 'package:flutter/material.dart';
import '../theme/doz_colors.dart';
import '../theme/doz_text_styles.dart';

/// Full-screen or inline loading indicator with DOZ branding.
class DozLoading extends StatefulWidget {
  final String? message;
  final bool overlay;
  final double size;

  const DozLoading({
    super.key,
    this.message,
    this.overlay = false,
    this.size = 48,
  });

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: DozColors.overlay,
      builder: (_) => PopScope(
        canPop: false,
        child: DozLoading(message: message, overlay: true),
      ),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  @override
  State<DozLoading> createState() => _DozLoadingState();
}

class _DozLoadingState extends State<DozLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulse = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ScaleTransition(
          scale: _pulse,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: DozColors.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: SizedBox(
                width: widget.size * 0.55,
                height: widget.size * 0.55,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(DozColors.primaryGreen),
                  strokeWidth: 3,
                ),
              ),
            ),
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: DozTextStyles.bodyMedium(),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (widget.overlay) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: DozColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: DozColors.border),
          ),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Skeleton loader shimmer effect for list items.
class DozSkeleton extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;

  const DozSkeleton({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<DozSkeleton> createState() => _DozSkeletonState();
}

class _DozSkeletonState extends State<DozSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: const [
              DozColors.surface,
              DozColors.border,
              DozColors.surface,
            ],
            stops: [
              (_animation.value - 1).clamp(0.0, 1.0),
              _animation.value.clamp(0.0, 1.0),
              (_animation.value + 1).clamp(0.0, 1.0),
            ],
          ),
        ),
      ),
    );
  }
}
