// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ReceiveBehalfUserDetailsView extends StatelessWidget {
  final String name;
  final String phone;
  Color? color = Colors.black;
  ReceiveBehalfUserDetailsView({
    Key? key,
    required this.name,
    required this.phone,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Opacity(
                  opacity: 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Opacity(
                          opacity: 0.6,
                          child: Text(
                            "Full name".tr(),
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if (name.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              name,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Opacity(
                  opacity: 0.9,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        child: Opacity(
                          opacity: 0.6,
                          child: Text(
                            'Phone number'.tr(),
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      if (phone.isNotEmpty)
                        Row(
                          children: [
                            Text(
                              phone,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
