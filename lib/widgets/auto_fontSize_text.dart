import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class AutoFontSizeText extends StatefulWidget {
  String text;
  double width; //如果作为 child ,父层级的宽度已知，可不传
  TextStyle style;

  double minfontSize;
  TextAlign textAlign;

  AutoFontSizeText({
    @required this.text,
    @required this.width,
    @required this.style,
    this.minfontSize,
    this.textAlign,
  });

  @override
  State<StatefulWidget> createState() {
    return AutoTextState();
  }
}

class AutoTextState extends State<AutoFontSizeText> {
  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      widget.text,
      style: widget.style,
      maxLines: 1,
      textAlign: widget.textAlign ?? TextAlign.center,
      minFontSize: widget.minfontSize ?? 10,
    );
  }
}
