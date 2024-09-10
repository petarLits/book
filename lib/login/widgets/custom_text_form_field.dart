import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField(
      {super.key,
      required this.isNonPasswordField,
      required this.labelText,
      required this.validator,
      required this.maxLength,
      required this.onChanged,
      this.maxLines = 1});

  final bool isNonPasswordField;
  final String labelText;
  final String? Function(String?)? validator;
  final int maxLength;
  final ValueChanged<String> onChanged;
  final int maxLines;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool obscureText = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLines: widget.maxLines,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onChanged: (value) {
        widget.onChanged(value);
      },
      maxLength: widget.maxLength,
      obscureText: widget.isNonPasswordField ? false : !obscureText,
      validator: widget.validator,
      decoration: InputDecoration(
          alignLabelWithHint: true,
          suffixIcon: IconButton(
            onPressed: () {
              toggleObscureText();
            },
            icon: widget.isNonPasswordField
                ? Icon(null)
                : !obscureText
                    ? Icon(Icons.visibility)
                    : Icon(Icons.visibility_off),
          ),
          border: OutlineInputBorder(),
          labelText: widget.labelText),
    );
  }

  void toggleObscureText() {
    obscureText = !obscureText;
    setState(() {});
  }
}
