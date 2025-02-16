import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/extensions/string.dart';
import 'package:sod_user/driver_lib/models/box.dart';
import 'package:sod_user/driver_lib/services/validator.service.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/utils/utils.dart';
import 'package:sod_user/driver_lib/view_models/receive_behalf.vm.dart';
import 'package:sod_user/driver_lib/views/pages/receive_behalf/widgets/receive_behaf_data_details.view.dart';
import 'package:sod_user/driver_lib/views/pages/receive_behalf/widgets/receive_behalf_user_details.view.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:sod_user/driver_lib/widgets/custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ConfirmReceiveBehalfPage extends StatefulWidget {
  const ConfirmReceiveBehalfPage({super.key, required this.vm});

  final ReceiveBehalfViewModel vm;

  @override
  State<ConfirmReceiveBehalfPage> createState() =>
      _ConfirmReceiveBehalfPageState();
}

class _ConfirmReceiveBehalfPageState extends State<ConfirmReceiveBehalfPage>
// with WidgetsBindingObserver
{
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final amountTEC = TextEditingController();
  // late ReceiveBehalfViewModel viewmodel;

  // @override
  // void initState(){
  //   super.initState();
  //   viewmodel = widget.vm;
  //   WidgetsBinding.instance.addPostFrameCallback((_){
  //     viewmodel.initialise();
  //   });
  //   WidgetsBinding.instance.addObserver(this);
  // }

  // @override
  // void dispose() {
  //   viewmodel.dispose();
  //   super.dispose();
  //   WidgetsBinding.instance.removeObserver(this);
  // }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     print("====did change app life cycle state ====");
  //     viewmodel.initialise();
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var checkBoxAddress = false;
    return ViewModelBuilder<ReceiveBehalfViewModel>.reactive(
        viewModelBuilder: () => widget.vm,
        onViewModelReady: (vm) => vm.initialise(),
        disposeViewModel: false,
        builder: (context, vm, child) {
          return BasePage(
            showAppBar: true,
            showLeadingAction: true,
            title: "Confirm receive behalf".tr(),
            body: VStack(
              crossAlignment: CrossAxisAlignment.start,
              axisSize: MainAxisSize.min,
              [
                "Confirm information"
                    .tr()
                    .text
                    .xl
                    .color(Colors.black)
                    .bold
                    .make()
                    .py(10),
                UiSpacer.divider(),
                VStack(
                  [
                    HStack(
                      [
                        Expanded(
                          child: InkWell(
                            child: ReceiveBehalfUserDetailsView(
                              name: '${widget.vm.deliveryUser!.name}',
                              phone: '${widget.vm.deliveryUser!.phone!}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ).py(8),
                UiSpacer.vSpace(8),
                'Box'.tr().text.xl.bold.make(),
                UiSpacer.vSpace(8),
                Container(
                  padding: EdgeInsets.only(bottom: 10.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: checkBoxAddress ? Colors.red : Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonFormField<Box>(
                    isExpanded: true,
                    selectedItemBuilder: (context) {
                      return widget.vm.boxes == null
                          ? []
                          : widget.vm.boxes!.map((value) {
                              return DropdownMenuItem<Box>(
                                value: value,
                                child: /*VStack(
                            crossAlignment: CrossAxisAlignment.start,
                            [
                              '${value.name} (${value.building!.name})'
                                  .text
                                  .semiBold
                                  .make(),
                              '${value.building!.address ?? ''}'
                                  .text
                                  .overflow(TextOverflow.ellipsis)
                                  .make(),
                            ]*/

                                    Wrap(
                                  spacing: 10, // Khoảng cách giữa các con
                                  children: [
                                    Text(
                                      '${value.name} (${value.building!.name})',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      '${value.building!.address ?? ''}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            }).toList();
                    },
                    padding: EdgeInsets.all(15),
                    borderRadius: BorderRadius.circular(15),
                    decoration: InputDecoration.collapsed(hintText: ""),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                    value: widget.vm.selectedBox,
                    onChanged: (value) {
                      widget.vm.selectedBox = value;
                    },
                    items: widget.vm.boxes == null
                        ? []
                        : widget.vm.boxes!.map((value) {
                            return DropdownMenuItem<Box>(
                              value: value,
                              child: /*VStack(
                          crossAlignment: CrossAxisAlignment.start,
                          [
                            '${value.name} (${value.building!.name})'
                                .text
                                .semiBold
                                .make(),
                            '${value.building!.address ?? ''}'
                                .text
                                .overflow(TextOverflow.visible)
                                .make(),
                            UiSpacer.divider(height: 5),
                          ],
                        ),*/
                                  Wrap(
                                spacing: 10, // Khoảng cách giữa các con
                                children: [
                                  Text(
                                    '${value.name} (${value.building!.name})',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${value.building!.address ?? ''}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  UiSpacer.divider(height: 5),
                                ],
                              ),
                            );
                          }).toList(),
                  ),
                ),
                Visibility(
                  visible: vm.hasErrorForKey('box') && (vm.selectedBox == null),
                  child: vm
                      .error('box')
                      .toString()
                      .text
                      .fontWeight(FontWeight.w600)
                      .red600
                      .make()
                      .py12(),
                ),
                UiSpacer.vSpace(8),
                HStack(['Package images'.tr().text.xl.bold.make()]),
                UiSpacer.vSpace(12),
                CarouselSlider(
                  items: widget.vm.images
                      .map(
                        (element) => ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(element,
                              fit: BoxFit.cover, width: double.infinity),
                        ),
                      )
                      .toList(),
                  options: CarouselOptions(viewportFraction: 1, autoPlay: true),
                ),
                UiSpacer.vSpace(12),
                Transform.scale(
                  scale: 1.1,
                  child: CheckboxListTile(
                    checkboxShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(2)),
                    checkColor: Colors.white,
                    activeColor: AppColor.accentColor,
                    title: '${"Paid order".tr()} (${"Paid order explain".tr()})'
                        .text
                        .make(),
                    value: widget.vm.paidOrderCheck,
                    onChanged: (value) {
                      setState(() {
                        widget.vm.paidOrderCheck = value!;
                      });
                      if (widget.vm.paidOrderCheck) {
                        widget.vm.receiveBehalfOrderTotal = 0;
                      } else {
                        widget.vm.receiveBehalfOrderTotal =
                            widget.vm.receiveBehalfOrderValue;
                      }
                      // widget.vm.notifyListeners();
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Visibility(
                  visible: !widget.vm.paidOrderCheck ? true : false,
                  child: Form(
                    key: formKey,
                    child: CustomTextFormField(
                      labelText: "Price".tr(),
                      textEditingController: amountTEC,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      suffixIcon: HStack(
                        axisSize: MainAxisSize.min,
                        alignment: MainAxisAlignment.center,
                        crossAlignment: CrossAxisAlignment.center,
                        [AppStrings.currencySymbol.text.bold.size(16).make()],
                      ),
                      validator: (value) => FormValidator.validateEmpty(
                        value,
                        errorTitle: "required".tr(),
                      ),
                      onChanged: (value) {
                        if (value.isEmpty) {
                          widget.vm.receiveBehalfOrderValue = 0;
                        } else {
                          int selectionIndexFromRight =
                              value.length - amountTEC.selection.end;
                          value = formatTextFieldInputNumber(
                              cleanTextFieldInputNumber(value));
                          amountTEC.value = TextEditingValue(
                              text: value,
                              selection: TextSelection.collapsed(
                                  offset:
                                      value.length - selectionIndexFromRight));
                          widget.vm.receiveBehalfOrderValue = int.parse(
                              cleanTextFieldInputNumber(amountTEC.text));
                        }
                        widget.vm.receiveBehalfOrderTotal =
                            widget.vm.receiveBehalfOrderValue;
                      },
                    ),
                  ),
                ),
                UiSpacer.vSpace(10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      padding: EdgeInsets.all(15),
                      borderRadius: BorderRadius.circular(15),
                      icon:
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                      decoration: InputDecoration.collapsed(hintText: ""),
                      value: widget.vm.receiveBehalfFee.toString(),
                      onChanged: (value) {
                        setState(() {
                          widget.vm.receiveBehalfFee = int.parse(value!);
                        });
                      },
                      items: ['0', '5000', '10000', '15000', '20000']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: HStack(
                            [
                              "${"Receive behalf fee".tr()}: ".text.make(),
                              Utils.formatCurrencyVND(double.parse(value))
                                  .text
                                  .make(),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Visibility(
                  visible: widget.vm.hasErrorForKey('confirm'),
                  child: widget.vm
                      .error('confirm')
                      .toString()
                      .text
                      .fontWeight(FontWeight.w600)
                      .red600
                      .make()
                      .py12(),
                ),
                UiSpacer.vSpace(10),
                HStack(
                  [
                    Expanded(
                      child: ReceiveBehalfDataDetails(
                        title: Utils.formatCurrencyVND(double.parse(
                            widget.vm.receiveBehalfOrderTotal.toString())),
                        value: 'Order total'.tr(),
                      ),
                    ),
                    UiSpacer.hSpace(10),
                    Expanded(
                      child: ReceiveBehalfDataDetails(
                        title: Utils.formatCurrencyVND(double.parse(
                            (widget.vm.receiveBehalfFee +
                                    widget.vm.receiveBehalfOrderTotal *
                                        widget.vm.serviceFeePercent /
                                        100)
                                .toString())),
                        value: widget.vm.paidOrderCheck
                            ? "Receive behalf fee".tr()
                            : "Service fee".tr(),
                      ),
                    ),
                    UiSpacer.hSpace(10),
                    Expanded(
                      child: ReceiveBehalfDataDetails(
                        title: Utils.formatCurrencyVND(
                          double.parse(
                            (widget.vm.receiveBehalfOrderTotal +
                                    (widget.vm.paidOrderCheck
                                        ? widget.vm.receiveBehalfFee
                                        : widget.vm.receiveBehalfFee +
                                            widget.vm.receiveBehalfOrderTotal *
                                                widget.vm.serviceFeePercent /
                                                100))
                                .toString(),
                          ),
                        ),
                        value: 'Receiver payment'.tr(),
                        color: AppColor.primaryColor,
                      ),
                    ),
                  ],
                ),
                UiSpacer.vSpace(20),
                widget.vm.paidOrderCheck
                    ? UiSpacer.emptySpace()
                    : Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: AppColor.primaryColor),
                          UiSpacer.hSpace(10),
                          "${"Service fee".tr()} = ${"Receive behalf fee".tr()} + ${"Payment fee".tr()} (${widget.vm.serviceFeePercent}%)"
                              .text
                              .xs
                              .make(),
                        ],
                      ),
                UiSpacer.vSpace(20),
                HStack(
                  [
                    CustomButton(
                      icon: Icons.arrow_back_ios,
                      iconColor: Colors.black,
                      title: "Back".tr(),
                      onPressed: () => Navigator.pop(context),
                    ),
                    UiSpacer.hSpace(10),
                    Expanded(
                      child: CustomButton(
                        title: "Create order".tr(),
                        color: AppColor.primaryColor,
                        loading: widget.vm.isBusy,
                        onPressed: () async {
                          // if (!widget.vm.paidOrderCheck && !formKey.currentState!.validate()) {
                          // return;
                          // }

                          if (widget.vm.selectedBox == null) {
                            print("BOX IS EMPTY!!!");
                            widget.vm.setErrorForObject(
                                "box", "Please enter your address".tr());
                            checkBoxAddress = true;
                            return;
                          }
                          // if (widget.vm.paidOrderCheck == false &&
                          //     widget.vm.receiveBehalfOrderTotal != 0 &&
                          //     widget.vm.receiveBehalfFee != 0) {
                          //   widget.vm.placeOrder();
                          //   print("Created order successfully!!!");
                          // } else if (widget.vm.paidOrderCheck) {
                          //   if (widget.vm.receiveBehalfFee == 0) {
                          //     widget.vm.setErrorForObject('confirm',
                          //         "Please select receive behalf fee".tr());
                          //   } else {
                          //     widget.vm.placeOrder();
                          //     print("Created order successfully!!!");
                          //   }
                          // } else {
                          //   if (widget.vm.receiveBehalfOrderTotal == 0) {
                          //     widget.vm.setError(
                          //         "please_enter_receive_behalf_order_total".tr);
                          //   } else if (widget.vm.receiveBehalfFee == 0) {
                          //     widget.vm.setErrorForObject('confirm',
                          //         "Please select receive behalf fee".tr());
                          //   }
                          // }
                          widget.vm.placeOrder();
                        },
                      ).h(50),
                    )
                  ],
                ),
              ],
            ).scrollVertical(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10)),
          );
        });
  }
}
