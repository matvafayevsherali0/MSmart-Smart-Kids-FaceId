import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../assets/colors/colors.dart';

class CustomButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String? label;
  final Widget? child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final bool isLoading;
  final bool isDisabled;

  const CustomButton({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.height,
    this.width,
    this.padding,
    this.borderRadius = 16,
    this.isLoading = false,
    this.isDisabled = false,
  }) : assert(
          label != null || child != null,
          'label yoki child dan bittasi berilishi kerak',
        );

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 240),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  bool get _inactive =>
      widget.isDisabled || widget.isLoading || widget.onPressed == null;

  void _onHighlightChanged(bool pressed) {
    if (_inactive) return;
    if (pressed) {
      _pressController.forward();
    } else {
      _pressController.reverse();
    }
  }

  Future<void> _onTap() async {
    if (_inactive) return;
    await HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.backgroundColor ?? cBlue;
    final fg = widget.foregroundColor ?? cWhite;
    final radius = BorderRadius.circular(widget.borderRadius.r);
    final h = widget.height ?? 52.sp;

    return IgnorePointer(
      ignoring: _inactive,
      child: AnimatedOpacity(
        opacity: widget.isDisabled ? 0.45 : 1,
        duration: const Duration(milliseconds: 200),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: cBlack.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: Offset(0, 3.h),
              ),
            ],
          ),
          child: Material(
            color: bg,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _onTap,
              onHighlightChanged: _onHighlightChanged,
              borderRadius: radius,
              splashColor: fg.withValues(alpha: 0.22),
              highlightColor: fg.withValues(alpha: 0.1),
              child: SizedBox(
                width: widget.width,
                height: h,
                child: AnimatedBuilder(
                  animation: _scale,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scale.value,
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  child: Padding(
                    padding: widget.padding ??
                        EdgeInsets.symmetric(horizontal: 16.w),
                    child: Center(
                      child: widget.isLoading
                          ? SizedBox(
                              width: 22.sp,
                              height: 22.sp,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.sp,
                                color: fg,
                              ),
                            )
                          : DefaultTextStyle.merge(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: fg,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                              child: widget.child ??
                                  Text(
                                    widget.label ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textScaler: TextScaler.noScaling,
                                  ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
