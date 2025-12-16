import 'package:flutter/material.dart';
import 'package:fitness_tracker_frontend/utils/size_config.dart'; //

class PasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final double vpad;
  final double fSize;

  const PasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.vpad,
    required this.fSize,
  });

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);

    return TextField(
      obscureText: _obscure,
      controller: widget.controller,
      style: TextStyle(
        fontSize: SizeConfig.sp(widget.fSize),
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        floatingLabelStyle: const TextStyle(color: Colors.black),
        labelText: widget.label,
        labelStyle: TextStyle(fontSize: SizeConfig.sp(widget.fSize)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SizeConfig.w(10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(width: SizeConfig.w(3)),
          borderRadius: BorderRadius.circular(SizeConfig.w(15)),
        ),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: SizeConfig.h(15),
          horizontal: SizeConfig.w(15),
        ),
      ),
    );
  }
}
