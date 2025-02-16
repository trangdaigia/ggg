import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';

class BottomAppBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const BottomAppBarItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColor.primaryColor, size: 25),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
