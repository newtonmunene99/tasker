import 'package:flutter/material.dart';

typedef OnChangeCallback = void Function(bool checked);

class CircularCheckBox extends StatefulWidget {
  final Color color;
  final Color uncheckedColor;
  final bool checked;
  final OnChangeCallback onChange;
  final double size;

  CircularCheckBox({
    this.color,
    this.uncheckedColor,
    @required this.checked,
    @required this.onChange,
    this.size,
  });
  @override
  _CircularCheckBoxState createState() => _CircularCheckBoxState();
}

class _CircularCheckBoxState extends State<CircularCheckBox> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.onChange(!widget.checked);
      },
      child: Container(
        width: widget.size ?? 30,
        height: widget.size ?? 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            width: 1.0,
            color: widget.uncheckedColor ?? Theme.of(context).primaryColor,
          ),
          color: widget.checked
              ? widget.color ?? Theme.of(context).primaryColor
              : Colors.white,
        ),
        child: widget.checked
            ? Center(
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
