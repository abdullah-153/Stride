import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/size_config.dart';

class CustomKeyboard extends StatelessWidget {
  final Function(String) onDigitTap;
  final VoidCallback onBackspaceTap;
  final bool isDarkMode;

  const CustomKeyboard({
    super.key,
    required this.onDigitTap,
    required this.onBackspaceTap,
    this.isDarkMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.w(24),
        vertical: SizeConfig.h(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          SizedBox(height: SizeConfig.h(16)),
          _buildRow(['4', '5', '6']),
          SizedBox(height: SizeConfig.h(16)),
          _buildRow(['7', '8', '9']),
          SizedBox(height: SizeConfig.h(16)),
          _buildRow(['', '0', 'delete']),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> values) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: values
          .map((val) => hasValue(val) ? _buildKey(val) : _buildSpacer())
          .toList(),
    );
  }

  bool hasValue(String val) => val.isNotEmpty;

  Widget _buildSpacer() =>
      SizedBox(width: SizeConfig.w(80), height: SizeConfig.w(70));

  Widget _buildKey(String value) {
    final bool isDelete = value == 'delete';
    final Color textColor = Colors.black87;

    return Container(
      width: SizeConfig.w(80),
      height: SizeConfig.w(70),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            HapticFeedback.lightImpact();
            if (isDelete) {
              onBackspaceTap();
            } else {
              onDigitTap(value);
            }
          },
          child: Center(
            child: isDelete
                ? Icon(
                    Icons.backspace_outlined,
                    color: textColor.withOpacity(0.7),
                    size: SizeConfig.sp(24),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: SizeConfig.sp(28),
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
