import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/services/validator.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/views/pages/parcel/widgets/parcel_form_input.dart';
import 'package:sod_user/widgets/bottomsheets/contact_permission.bottomsheet.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

class PackageStopRecipientView extends StatefulWidget {
  const PackageStopRecipientView(
    this.stop,
    this.recipientNameTEC,
    this.recipientPhoneTEC,
    this.noteTEC, {
    Key? key,
    this.isOpen = false,
    this.viewKey,
    this.index = 1,
  }) : super(key: key);

  final DeliveryAddress stop;
  final TextEditingController recipientNameTEC;
  final TextEditingController recipientPhoneTEC;
  final TextEditingController noteTEC;
  final bool isOpen;
  final Key? viewKey;
  final int index;

  @override
  _PackageStopRecipientViewState createState() =>
      _PackageStopRecipientViewState();
}

class _PackageStopRecipientViewState extends State<PackageStopRecipientView> {
  //
  bool isOpen = true;

  @override
  void initState() {
    super.initState();
    isOpen = widget.isOpen;
  }

  //
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        //
        HStack(
          [
            "${widget.index}"
                .text
                .color(Utils.textColorByTheme())
                .make()
                .p12()
                .box
                .color(AppColor.primaryColor)
                .roundedFull
                .make(),
            UiSpacer.hSpace(10),
            VStack(
              [
                "Contact Info".tr().text.xl.semiBold.make(),
                "(${widget.stop.name})"
                    .text
                    .base
                    .medium
                    .maxLines(2)
                    .ellipsis
                    .make(),
              ],
            ).expand(),
            UiSpacer.hSpace(10),
            Icon(
              isOpen ? FlutterIcons.caret_down_faw : FlutterIcons.caret_up_faw,
              color: AppColor.primaryColor,
            ),
          ],
          crossAlignment: CrossAxisAlignment.start,
        ).onInkTap(() {
          //
          setState(() {
            isOpen = !isOpen;
          });
        }),

        //
        Visibility(
            key: widget.viewKey,
            visible: isOpen,
            child: VStack(
              [
                UiSpacer.verticalSpace(),
                //pick contact btn
                CustomButton(
                  title: "Pick from Phonebook".tr(),
                  onPressed: _openContactPicker,
                ),
                UiSpacer.verticalSpace(),
                //name
                ParcelFormInput(
                  isReadOnly: false,
                  iconData: FlutterIcons.user_fea,
                  iconColor: AppColor.primaryColor,
                  labelText: "Name".tr().toUpperCase(),
                  hintText: "Contact Name".tr(),
                  tec: widget.recipientNameTEC,
                  formValidator: (value) => FormValidator.validateCustom(
                    value,
                    name: "Name".tr(),
                  ),
                ),
                UiSpacer.formVerticalSpace(),
                //phone
                ParcelFormInput(
                  isReadOnly: false,
                  iconData: FlutterIcons.phone_fea,
                  iconColor: AppColor.primaryColor,
                  labelText: "phone".tr().toUpperCase(),
                  hintText: "Contact Phone number".tr(),
                  keyboardType: TextInputType.phone,
                  tec: widget.recipientPhoneTEC,
                  formValidator: (value) => FormValidator.validatePhone(
                    value,
                    name: "phone".tr().allWordsCapitilize(),
                  ),
                ),
                UiSpacer.formVerticalSpace(),
                //note
                ParcelFormInput(
                  isReadOnly: false,
                  iconData: FlutterIcons.note_oct,
                  iconColor: AppColor.primaryColor,
                  labelText: "Note".tr().toUpperCase(),
                  hintText: "Further instruction".tr(),
                  tec: widget.noteTEC,
                ),
              ],
            )),
      ],
    ).p12().box.p12.py4.border(color: AppColor.primaryColor).roundedSM.make();
  }

  _openContactPicker() async {
    //
    bool granted = true;
    if (!(await FlutterContactPicker.hasPermission())) {
      granted = false;
      //show the contact dialog before showing the grant permission
      final result = await showDialog(
        context: context,
        builder: (ctx) => ContactPermissionDialog(),
      );
      //
      if (result == null || !(result as bool)) {
        return;
      }
      //request for permission now
      granted = await FlutterContactPicker.requestPermission();
    }

    if (granted) {
      try {
        final PhoneContact contact =
            await FlutterContactPicker.pickPhoneContact();

        setState(() {
          widget.recipientNameTEC.text = contact.fullName ?? "";
          widget.recipientPhoneTEC.text =
              contact.phoneNumber?.number?.removeAllWhiteSpace() ?? "";
        });
      } catch (e) {
        print(e);
      }
      //
    } else {
      Fluttertoast.showToast(
        msg: "Permission Denied".tr(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }
}
