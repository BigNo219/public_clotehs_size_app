import 'package:flutter/material.dart';

class CustomDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final double indent;
  final double endIndent;
  final Color color;

  const CustomDivider({
    super.key,
    this.height = 16.0,
    this.thickness = 2.0,
    this.indent = 8.0,
    this.endIndent = 8.0,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      thickness: thickness,
      indent: indent,
      endIndent: endIndent,
      color: color,
    );
  }
}