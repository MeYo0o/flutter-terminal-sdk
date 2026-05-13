// dart
import 'package:flutter/material.dart';

class ScrollableSizedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final double? height;
  final double? width;
  final EdgeInsetsGeometry padding;
  final TextAlign textAlign;
  final bool selectable;
  final TextStyle? style;

  const ScrollableSizedText({
    super.key,
    required this.text,
    this.fontSize = 14,
    this.height,
    this.width,
    this.padding = const EdgeInsets.all(8),
    this.textAlign = TextAlign.start,
    this.selectable = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final textWidget = selectable
        ? SelectableText(
      text,
      textAlign: textAlign,
      style: style ?? TextStyle(fontSize: fontSize),
    )
        : Text(
      text,
      textAlign: textAlign,
      style: style ?? TextStyle(fontSize: fontSize),
    );

    return Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(6),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: textWidget,
      ),
    );
  }
}

// Usage example in a build method:
// ScrollableSizedText(
//   text: longStringVariable,
//   fontSize: 18,
//   height: 200,             // fixed height -> enables scrolling when content overflows
//   width: double.infinity,  // optional
//   selectable: true,        // optional
// );
