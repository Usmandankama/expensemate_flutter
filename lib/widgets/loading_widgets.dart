import 'package:flutter/material.dart';
import '../utils/animation_utils.dart';
import 'animated_widgets.dart';

// ── Animated Loading Indicator ─────────────────────────────────────────────────

class AnimatedLoadingIndicator extends StatefulWidget {
  final double? size;
  final Color? color;
  final Duration? duration;

  const AnimatedLoadingIndicator({
    Key? key,
    this.size,
    this.color,
    this.duration,
  }) : super(key: key);

  @override
  State<AnimatedLoadingIndicator> createState() => _AnimatedLoadingIndicatorState();
}

class _AnimatedLoadingIndicatorState extends State<AnimatedLoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: widget.duration ?? AppAnimations.slow,
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: AppAnimations.smoothCurve,
    ));

    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationAnimation, _scaleAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: SizedBox(
              width: widget.size ?? 24.0,
              height: widget.size ?? 24.0,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.color ?? Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Animated Progress Bar ─────────────────────────────────────────────────────

class AnimatedProgressBar extends StatefulWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? progressColor;
  final double? height;
  final BorderRadius? borderRadius;
  final Duration? duration;

  const AnimatedProgressBar({
    Key? key,
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.height,
    this.borderRadius,
    this.duration,
  }) : super(key: key);

  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AppAnimations.medium,
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.smoothCurve,
    ));

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: AppAnimations.smoothCurve,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          height: widget.height ?? 8.0,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Colors.grey[300],
            borderRadius: widget.borderRadius ?? BorderRadius.circular(4.0),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _progressAnimation.value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: widget.progressColor ?? Theme.of(context).primaryColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(4.0),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Skeleton Loading Widget ───────────────────────────────────────────────────

class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonLoader({
    Key? key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        width: width,
        height: height ?? 16.0,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: borderRadius ?? BorderRadius.circular(4.0),
        ),
      ),
    );
  }
}

// ── Animated Card Skeleton ───────────────────────────────────────────────────

class AnimatedCardSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AnimatedCardSkeleton({
    Key? key,
    this.width,
    this.height,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      enableHover: false,
      enableScale: false,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            children: [
              SkeletonLoader(
                width: 40.0,
                height: 40.0,
                borderRadius: BorderRadius.circular(20.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      height: 16.0,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    const SizedBox(height: 8.0),
                    SkeletonLoader(
                      width: 100.0,
                      height: 12.0,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          // Content skeleton
          SkeletonLoader(
            height: 12.0,
            borderRadius: BorderRadius.circular(4.0),
          ),
          const SizedBox(height: 8.0),
          SkeletonLoader(
            height: 12.0,
            borderRadius: BorderRadius.circular(4.0),
          ),
          const SizedBox(height: 8.0),
          SkeletonLoader(
            width: 150.0,
            height: 12.0,
            borderRadius: BorderRadius.circular(4.0),
          ),
        ],
      ),
    );
  }
}

// ── Animated List Skeleton ────────────────────────────────────────────────────

class AnimatedListSkeleton extends StatelessWidget {
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  const AnimatedListSkeleton({
    Key? key,
    required this.itemCount,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          itemCount,
          (index) => AnimatedListItem(
            index: index,
            child: AnimatedCardSkeleton(
              margin: const EdgeInsets.only(bottom: 12.0),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Floating Action Button with Animation ───────────────────────────────────

class AnimatedFab extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Duration? duration;
  final bool enablePulse;

  const AnimatedFab({
    Key? key,
    required this.child,
    required this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.duration,
    this.enablePulse = false,
  }) : super(key: key);

  @override
  State<AnimatedFab> createState() => _AnimatedFabState();
}

class _AnimatedFabState extends State<AnimatedFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AppAnimations.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.9,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.defaultCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget fab = FloatingActionButton(
      onPressed: widget.onPressed,
      backgroundColor: widget.backgroundColor,
      child: widget.child,
    );

    if (widget.enablePulse) {
      fab = PulseWidget(
        child: fab,
      );
    }

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: fab,
      ),
    );
  }
}

// ── Animated Empty State Widget ───────────────────────────────────────────────

class AnimatedEmptyState extends StatelessWidget {
  final Widget icon;
  final String title;
  final String? subtitle;
  final Widget? action;
  final Duration? delay;

  const AnimatedEmptyState({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.delay,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedListItem(
      index: 0,
      delay: delay,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulseWidget(
                duration: AppAnimations.slow,
                child: IconTheme(
                  data: IconThemeData(
                    size: 64.0,
                    color: Theme.of(context).disabledColor,
                  ),
                  child: icon,
                ),
              ),
              const SizedBox(height: 24.0),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 8.0),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 24.0),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
