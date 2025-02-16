import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ReceiveBehalfComplaintDialog extends StatelessWidget {
  const ReceiveBehalfComplaintDialog(
      {Key? key, required this.controller, required this.onConfirm})
      : super(key: key);
  final TextEditingController controller;
  final Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: VStack(
        [
          FormBuilderTextField(
            onChanged: (value) async {},
            name: "Complaint".tr(),
            decoration: InputDecoration(
              enabledBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
              border:
                  OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
            ).copyWith(labelText: "Write your complaint".tr()),
            textInputAction: TextInputAction.next,
            controller: controller,
          ),
          UiSpacer.verticalSpace(),
          CustomButton(
            title: "Confirm".tr(),
            onPressed: onConfirm,
          ).py12(),
          Visibility(
            visible: !Platform.isIOS,
            child: CustomButton(
              title: "Cancel".tr(),
              color: Colors.grey[400],
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ).p20().wFull(context).scrollVertical(), //.hTwoThird(context),
    );
  }
}
