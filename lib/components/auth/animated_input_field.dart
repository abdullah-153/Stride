import 'package:flutter/material.dart';
import '../../utils/size_config.dart';

class AnimatedInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final int delayMs; 

  const AnimatedInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.delayMs = 0,
  });

  @override
  State<AnimatedInputField> createState() => _AnimatedInputFieldState();
}

class _AnimatedInputFieldState extends State<AnimatedInputField> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero) // Slide from right
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start immediately
    if (widget.delayMs > 0) {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _controller.forward();
      });
    } else {
        _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(vertical: SizeConfig.h(8)),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5), // Semi-transparent white
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.6)), // Subtle border
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            style: TextStyle(
              fontSize: SizeConfig.sp(16),
              fontWeight: FontWeight.w500,
              color: Colors.black87, // Restore black text
            ),
            decoration: InputDecoration(
              hintText: widget.label,
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(widget.icon, color: Colors.grey[600], size: 22),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: Colors.grey[600],
                        size: 22,
                      ),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: SizeConfig.w(20),
                vertical: SizeConfig.h(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
