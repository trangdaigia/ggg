import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/services/validator.service.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class WithdrawToBankBottomSheet extends StatefulWidget {
  WithdrawToBankBottomSheet({
    required this.onSubmit,
    required this.bankAccounts,
    Key? key,
  }) : super(key: key);

  final Function(String, String)
      onSubmit; // Thêm tài khoản bank vào hàm onSubmit
  final List<String> bankAccounts; // Danh sách số tài khoản ngân hàng

  @override
  _WithdrawToBankBottomSheetState createState() =>
      _WithdrawToBankBottomSheetState();
}

class _WithdrawToBankBottomSheetState extends State<WithdrawToBankBottomSheet> {
  final formKey = GlobalKey<FormState>();
  final _amountTEC = TextEditingController();
  String? _selectedBankAccount; // Biến để lưu tài khoản ngân hàng được chọn
  List<String> _bankAccounts = []; // Danh sách tài khoản ngân hàng

  @override
  void initState() {
    super.initState();
    _bankAccounts = widget.bankAccounts;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.mq.viewInsets.bottom),
      child: FractionallySizedBox(
        heightFactor:
            0.5, // Giảm chiều cao của BottomSheet, 0.5 là 50% chiều cao màn hình
        child: VStack(
          [
            //
            10.heightBox,
            //
            "Withdraw to Bank".tr().text.xl3.semiBold.make().pOnly(bottom: 10),
            "Select bank account".tr().text.make().pOnly(bottom: 10),

            // Row chứa Dropdown và nút thêm số tài khoản
            Row(
              children: [
                // Dropdown để chọn số tài khoản ngân hàng
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedBankAccount,
                    items: _bankAccounts.map((account) {
                      return DropdownMenuItem(
                        value: account,
                        child: Text(account),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBankAccount =
                            value; // Cập nhật tài khoản đã chọn
                      });
                    },
                    decoration: InputDecoration(
                      labelText: "Bank Account".tr(),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null
                        ? "Please select a bank account".tr()
                        : null,
                  ),
                ),
              ],
            ).py12(),

            "Enter amount to withdraw to bank"
                .tr()
                .text
                .make()
                .pOnly(bottom: 10),

            Form(
              key: formKey,
              child: CustomTextFormField(
                hintText: "Enter the amount".tr(),
                labelText: "Amount".tr(),
                textEditingController: _amountTEC,
                suffixIcon: HStack(
                  axisSize: MainAxisSize.min,
                  alignment: MainAxisAlignment.center,
                  crossAlignment: CrossAxisAlignment.center,
                  [AppStrings.currencySymbol.text.bold.size(16).make()],
                ),
                onChanged: (string) {
                  int selectionIndexFromRight =
                      string.length - _amountTEC.selection.end;
                  string = formatTextFieldInputNumber(
                      cleanTextFieldInputNumber(string));
                  _amountTEC.value = TextEditingValue(
                      text: string,
                      selection: TextSelection.collapsed(
                          offset: string.length - selectionIndexFromRight));
                },
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) => FormValidator.validateEmpty(
                  value,
                  errorTitle: "Amount".tr(),
                ),
              ),
            ).py12(),

            CustomButton(
              title: "WITHDRAW".tr(),
              onPressed: () {
                widget.onSubmit(
                  _amountTEC.text,
                  _selectedBankAccount ?? ""
                );
              },
            ),
            20.heightBox,
          ],
        )
            .p20()
            .scrollVertical()
            .box
            .color(context.theme.colorScheme.background)
            .topRounded()
            .make(),
      ),
    );
  }
}
