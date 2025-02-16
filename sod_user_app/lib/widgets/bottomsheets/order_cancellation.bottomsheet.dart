import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/view_models/order_cancellation.view_model.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderCancellationBottomSheet extends StatefulWidget {
  OrderCancellationBottomSheet({
    required this.onSubmit,
    required this.order,
    Key? key,
  }) : super(key: key);

  final Function(String) onSubmit;
  final Order order;

  @override
  _OrderCancellationBottomSheetState createState() =>
      _OrderCancellationBottomSheetState();
}

class _OrderCancellationBottomSheetState
    extends State<OrderCancellationBottomSheet> {
  String _selectedReason = "";
  TextEditingController reasonTEC = TextEditingController();
  bool checkReason = false;
  int _selectedValue = 0;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<OrderCancellationViewModel>.reactive(
      viewModelBuilder: () => OrderCancellationViewModel(context, widget.order),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, vm, child) {
        return VStack(
          [
            "Order Cancellation".tr().text.semiBold.xl.make(),
            "Please state why you want to cancel order".tr().text.make(),

            // default reasons
            VStack(
              [
                if (vm.isBusy || vm.busy(vm.reasons))
                  BusyIndicator().p(12).centered()
                else if (vm.reasons.isEmpty)
                  Column(
                    children: <Widget>[
                      RadioListTile<int>(
                        title: Text('Đổi ý không muốn đặt nữa.'),
                        value: 1,
                        groupValue: _selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                        },
                      ),
                      RadioListTile<int>(
                        title: Text('Lý do khác'),
                        value: 2,
                        groupValue: _selectedValue,
                        onChanged: (int? value) {
                          setState(() {
                            _selectedValue = value!;
                          });
                        },
                      ),
                    ],
                  )
                else
                  RadioGroup<String>.builder(
                    spacebetween: Vx.dp48,
                    groupValue: _selectedReason,
                    onChanged: (value) => setState(() {
                      _selectedReason = value ?? "";
                    }),
                    items: vm.reasons,
                    itemBuilder: (item) => RadioButtonBuilder(
                      item.tr().capitalized,
                    ),
                  ).py12(),
//custom
                /* _selectedReason == "custom"
                      ? CustomTextFormField(
                          labelText: "Reason".tr(),
                          textEditingController: reasonTEC,
                        ).py12()
                      : UiSpacer.emptySpace(),*/
                CustomTextFormField(
                  labelText: "Reason".tr(),
                  textEditingController: reasonTEC,
                  suffixIcon: checkReason
                      ? Icon(
                          AntDesign.warning,
                          color: Colors.red,
                          size: 16,
                        )
                      : null,
                ).py12()
              ],
            ).py(10),

            CustomButton(
              title: "Submit".tr(),
              onPressed: () {
                if (reasonTEC.text.isEmpty) {
                  setState(() {
                    checkReason = true;
                  });

                  // Create an OverlayEntry with a red notification
                  final overlayEntry = OverlayEntry(
                    builder: (context) => Positioned(
                      top: MediaQuery.of(context).padding.top + 1,
                      left: MediaQuery.of(context).padding.left + 5,
                      right: MediaQuery.of(context).padding.right + 5,
                      child: Material(
                        color: Colors.transparent,
                        // Make the notification material transparent for better layering
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child:
                                "Please enter the reason for canceling the order"
                                    .tr()
                                    .text
                                    .textStyle(
                                      TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    )
                                    .make(),
                          ),
                        ),
                      ),
                    ),
                  );

                  // Show the notification by inserting the OverlayEntry
                  Overlay.of(context).insert(overlayEntry);

                  // Remove the notification after 3 seconds
                  Future.delayed(const Duration(seconds: 3), () {
                    overlayEntry.remove();
                  });
                } else {
                  _selectedReason = reasonTEC.text;
                  widget.onSubmit(_selectedReason);
                }
              },
            ),
          ],
        ).p20().scrollVertical().pOnly(bottom: context.mq.viewInsets.bottom).h(
              context.percentHeight * 80, //80% of screen height
            );
      },
    );
  }
}
