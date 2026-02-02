import 'package:flutter/material.dart';
import '../../utils/size_config.dart';
import 'custom_keyboard.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

class PremiumOTPSection extends StatefulWidget {
  final String email;
  final Future<bool> Function(String) onVerifyCode;
  final VoidCallback onVerified;
  final VoidCallback onResend;

  const PremiumOTPSection({
    super.key,
    required this.email,
    required this.onVerified,
    required this.onVerifyCode,
    required this.onResend,
    this.isLoading = false,
  });

  final bool isLoading;

  @override
  State<PremiumOTPSection> createState() => _PremiumOTPSectionState();
}

class _PremiumOTPSectionState extends State<PremiumOTPSection>
    with TickerProviderStateMixin {
  final int _otpLength = 4;
  String _code = "";
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _shakeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _shakeController.reset();
        setState(() {
          _isError = false;
          _code = "";
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _onDigitTap(String digit) async {
    if (_code.length < _otpLength) {
      setState(() {
        _code += digit;
      });

      if (_code.length == _otpLength) {
        final isValid = await widget.onVerifyCode(_code);

        if (isValid) {
          widget.onVerified();
        } else {
          _triggerError();
        }
      }
    }
  }

  void _triggerError() {
    HapticFeedback.heavyImpact();
    setState(() => _isError = true);
    _shakeController.forward();
  }

  void _onBackspaceTap() {
    if (_code.isNotEmpty) {
      setState(() => _code = _code.substring(0, _code.length - 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Colors.black;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            double offset = math.sin(_shakeAnimation.value * math.pi * 4) * 10;
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const Spacer(flex: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(SizeConfig.w(20)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.isLoading
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: widget.isLoading
                    ? SizedBox(
                        width: SizeConfig.w(40),
                        height: SizeConfig.w(40),
                        child: const CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 3,
                        ),
                      )
                    : Icon(
                        Icons.lock_person_outlined,
                        size: SizeConfig.w(40),
                        color: _isError ? Colors.red : const Color(0xFF000000),
                      ),
              ),

              const Spacer(flex: 1),

              SizedBox(
                height: SizeConfig.w(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: List.generate(_otpLength, (index) {
                    final isActive = index < _code.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      margin: EdgeInsets.symmetric(
                        horizontal: SizeConfig.w(10),
                      ),
                      width: isActive ? SizeConfig.w(20) : SizeConfig.w(14),
                      height: isActive ? SizeConfig.w(20) : SizeConfig.w(14),
                      decoration: BoxDecoration(
                        color: _isError
                            ? Colors.red.withOpacity(0.8)
                            : (isActive ? Colors.black : Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isError
                              ? Colors.red
                              : (isActive ? Colors.black : Colors.transparent),
                          width: 2,
                        ),
                        boxShadow: isActive
                            ? [
                                BoxShadow(
                                  color: (_isError ? Colors.red : Colors.black)
                                      .withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : [],
                      ),
                    );
                  }),
                ),
              ),

              SizedBox(height: SizeConfig.h(12)),
              AnimatedOpacity(
                opacity: _isError ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  "Incorrect code. Please try again.",
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: SizeConfig.sp(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const Spacer(flex: 3),

              if (!widget.isLoading) ...[
                CustomKeyboard(
                  onDigitTap: _onDigitTap,
                  onBackspaceTap: _onBackspaceTap,
                  isDarkMode: false,
                ),

                TextButton(
                  onPressed: widget.onResend,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    "Resend Code",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: SizeConfig.sp(15),
                    ),
                  ),
                ),
              ] else ...[
                const Spacer(flex: 2),
                Text(
                  "Verifying Code...",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: SizeConfig.sp(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(flex: 3),
              ],
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
