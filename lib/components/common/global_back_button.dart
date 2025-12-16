import 'package:flutter/material.dart';

class GlobalBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isDark;

  const GlobalBackButton({
    super.key,
    this.onPressed,
    this.isDark =
        false, // You might want to default to detecting theme logic if context available, but passed prop is fine
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: isDark
            ? Colors.white.withOpacity(0.1)
            : Colors.black.withOpacity(0.05),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: textColor,
          ),
          onPressed: onPressed ?? () => Navigator.of(context).pop(),
          splashRadius: 20,
        ),
      ),
    );
  }
}
