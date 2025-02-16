import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_finance_settings.dart';
import 'package:sod_user/models/vehicle.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/vnd_text_formatter.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/post_ride_confirm.page.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/car_drop_down.button.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_input.page.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_text_field.view.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:sod_user/utils/utils.dart';

class PostRideInfoPage extends StatefulWidget {
  final SharedRideViewModel model;
  PostRideInfoPage({
    Key? key,
    required this.model,
  }) : super(key: key);
  @override
  State<PostRideInfoPage> createState() => _PostRideInfoPageState();
}

class _PostRideInfoPageState extends State<PostRideInfoPage> {
  int i = 0;
  final formKey = GlobalKey<FormState>();
  final packageKey = GlobalKey<FormState>();
  late CarManagementViewModel model;
  @override
  void initState() {
    widget.model.calculatePrice();
    model = CarManagementViewModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CarManagementViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => model,
        onViewModelReady: (viewModel) async {
          await widget.model.getRentalVehicles();
          viewModel.initialise();
        },
        builder: (context, viewModel, child) {
          return BasePage(
            backgroundColor: Colors.white,
            showAppBar: true,
            customAppbar: PreferredSize(
              preferredSize: Size.fromHeight(60),
              child: AppBar(
                backgroundColor: AppColor.primaryColor,
                title: "Ride information".tr().text.make(),
              ),
            ),
            body: VStack(
              axisSize: MainAxisSize.min,
              crossAlignment: CrossAxisAlignment.start,
              [
                UiSpacer.vSpace(15),
                "Please choose a price in a suitable range for ride"
                    .tr()
                    .text
                    .black
                    .make(),
                UiSpacer.vSpace(15),
                Form(
                  key: formKey,
                  child: PostShareRideTextField(
                    enabled:
                        AppFinanceSettings.enableSharedRidePrice ? false : true,
                    validator: (value) {
                      if (value!.isEmpty) return 'Enter amount'.tr();
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      VNTextFormatter(),
                    ],
                    fontSize: 24,
                    controller: widget.model.priceController,
                    hintText: "",
                    prefixIcon:
                        const Icon(Icons.account_balance_wallet_rounded),
                    suffix: HStack(
                      axisSize: MainAxisSize.min,
                      alignment: MainAxisAlignment.center,
                      crossAlignment: CrossAxisAlignment.center,
                      ["đ".text.bold.size(24).make()],
                    ),
                  ),
                ),
                UiSpacer.vSpace(20),
                VxBox(
                  child: HStack(
                    alignment: MainAxisAlignment.center,
                    [
                      AppFinanceSettings.enableSharedRidePrice
                          ? "Price set is on, you cannot change trip price"
                              .tr()
                              .text
                              .textStyle(TextStyle(fontSize: 12))
                              .bold
                              .black
                              .make()
                          : "Price set is off, you are allowed to change trip price"
                              .tr()
                              .text
                              .textStyle(TextStyle(fontSize: 12))
                              .black
                              .bold
                              .make()
                    ],
                  ),
                )
                    .width(double.infinity)
                    .withDecoration(BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ))
                    .padding(EdgeInsets.symmetric(vertical: 10, horizontal: 15))
                    .make(),
                UiSpacer.vSpace(20),
                'Pick a car'.tr().text.black.bold.make(),
                'Which vehicle will you travel with'
                    .tr()
                    .text
                    .color(Colors.grey[400])
                    .make(),
                UiSpacer.vSpace(20),
                widget.model.vehicles.isNotEmpty
                    ? VxBox(
                        child: CarDropDownButton(
                          value: widget.model.selectedVehicle!.id.toString(),
                          prefixIcon: const Icon(Icons.directions_car,
                              color: Colors.grey),
                          items: widget.model.vehicles.map((Vehicle value) {
                            return DropdownMenuItem<String>(
                              value: value.id.toString(),
                              child:
                                  "${value.carModel?.carMake ?? ""}, ${value.carModel} (${value.yearMade ?? "2000"}), ${value.color}"
                                      .text
                                      .black
                                      .make(),
                            );
                          }).toList(),
                          onChanged: (value) {
                            widget.model.selectedVehicle = widget.model.vehicles
                                .firstWhere((element) =>
                                    element.id == int.parse(value!));
                          },
                        ),
                      )
                        .withDecoration(BoxDecoration(
                          border: Border.all(color: Colors.grey[350]!),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                        ))
                        .make()
                    : CustomButton(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            "You don't have any vehicles yet".tr().text.make(),
                            "Click to add vehicle".tr().text.make(),
                          ],
                        ),
                        onPressed: () {
                          viewModel.brandController.text = '';
                          viewModel.brandId = '';
                          viewModel.carModelController.text = '';
                          viewModel.carModelId = '';
                          viewModel.colorController.text = '';
                          viewModel.addressController.text = '';
                          viewModel.regNoController.text = '';
                          viewModel.price26Controller.text = '';
                          viewModel.price7cnController.text = '';
                          viewModel.requirements = [];
                          viewModel.utilities = [];
                          viewModel.yearMadeController.text = '';
                          viewModel.newPhotos = [];
                          // context.nextPage(NavigationService().addCarRentalPage(
                          //     model: viewModel, type: "address"));
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => NavigationService()
                                      .addCarRentalPage(
                                          shareRideModel: widget.model,
                                          model: viewModel,
                                          type: "address")));
                        },
                      ),
                if (widget.model.type == "person") ...[
                  UiSpacer.vSpace(20),
                  "Number of seat".tr().text.black.bold.make(),
                  UiSpacer.vSpace(20),
                  PostShareRideTextField(
                    enabled: false,
                    onTap: () => context.nextPage(PostShareRideInputPage(
                        type: "number_of_seat", model: widget.model)),
                    hintText: "Number of seat".tr(),
                    prefixIcon: const Icon(Icons.chair, size: 25),
                    controller: widget.model.number_of_seat,
                  ),
                ],
                if (widget.model.type == "package") ...[
                  UiSpacer.vSpace(20),
                  "Package details".tr().text.black.bold.make(),
                  UiSpacer.vSpace(20),
                  Form(
                    key: packageKey,
                    child: VStack(
                      [
                        PostShareRideTextField(
                          validator: (value) {
                            if (value!.isEmpty) return "Empty".tr();
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            VNTextFormatter(),
                          ],
                          controller: widget.model.packagePriceController,
                          hintText: "Package price".tr(),
                          prefixIcon: const Icon(Icons.attach_money_rounded),
                          suffix: HStack(
                            axisSize: MainAxisSize.min,
                            alignment: MainAxisAlignment.center,
                            crossAlignment: CrossAxisAlignment.center,
                            ["đ".text.bold.size(24).make()],
                          ),
                        ),
                        UiSpacer.vSpace(10),
                        PostShareRideTextField(
                          validator: (value) {
                            if (value!.isEmpty) return "Empty".tr();
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: widget.model.widthController,
                          hintText: "${"Width".tr()} (cm)",
                          prefixIcon: Icon(Icons.info),
                        ),
                        UiSpacer.vSpace(10),
                        PostShareRideTextField(
                          validator: (value) {
                            if (value!.isEmpty) return "Empty".tr();
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: widget.model.heightController,
                          hintText: "${"Height".tr()} (cm)",
                          prefixIcon: Icon(Icons.info),
                        ),
                        UiSpacer.vSpace(10),
                        PostShareRideTextField(
                          validator: (value) {
                            if (value!.isEmpty) return "Empty".tr();
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: widget.model.lengthController,
                          hintText: "${"Length".tr()} (cm)",
                          prefixIcon: Icon(Icons.info),
                        ),
                        UiSpacer.vSpace(10),
                        PostShareRideTextField(
                          validator: (value) {
                            if (value!.isEmpty) return "Empty".tr();
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          controller: widget.model.weightController,
                          hintText: "${"Weight".tr()} (Kg)",
                          prefixIcon: Icon(Icons.info),
                        )
                      ],
                    ),
                  )
                ],
                UiSpacer.vSpace(20),
                'Note'.tr().text.black.make(),
                UiSpacer.vSpace(10),
                PostShareRideTextField(
                  controller: widget.model.noteController,
                  hintText: "Note for passenger".tr(),
                  prefixIcon: const Icon(CupertinoIcons.chat_bubble),
                ),
                UiSpacer.vSpace(20),
              ],
            ).p(10).scrollVertical(physics: const BouncingScrollPhysics()),
            bottomNavigationBar: CustomButton(
              onPressed: () {
                if (widget.model.type == "package") {
                  if (formKey.currentState!.validate() &&
                      packageKey.currentState!.validate()) {
                    context.nextPage(PostRideConfirmPage(model: widget.model));
                  }
                } else {
                  if (formKey.currentState!.validate()) {
                    final forbiddenWord = Utils.checkForbiddenWordsInString(
                        widget.model.noteController.text);
                    if (forbiddenWord != null) {
                      CoolAlert.show(
                        context: context,
                        type: CoolAlertType.error,
                        title: "Warning forbidden words".tr(),
                        text: "Your information contains forbidden word".tr() +
                            ": $forbiddenWord",
                      );
                      return;
                    }
                    context.nextPage(PostRideConfirmPage(model: widget.model));
                  }
                }
              },
              title: "Proceed".tr(),
            ).p(15),
          );
        });
  }
}
