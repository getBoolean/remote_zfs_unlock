import 'package:flutter/material.dart';
import 'package:remote_zfs_unlock/screens/widgets/futuristic_outlined_button.dart';

class FuturisticCancelButton extends StatelessWidget {
  const FuturisticCancelButton({
    required this.onPressed,
    this.accentColor,
    super.key,
  });

  final VoidCallback? onPressed;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return FuturisticOutlinedButton(
      onPressed: onPressed,
      icon: Icons.close_rounded,
      label: 'Cancel',
      toneDownGlow: true,
      accentColor: accentColor ?? Theme.of(context).colorScheme.error,
    );
  }
}
