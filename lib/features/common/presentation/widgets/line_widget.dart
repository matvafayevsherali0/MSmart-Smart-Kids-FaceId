import 'package:flutter/material.dart';

class LineWidget extends StatelessWidget {
  const LineWidget({
    super.key,
    this.lead,
    required this.body,
    this.trail,
    this.bodyCrossAxisAlignment = CrossAxisAlignment.start,
    this.shape,
    this.isSelected = false,
    this.isEnabled = true,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.minHeight = 56,
    this.gap = 16,
    this.backgroundColor,
  });

  final Color? backgroundColor;

  final Widget? lead;
  final Widget body;
  final Widget? trail;

  final CrossAxisAlignment bodyCrossAxisAlignment;

  final ShapeBorder? shape;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  final EdgeInsetsGeometry padding;
  final double minHeight;
  final double gap;

  Color _background(ColorScheme scheme) {
    if (!isEnabled) {
      return scheme.onSurface.withValues(alpha: 0.08);
    }
    if (isSelected) {
      return scheme.primaryContainer;
    }
    return backgroundColor ?? scheme.surface;
  }

  Color _contentColor(ColorScheme scheme) {
    if (!isEnabled) {
      return scheme.onSurface.withValues(alpha: 0.38);
    }
    if (isSelected) {
      return scheme.onPrimaryContainer;
    }
    return scheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = _background(scheme);
    final fg = _contentColor(scheme);
    final effectiveShape = shape ?? RoundedRectangleBorder(borderRadius: BorderRadius.circular(12));
    final inkRadius = effectiveShape is RoundedRectangleBorder
        ? effectiveShape.borderRadius.resolve(Directionality.of(context))
        : BorderRadius.circular(12);

    final row = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (lead != null) ...[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [lead!],
            ),
            SizedBox(width: gap),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: bodyCrossAxisAlignment,
              mainAxisSize: MainAxisSize.min,
              children: [body],
            ),
          ),
          if (trail != null) ...[
            SizedBox(width: gap),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [trail!],
            ),
          ],
        ],
      ),
    );

    final themed = DefaultTextStyle.merge(
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg) ?? TextStyle(color: fg),
      child: IconTheme.merge(
        data: IconThemeData(color: fg),
        child: row,
      ),
    );

    final tappable = onTap != null && isEnabled;

    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Material(
        color: bg,
        shape: effectiveShape,
        clipBehavior: Clip.antiAlias,
        child: tappable
            ? InkWell(
                onTap: onTap,
                borderRadius: inkRadius,
                splashColor: fg.withValues(alpha: 0.12),
                highlightColor: fg.withValues(alpha: 0.06),
                child: themed,
              )
            : themed,
      ),
    );
  }
}
