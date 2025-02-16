import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
class CustomToggleButtons extends StatefulWidget {
  const CustomToggleButtons(
      {super.key,
      required this.buttonTitles,
      this.twoWay,
      this.buttonTexts = const [],
      required this.onTap});
  final List<String> buttonTitles;
  final List<String> buttonTexts;
  final bool? twoWay;
  final Function(int) onTap;
  @override
  State<CustomToggleButtons> createState() => _CustomToggleButtonsState();
}

class _CustomToggleButtonsState extends State<CustomToggleButtons> {
  final List<bool> _isSelected = <bool>[true, false];
  @override
  Widget build(BuildContext context) {
    return Container(child: LayoutBuilder(builder: (context, constraints) {
      return ToggleButtons(
        isSelected: _isSelected,
        onPressed: (index) {
          
          widget.onTap(index);
          // only one button is selected at the time
          setState(() {
            if (_isSelected[index] != true) {
              _isSelected[1 - index] = false;
              _isSelected[index] = true;
            }
          });
        },
        children: [
          for (int index = 0; index < widget.buttonTitles.length; index++)
            Expanded(
              child: Container(
                
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.buttonTitles[index],
                              textAlign: TextAlign.start,
                              style: TextStyle(fontWeight: FontWeight.bold)
                          ),
                          Text(
                            widget.buttonTexts[index],
                            textAlign: TextAlign.left,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                    Icon(_isSelected[index]?Icons.check_circle_outline:Icons.circle_outlined),
                  ],

                ),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: _isSelected[index] ? AppColor.primaryColor: Colors.grey,
                        width: 1.0),
                    borderRadius: BorderRadius.circular(10),
                    color: _isSelected[index]?AppColor.primaryColor.withOpacity(0.1):null
                    ),
                padding: EdgeInsets.all(10),
                margin: index != widget.buttonTitles.length - 1
                    ? EdgeInsets.only(right: 10)
                    : null,
              
              ),
            )
        ],
        // the fill color for selected button
        fillColor: Colors.white,
        // color: color for text and icon if the button is enable and not selected
        color: Theme.of(context).textTheme.bodyLarge!.color,
        renderBorder: false,
        constraints: BoxConstraints.expand(width: constraints.maxWidth / 2),
      );
    }));
  }
}
