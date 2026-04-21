import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.keyboardType,
    this.minLines = 1,
    this.maxLines = 1,
    this.onSubmitted,
    this.obscureText = false,
    this.suffix,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final int minLines;
  final int maxLines;
  final void Function(String)? onSubmitted;
  final bool obscureText;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      minLines: minLines,
      maxLines: maxLines,
      obscureText: obscureText,
      onSubmitted: onSubmitted,
      textInputAction:
          maxLines == 1 ? TextInputAction.done : TextInputAction.newline,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        suffixIcon: suffix,
      ),
    );
  }
}
