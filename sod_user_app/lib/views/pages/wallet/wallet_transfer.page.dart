import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_text_styles.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/trip.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/models/wallet.dart';
import 'package:sod_user/services/validator.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/wallet.vm.dart';
import 'package:sod_user/view_models/wallet_transfer.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import 'widgets/selected_wallet_user.dart';

class WalletTransferPage extends StatelessWidget {
  const WalletTransferPage(this.wallet, this.phone, this.deposit_price, this.trip, {Key? key})
      : super(key: key);
  //
  final Wallet wallet;
  final String? phone;
  final String? deposit_price;
  final Trip? trip;
  @override
  Widget build(BuildContext context) {
    TextEditingController phoneController = TextEditingController();
    return BasePage(
      title: "Wallet Transfer".tr(),
      showLeadingAction: true,
      showAppBar: true,
      body: ViewModelBuilder<WalletTransferViewModel>.reactive(
        viewModelBuilder: () => WalletTransferViewModel(context, wallet),
        onViewModelReady: (vm) async {
          vm.initiateWalletTransfer();
          if (phone != null) {
            List<User> searchResults = await vm.searchUserOwnerCar(phone!);
            vm.userSelected(searchResults.first);
          }
        },
        builder: (context, vm, child) {
          if (phone != null && deposit_price != null) {
            vm.amountTEC.text = deposit_price!;
            phoneController.text = phone!;
          }
          return Form(
            key: vm.formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: VStack(
              [
                //amount
                CustomTextFormField(
                  labelText: "Amount".tr(),
                  hintText: "Enter amount".tr(),
                  suffixIcon: HStack(
                    axisSize: MainAxisSize.min,
                    alignment: MainAxisAlignment.center,
                    crossAlignment: CrossAxisAlignment.center,
                    [AppStrings.currencySymbol.text.bold.size(16).make()],
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textEditingController: vm.amountTEC,
                  isReadOnly: phone != null ? true : false,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) => FormValidator.validateCustom(
                    cleanTextFieldInputNumber(value!),
                    name: "Amount".tr(),
                    rules: "required|lt:${vm.wallet?.balance}",
                  ),
                  onChanged: (string) {
                    int selectionIndexFromRight = string.length - vm.amountTEC.selection.end;
                    string = formatTextFieldInputNumber(cleanTextFieldInputNumber(string));
                    vm.amountTEC.value = TextEditingValue(
                        text: string,
                        selection: TextSelection.collapsed(
                            offset: string.length - selectionIndexFromRight));
                  },
                ),
                UiSpacer.formVerticalSpace(),
                //receiver email/phone
                "Receiver".tr().text.lg.semiBold.make(),
                UiSpacer.verticalSpace(space: 6),
                //Receiver row data
                Row(
                  children: [
                    //
                    TypeAheadField(
                      hideOnLoading: true,
                      hideSuggestionsOnKeyboardHide: false,
                      minCharsForSuggestions: 2,
                      debounceDuration: const Duration(seconds: 1),
                      textFieldConfiguration: TextFieldConfiguration(
                        enabled: phone != null ? false : true,
                        controller: phoneController,
                        style: AppTextStyle.h5TitleTextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge!.color,
                        ).copyWith(fontSize: 15),
                        autofocus: false,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColor.primaryColor,
                            ),
                          ),
                          hintText: "Email/Phone".tr(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColor.primaryColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColor.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      suggestionsCallback: vm.searchUsers,
                      itemBuilder: (context, User? suggestion) {
                        if (suggestion == null) {
                          return Divider();
                        }
                        //
                        return VStack(
                          [
                            VStack(
                              [
                                "${suggestion.name}".text.semiBold.lg.make(),
                                UiSpacer.vSpace(5),
                                "${suggestion.code ?? ''} - ${suggestion.phone.isNotBlank ? suggestion.phone.maskString(
                                        start: 3,
                                        end: 8,
                                      ) : ''}"
                                    .text
                                    .sm
                                    .make(),
                              ],
                            ).px12().py(3),
                            Divider(),
                          ],
                        );
                      },
                      onSuggestionSelected: vm.userSelected,
                    ).expand(),
                    UiSpacer.horizontalSpace(),
                    //scan qrcode
                    Icon(
                      FlutterIcons.qrcode_ant,
                      size: 32,
                      color: Utils.textColorByTheme(),
                    )
                        .p12()
                        .box
                        .roundedSM
                        .outerShadowSm
                        .color(AppColor.primaryColor)
                        .make()
                        .onInkTap(() {
                      if (phone == null) {
                        vm.scanWalletAddress();
                      }
                    }),
                  ],
                ),
                //selected user view
                if (vm.selectedUser != null) SelectedWalletUser(vm.selectedUser!),

                UiSpacer.formVerticalSpace(),
                //account password
                CustomTextFormField(
                  hintText: "Enter your password".tr(),
                  labelText: "Password".tr(),
                  textEditingController: vm.passwordTEC,
                  obscureText: true,
                  validator: FormValidator.validatePassword,
                ),
                UiSpacer.formVerticalSpace(),
                //send button
                CustomButton(
                    loading: phone != null ? vm.isBusy || vm.selectedUser == null : vm.isBusy,
                    title: "Transfer".tr(),
                    onPressed: () async {
                      if (trip != null) {
                        await vm.initiateWalletTransfer(trip);
                      } else {
                        await vm.initiateWalletTransfer();
                      }
                    }).wFull(context),
                UiSpacer.formVerticalSpace(),
              ],
            ).p20().scrollVertical(),
          );
        },
      ),
    );
  }
}
