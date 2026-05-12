import 'package:flutter/material.dart';
import '../utils/animation_utils.dart';

// ── Animated Card Widget ─────────────────────────────────────────────────────

class AnimatedCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Duration? animationDuration;
  final double? elevation;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final bool enableHover;
  final bool enableScale;

  const AnimatedCard({
    Key? key,
    required this.child,
    this.onTap,
    this.animationDuration,
    this.elevation,
    this.color,
    this.margin,
    this.padding,
    this.borderRadius,
    this.enableHover = true,
    this.enableScale = true,
  }) : super(key: key);

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? AppAnimations.fast,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.enableScale ? 1.05 : 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.smoothCurve,
    ));

    _elevationAnimation = Tween<double>(
      begin: widget.elevation ?? 2.0,
      end: (widget.elevation ?? 2.0) + 4.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.smoothCurve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHoverChange(bool isHovered) {
    if (!widget.enableHover) return;
    
    if (isHovered) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverChange(true),
      onExit: (_) => _onHoverChange(false),
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: AnimatedContainer(
                duration: AppAnimations.fast,
                margin: widget.margin,
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.color ?? Theme.of(context).cardColor,
                  borderRadius: widget.borderRadius ?? BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value / 2),
                    ),
                  ],
                ),
                child: child,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

// ── Animated List Item Widget ─────────────────────────────────────────────────

class AnimatedListItem extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration? delay;
  final Offset? startOffset;
  final Duration? duration;

  const AnimatedListItem({
    Key? key,
    required this.child,
    this.index = 0,
    this.delay,
    this.startOffset,
    this.duration,
  }) : super(key: key);

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    final totalDelay = Duration(
      milliseconds: (widget.delay?.inMilliseconds ?? 0) + (widget.index * 100),
    );
    
    _controller = AnimationController(
      duration: widget.duration ?? AppAnimations.medium,
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: widget.startOffset ?? const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.smoothCurve,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.smoothCurve,
    ));

    // Start animation after delay
    Future.delayed(totalDelay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _offsetAnimation,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

// ── Animated Button Widget ───────────────────────────────────────────────────

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration? duration;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? scaleDown;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool enableRipple;

  const AnimatedButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.duration,
    this.backgroundColor,
    this.foregroundColor,
    this.scaleDown,
    this.borderRadius,
    this.padding,
    this.enableRipple = true,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
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
      end: widget.scaleDown ?? 0.95,
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
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: AnimatedContainer(
              duration: AppAnimations.fast,
              padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Theme.of(context).primaryColor,
                borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
              ),
              child: widget.enableRipple
                  ? Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
                        onTap: widget.onPressed,
                        child: IconTheme(
                          data: IconThemeData(
                            color: widget.foregroundColor ?? Colors.white,
                          ),
                          child: widget.child,
                        ),
                      ),
                    )
                  : IconTheme(
                      data: IconThemeData(
                        color: widget.foregroundColor ?? Colors.white,
                      ),
                      child: widget.child,
                    ),
            ),
          );
        },
      ),
    );
  }
}

// ── Shimmer Loading Widget ───────────────────────────────────────────────────

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? duration;

  const ShimmerLoading({
    Key? key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration,
  }) : super(key: key);

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AppAnimations.slow,
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.defaultCurve,
    ));

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor ?? Colors.grey[300]!,
                widget.highlightColor ?? Colors.grey[100]!,
                widget.baseColor ?? Colors.grey[300]!,
              ],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: GradientRotation(_shimmerAnimation.value * 3.14159),
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

// ── Staggered Animation List Widget ────────────────────────────────────────────

class StaggeredAnimationList extends StatelessWidget {
  final List<Widget> children;
  final Duration? staggerDelay;
  final Duration? itemDuration;
  final Offset? startOffset;
  final Axis? direction;

  const StaggeredAnimationList({
    Key? key,
    required this.children,
    this.staggerDelay,
    this.itemDuration,
    this.startOffset,
    this.direction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return AnimatedListItem(
          index: index,
          delay: staggerDelay,
          duration: itemDuration,
          startOffset: startOffset,
          child: child,
        );
      }).toList(),
    );
  }
}

// ── Pulse Animation Widget ─────────────────────────────────────────────────────

class PulseWidget extends StatefulWidget {
  final Widget child;
  final Duration? duration;
  final double? minScale;
  final double? maxScale;
  final bool autoStart;

  const PulseWidget({
    Key? key,
    required this.child,
    this.duration,
    this.minScale,
    this.maxScale,
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? AppAnimations.slow,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale ?? 0.95,
      end: widget.maxScale ?? 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.defaultCurve,
    ));

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
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
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
