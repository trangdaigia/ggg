import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/services/custom_form_builder_validator.service.dart';
import 'package:sod_user/services/validator.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/callbackme.vm.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:sod_user/widgets/custom_text_form_field.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class CallBackMePage extends StatefulWidget {
  const CallBackMePage(this.vendorType, this.isShippingOrder, {Key? key})
      : super(key: key);
  final VendorType vendorType;
  final bool isShippingOrder;

  @override
  State<CallBackMePage> createState() => _CallBackMePageState();
}

class _CallBackMePageState extends State<CallBackMePage>
    with AutomaticKeepAliveClientMixin<CallBackMePage> {
  GlobalKey pageKey = GlobalKey<State>();

  TaxiViewModel? get vm => null;
  @override
  Widget build(BuildContext context) {
    print("CallBackMePage");
    super.build(context);
    return ViewModelBuilder<CallBackMeViewModel>.reactive(
      viewModelBuilder: () => CallBackMeViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
            resizeToAvoidBottomInset:
                true, // Điều này sẽ giúp đẩy màn hình lên khi bàn phím xuất hiện
            showAppBar: true,
            showLeadingAction: !AppStrings.isSingleVendorMode,
            elevation: 0,
            title: "${widget.vendorType.name}",
            appBarColor: context.theme.colorScheme.background,
            appBarItemColor: AppColor.primaryColor,
            showCart: true,
            key: model.pageKey,
            body: SingleChildScrollView(
              child: VStack(
                [
                  CustomImage(
                    imageUrl:
                        "https://sod.di4l.vn/storage/17/3639/ja2aTjTyanmrKboN3l52H7Vata0jEY-metaYmFubmVyX3NlcjIuanBn-.jpg",
                    height: 220,
                    canZoom: true,
                  ).wFull(context),
                  //location setion
                  //label "nhập địa điểm"
                  "Enter your information"
                      .tr()
                      .text
                      .textStyle(context.textTheme.titleMedium!.copyWith(
                        color: AppColor.primaryColor,
                      ))
                      .make()
                      .pOnly(top: 10, left: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextFormField(
                      hintText: "Enter address".tr(),
                      labelText: "Address".tr(),
                      isReadOnly: true,
                      textEditingController: model.addressTEC,
                      validator: (value) => FormValidator.validateEmpty(value,
                          errorTitle: "Address".tr()),
                      onTap: model.showAddressLocationPicker,
                    ).py2(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextFormField(
                      hintText: "Enter phone".tr(),
                      labelText: "Phone".tr(),
                      textEditingController: model.phoneTEC,
                      validator: (value) => FormValidator.validateEmpty(value,
                          errorTitle: "Phone".tr()),
                    ).py2(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomTextFormField(
                      hintText: "Enter name contact".tr(),
                      labelText: "Name".tr(),
                      textEditingController: model.nameTEC,
                      validator: (value) => FormValidator.validateEmpty(value,
                          errorTitle: "Name".tr()),
                    ).py2(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                  ),
                  // Nhập yêu cầu của bạn
                  "Enter your request"
                      .tr()
                      .text
                      .textStyle(context.textTheme.titleMedium!.copyWith(
                        color: AppColor.primaryColor,
                      ))
                      .make()
                      .pOnly(top: 10, left: 10),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: VStack(
                      crossAlignment: CrossAxisAlignment.start,
                      [
                        UiSpacer.vSpace(10),
                        FormBuilderTextField(
                          onChanged: (value) async {
                            model.note = value.toString();
                          },
                          name: "Request".tr(),
                          keyboardType: TextInputType.text,
                          validator: CustomFormBuilderValidator.required,
                          maxLines: 3,
                          minLines: 3,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColor.primaryColor)),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: AppColor.primaryColor)),
                          ).copyWith(
                            labelText: "Enter your request".tr(),
                            alignLabelWithHint: true,
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: "Shipper will buy according to your request"
                        .tr()
                        .text
                        .textStyle(context.textTheme.titleMedium!.copyWith())
                        .make()
                        .pOnly(top: 10, left: 10),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Center(
                      child:
                          "Shipping fees are calculated based on the distance in kilometers from the place of purchase to your delivery location."
                              .tr()
                              .text
                              .textStyle(
                                  context.textTheme.titleMedium!.copyWith())
                              .align(TextAlign.center) // Căn giữa văn bản
                              .make()
                              .pOnly(top: 10, left: 10),
                    ),
                  ),
                  // Button xác nhận yêu cầu
                  CustomButton(
                    title: "Confirm request".tr(),
                    // onPressed: model.processNewOrder,
                    onPressed: () {
                      model.processNewOrder();
                    },
                  ).p8().safeArea(top: false),
                ],
              ),
            ));
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
