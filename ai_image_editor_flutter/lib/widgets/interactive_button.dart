import 'package:flutter/material.dart';

/// Widget tùy chỉnh tạo hiệu ứng mờ khi nhấn cho các nút
class InteractiveButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final double pressedOpacity;
  final Duration animationDuration;

  const InteractiveButton({
    Key? key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.padding,
    this.backgroundColor,
    this.pressedOpacity = 0.6,
    this.animationDuration = const Duration(milliseconds: 100),
  }) : super(key: key);

  @override
  State<InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<InteractiveButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressedOpacity,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_isPressed && widget.onTap != null) {
      setState(() {
        _isPressed = true;
      });
      _animationController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
      if (widget.onTap != null) {
        widget.onTap!();
      }
    }
  }

  void _handleTapCancel() {
    if (_isPressed) {
      setState(() {
        _isPressed = false;
      });
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              padding: widget.padding,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: widget.borderRadius,
              ),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}

/// Extension methods để dễ dàng áp dụng hiệu ứng cho các widget khác
extension InteractiveWidget on Widget {
  Widget withInteractiveEffect({
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    Color? backgroundColor,
    double pressedOpacity = 0.6,
    Duration animationDuration = const Duration(milliseconds: 100),
  }) {
    return InteractiveButton(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: borderRadius,
      padding: padding,
      backgroundColor: backgroundColor,
      pressedOpacity: pressedOpacity,
      animationDuration: animationDuration,
      child: this,
    );
  }
}

/// Custom button với hiệu ứng mờ built-in
class FadeButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;
  final EdgeInsets padding;
  final Color? backgroundColor;
  final BorderRadius borderRadius;
  final double pressedOpacity;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const FadeButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.onLongPress,
    this.padding = const EdgeInsets.all(12),
    this.backgroundColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.pressedOpacity = 0.6,
    this.border,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InteractiveButton(
      onTap: onPressed,
      onLongPress: onLongPress,
      pressedOpacity: pressedOpacity,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: borderRadius,
          border: border,
          boxShadow: boxShadow,
        ),
        child: child,
      ),
    );
  }
}