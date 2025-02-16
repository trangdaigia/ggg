import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sod_user/driver_lib/services/custom_form_builder_validator.service.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/receive_behalf.vm.dart';
import 'package:sod_user/driver_lib/views/pages/receive_behalf/confirm_receive_behalf.page.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/buttons/custom_button.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ReceiveBehalfPage extends StatelessWidget {
  const ReceiveBehalfPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ReceiveBehalfViewModel>.reactive(
      viewModelBuilder: () => ReceiveBehalfViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      onDispose: (vm) =>
          print("=========dispose receive behalf view model============"),
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "Receive Behalf".tr(),
          body: FormBuilder(
            key: vm.formBuilderKey,
            child: VStack(
              axisSize: MainAxisSize.min,
              crossAlignment: CrossAxisAlignment.start,
              [
                UiSpacer.vSpace(4),
                "Receiver information".tr().text.xl.bold.make(),
                UiSpacer.vSpace(10),
                HStack(
                  [
                    Expanded(
                      flex: 3,
                      child: VStack(
                        crossAlignment: CrossAxisAlignment.start,
                        [
                          HStack(
                            alignment: MainAxisAlignment.spaceBetween,
                            [
                              '${"User phone number".tr()} *'.text.make(),
                            ],
                          ),
                          UiSpacer.vSpace(10),
                          FormBuilderTextField(
                            onChanged: (value) async {
                              vm.searchUserList =
                                  await vm.request.phoneSearch(value!);
                              vm.notifyListeners();
                            },
                            name: "Phone number".tr(),
                            keyboardType: TextInputType.number,
                            validator: CustomFormBuilderValidator.required,
                            decoration: InputDecoration(
                              enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red)),
                            ).copyWith(labelText: "User phone number".tr()),
                            textInputAction: TextInputAction.next,
                            controller: vm.userPhoneNumberController,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Visibility(
                  visible: vm.hasErrorForKey('user') &&
                      (vm.deliveryUser == null || vm.images.isEmpty),
                  child: vm
                      .error('user')
                      .toString()
                      .text
                      .fontWeight(FontWeight.w600)
                      .red600
                      .make()
                      .py12(),
                ),
                VStack(
                  [
                    VStack(
                      alignment: MainAxisAlignment.center,
                      crossAlignment: CrossAxisAlignment.start,
                      axisSize: MainAxisSize.min,
                      [
                        vm.userPhoneNumberController.text.isNotEmpty
                            ? Container(
                                height: 100,
                                padding: const EdgeInsets.all(10),
                                child: vm.searchUserList.isNotEmpty
                                    ? Scrollbar(
                                        child: ListView.separated(
                                          separatorBuilder: (context, index) {
                                            return UiSpacer.divider(height: 10);
                                          },
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: vm.searchUserList.length,
                                          itemBuilder: (context, index) {
                                            return GestureDetector(
                                              onTap: () async {
                                                vm.userPhoneNumberController
                                                        .text =
                                                    vm.searchUserList[index]
                                                        .phone!;
                                                vm.deliveryUser =
                                                    vm.searchUserList[index];
                                                vm.notifyListeners();
                                              },
                                              child: vm.searchUserList[index]
                                                  .phone!.text
                                                  .fontWeight(FontWeight.w500)
                                                  .xl
                                                  .make(),
                                            );
                                          },
                                        ).scrollVertical(),
                                      )
                                    : UiSpacer.emptySpace())
                            : UiSpacer.emptySpace(),
                        vm.deliveryUser != null
                            ? Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey,
                                ),
                                child: HStack(
                                  [
                                    CircleAvatar(
                                        radius: 35,
                                        backgroundImage: NetworkImage(
                                            vm.deliveryUser!.photo)),
                                    UiSpacer.hSpace(10),
                                    VStack(
                                      crossAlignment: CrossAxisAlignment.start,
                                      [
                                        '${'Full name'.tr()}: ${vm.deliveryUser!.name}'
                                            .text
                                            .make(),
                                        UiSpacer.vSpace(8),
                                        '${'Phone'.tr()}: ${vm.deliveryUser!.phone}'
                                            .text
                                            .make(),
                                        UiSpacer.vSpace(8),
                                        // Text('${'Apartment'.tr}: ${deliveryUser.apartment?.name ?? ''}'),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            : UiSpacer.emptySpace(),
                        UiSpacer.vSpace(10),
                        '${'Package images'.tr()} *'.text.make(),
                        UiSpacer.vSpace(10),
                        vm.images.isNotEmpty
                            ? CarouselSlider(
                                items: vm.images
                                    .map(
                                      (element) => ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(element,
                                            fit: BoxFit.cover,
                                            width: double.infinity),
                                      ),
                                    )
                                    .toList(),
                                options: CarouselOptions(
                                    autoPlay: true, viewportFraction: 1),
                              )
                            : UiSpacer.emptySpace(),
                        UiSpacer.vSpace(10),
                        CustomButton(
                          title: 'Picked from gallery'.tr(),
                          onPressed: () async {
                            final selectedImages = await ImagePicker()
                                .pickMultiImage(
                                    maxWidth: 1024, maxHeight: 1024);
                            if (selectedImages.isNotEmpty) {
                              vm.images = selectedImages
                                  .map((e) => File(e.path))
                                  .toList();
                              vm.notifyListeners();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ).py12(),
                UiSpacer.vSpace(10),
                CustomButton(
                  title: 'Continue'.tr(),
                  onPressed: () {
                    if (vm.deliveryUser == null) {
                      vm.setErrorForObject(
                          'user', "User phone number is required".tr());
                      return;
                    }
                    if (vm.images.isEmpty) {
                      vm.setErrorForObject('user', "Please pick images".tr());
                      return;
                    }
                    // print("nextpage======== ${vm.deliveryUser!.phone} isEmptyImage: ${vm.images.isEmpty}");
                    if (context.mounted) {
                      context.nextPage(ConfirmReceiveBehalfPage(vm: vm));
                    }
                  },
                )
              ],
            ),
          )
              .scrollVertical(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15))
              .pOnly(bottom: MediaQuery.of(context).viewInsets.bottom),
        );
      },
    );
  }
}
