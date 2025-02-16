import 'package:flutter/material.dart';

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({super.key, this.twoWay, required this.onChanged});
  final bool? twoWay;
  final Function onChanged;
  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool? _isChecked;
  @override
  void initState() {
    super.initState();
    _isChecked = widget.twoWay??false;
  }

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: _isChecked,
      onChanged: (value){
        widget.onChanged();
        setState((){
          _isChecked = value;
        });
      },
    );
  }
}