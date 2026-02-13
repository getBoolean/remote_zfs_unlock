import 'package:flutter/material.dart';

class FuturisticOutlinedButton extends StatelessWidget {
  const FuturisticOutlinedButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.accentColor,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onPressed != null;
    final accent = accentColor ?? scheme.secondary;
    final foregroundColor = enabled
        ? accent
        : scheme.onSurface.withValues(alpha: 0.45);

    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: Colors.transparent,
      side: BorderSide.none,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      textStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.24,
      ),
    ).copyWith(
      overlayColor: WidgetStatePropertyAll(accent.withValues(alpha: 0.14)),
    );

    final buttonChild = icon == null
        ? OutlinedButton(
            onPressed: onPressed,
            style: buttonStyle,
            child: Text(label),
          )
        : OutlinedButton.icon(
            onPressed: onPressed,
            style: buttonStyle,
            icon: Icon(icon, size: 18),
            label: Text(label),
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: enabled
            ? LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.18),
                  scheme.primary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: enabled
            ? scheme.surface.withValues(alpha: 0.2)
            : scheme.surface.withValues(alpha: 0.12),
        border: Border.all(
          color: enabled
              ? accent.withValues(alpha: 0.78)
              : scheme.outlineVariant.withValues(alpha: 0.8),
          width: 1.15,
        ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.2),
                  blurRadius: 10,
                  spreadRadius: 0.4,
                ),
              ]
            : null,
      ),
      child: buttonChild,
    );
  }
}
