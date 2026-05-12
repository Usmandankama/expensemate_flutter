import 'package:flutter/material.dart';

class AppAnimations {
  // ── Animation Durations ─────────────────────────────────────────────────────
  
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration extraSlow = Duration(milliseconds: 800);
  
  // ── Animation Curves ───────────────────────────────────────────────────────
  
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve bounceCurve = Curves.easeOutBack;
  static const Curve smoothCurve = Curves.easeOutCubic;
  static const Curve sharpCurve = Curves.easeInOutCubic;
  
  // ── Page Transition Animations ─────────────────────────────────────────────
  
  static Widget slideTransition(Widget child, Animation<double> animation, {bool slideFromRight = true}) {
    final offsetBegin = slideFromRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
    final offsetEnd = Offset.zero;
    
    return SlideTransition(
      position: Tween<Offset>(
        begin: offsetBegin,
        end: offsetEnd,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: smoothCurve,
      )),
      child: child,
    );
  }
  
  static Widget fadeTransition(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
  
  static Widget scaleTransition(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: bounceCurve,
      )),
      child: child,
    );
  }
  
  // ── Widget Animation Builders ─────────────────────────────────────────────
  
  static Widget animatedContainer({
    required Widget child,
    Duration duration = medium,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    Color? color,
    Decoration? decoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
  }) {
    return AnimatedContainer(
      duration: duration,
      padding: padding,
      margin: margin,
      color: color,
      decoration: decoration,
      width: width,
      height: height,
      constraints: constraints,
      child: child,
    );
  }
  
  static Widget animatedSwitcher({
    required Widget child,
    Duration duration = medium,
    AnimatedSwitcherTransitionBuilder? transitionBuilder,
  }) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: transitionBuilder ?? (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }
  
  // ── Gesture Animation Widgets ───────────────────────────────────────────────
  
  static Widget animatedButton({
    required Widget child,
    required VoidCallback onPressed,
    Duration duration = fast,
    double scaleDown = 0.95,
    double? scaleUp,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.0),
      duration: duration,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (_) {
          // Scale down animation handled by TweenAnimationBuilder
        },
        onTapUp: (_) {
          onPressed();
        },
        onTapCancel: () {
          // Reset to normal scale
        },
        child: child,
      ),
    );
  }
  
  // ── List Item Animations ───────────────────────────────────────────────────
  
  static Widget slideInListItem({
    required Widget child,
    int index = 0,
    Duration duration = medium,
    Offset startOffset = const Offset(0.0, 0.3),
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween<Offset>(begin: startOffset, end: Offset.zero),
      duration: Duration(milliseconds: duration.inMilliseconds + (index * 50)),
      curve: smoothCurve,
      builder: (context, offset, child) {
        return SlideTransition(
          position: AlwaysStoppedAnimation(offset),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: AnimationController(
                  vsync: Navigator.of(context),
                  duration: Duration(milliseconds: duration.inMilliseconds + (index * 50)),
                )..forward(),
                curve: smoothCurve,
              ),
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
  
  // ── Shimmer Loading Animation ───────────────────────────────────────────────
  
  static Widget shimmerLoading({
    required Widget child,
    Color baseColor = const Color(0xFFE0E0E0),
    Color highlightColor = const Color(0xFFF5F5F5),
    Duration duration = slow,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: -1.0, end: 2.0),
      duration: duration,
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: GradientRotation(value * 3.14159),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }
  
  // ── Pulse Animation ──────────────────────────────────────────────────────────
  
  static Widget pulse({
    required Widget child,
    Duration duration = slow,
    double minScale = 0.95,
    double maxScale = 1.05,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: minScale, end: maxScale),
      duration: duration,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      onEnd: () {
        // Reverse animation
      },
      child: child,
    );
  }
  
  // ── Staggered Animation Helper ───────────────────────────────────────────────
  
  static List<Duration> getStaggeredDurations(int count, Duration baseDuration) {
    return List.generate(count, (index) {
      return Duration(milliseconds: baseDuration.inMilliseconds + (index * 100));
    });
  }
  
  // ── Custom Page Route ───────────────────────────────────────────────────────
  
  static Route<T> slidePageRoute<T>({
    required Widget page,
    Duration duration = medium,
    bool slideFromRight = true,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return slideTransition(child, animation, slideFromRight: slideFromRight);
      },
    );
  }
  
  static Route<T> fadePageRoute<T>({
    required Widget page,
    Duration duration = medium,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return fadeTransition(child, animation);
      },
    );
  }
  
  static Route<T> scalePageRoute<T>({
    required Widget page,
    Duration duration = medium,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return scaleTransition(child, animation);
      },
    );
  }
}

// ── Animated Widget Extensions ─────────────────────────────────────────────────

extension WidgetAnimationExtensions on Widget {
  Widget animateWith({
    Duration duration = AppAnimations.medium,
    Curve curve = AppAnimations.defaultCurve,
    Offset? slideOffset,
    bool fadeIn = true,
    bool scaleIn = false,
  }) {
    Widget animated = this;
    
    if (slideOffset != null) {
      animated = TweenAnimationBuilder<Offset>(
        tween: Tween<Offset>(begin: slideOffset, end: Offset.zero),
        duration: duration,
        curve: curve,
        builder: (context, offset, child) {
          return SlideTransition(
            position: AlwaysStoppedAnimation(offset),
            child: child,
          );
        },
        child: animated,
      );
    }
    
    if (fadeIn) {
      animated = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: duration,
        curve: curve,
        builder: (context, opacity, child) {
          return Opacity(
            opacity: opacity,
            child: child,
          );
        },
        child: animated,
      );
    }
    
    if (scaleIn) {
      animated = TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.8, end: 1.0),
        duration: duration,
        curve: curve,
        builder: (context, scale, child) {
          return Transform.scale(
            scale: scale,
            child: child,
          );
        },
        child: animated,
      );
    }
    
    return animated;
  }
}
