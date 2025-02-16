// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';

class ReceiveBehalfDataDetails extends StatelessWidget {
  final String title;
  final String value;
  Color? color = Colors.black;
  ReceiveBehalfDataDetails({
    Key? key,
    required this.title,
    required this.value,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: 0.9,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15, color: color, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 6),
          Opacity(
            opacity: 0.6,
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
