import 'package:flutter/material.dart';

class DigitBox extends StatelessWidget {
  final String digit;
  final bool isSelected;

  const DigitBox({super.key, required this.digit, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 250,
      height: 250,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected
            ? const Color.fromARGB(255, 255, 129, 18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Colors.transparent,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ]
            : [],

        border: Border.all(
          color: isSelected
              ? const Color.fromARGB(255, 235, 170, 113)
              : Colors.transparent,
          width: 10,
        ),
      ),
      child: Text(
        digit,
        style: TextStyle(
          fontSize: isSelected ? 120 : 70,
          fontWeight: FontWeight.bold,
          color: isSelected
              ? Colors.white
              : const Color.fromARGB(255, 159, 159, 159),
        ),
      ),
    );
  }
}
