import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/home.page.dart';
import 'package:sod_user/views/pages/shared_ride/post_ride.page.dart';
import 'package:sod_user/views/pages/shared_ride/search_share_ride_result.page.dart';
import 'package:sod_user/views/pages/shared_ride/shared_ride.page.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/car_drop_down.button.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_input.page.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_text_field.view.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchRidePage extends StatefulWidget {
  const SearchRidePage({Key? key}) : super(key: key);

  @override
  State<SearchRidePage> createState() => _SearchRidePageState();
}

class _SearchRidePageState extends State<SearchRidePage>
    with AutomaticKeepAliveClientMixin<SearchRidePage> {
  late SharedRideViewModel model;
  final formKey = GlobalKey<FormState>();
  String? selectedType;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<SharedRideViewModel>.reactive(
      viewModelBuilder: () => SharedRideViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.nextReplacementPage(HomePage()),
              icon: Icon(Icons.arrow_back),
            ),
            backgroundColor: AppColor.primaryColor,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                "Search ride".tr().text.white.lg.bold.make(),
                "Find driver with the same route to move together"
                    .tr()
                    .text
                    .sm
                    .white
                    .maxLines(1)
                    .overflow(TextOverflow.ellipsis)
                    .make(),
              ],
            ),
          ),
          body: SafeArea(
            child: VStack(
              [
                Container(
                  color: const Color.fromARGB(255, 124, 138, 124),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PostShareRideTextField(
                            enabled: false,
                            onTap: () async {
                              LocationService.currenctAddress!.addressLine !=
                                      null
                                  ? model.departure.text = LocationService
                                      .currenctAddress!.addressLine
                                      .toString()
                                  : null;
                              if (LocationService
                                      .currenctAddress?.coordinates !=
                                  null) {
                                model.depatureLatLong = LatLng(
                                    LocationService
                                        .currenctAddress!.coordinates!.latitude,
                                    LocationService.currenctAddress!
                                        .coordinates!.longitude);
                                List<Placemark> placeMarks =
                                    await placemarkFromCoordinates(
                                        LocationService.currenctAddress!
                                            .coordinates!.latitude,
                                        LocationService.currenctAddress!
                                            .coordinates!.longitude);
                                model.departureCity =
                                    placeMarks.first.administrativeArea! +
                                        " City";
                              }
                              context.nextPage(
                                PostShareRideInputPage(
                                    type: "departure", model: model),
                              );
                            },
                            controller: model.departure,
                            hintText: "departure".tr(),
                            prefixIcon: const Icon(CupertinoIcons.location),
                            validator: (String? value) {
                              if (value!.isNotEmpty) {
                                return null;
                              } else {
                                return 'Departure cannot be empty'.tr();
                              }
                            },
                          ),
                          UiSpacer.vSpace(10),
                          PostShareRideTextField(
                            enabled: false,
                            onTap: () => context.nextPage(
                                PostShareRideInputPage(
                                    type: "destination", model: model)),
                            controller: model.destination,
                            hintText: "destination".tr(),
                            prefixIcon:
                                const Icon(CupertinoIcons.location_solid),
                            validator: (String? value) {
                              if (value!.isNotEmpty) {
                                return null;
                              } else {
                                return 'Destination cannot be empty'.tr();
                              }
                            },
                          ),
                          UiSpacer.vSpace(10),
                          PostShareRideTextField(
                            enabled: false,
                            onTap: () => context.nextPage(
                                PostShareRideInputPage(
                                    type: "date", model: model)),
                            controller: model.date,
                            hintText: "today".tr(),
                            prefixIcon:
                                const Icon(Icons.calendar_month, size: 25),
                          ),
                          UiSpacer.vSpace(10),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: CarDropDownButton(
                                  contentPadding: EdgeInsets.zero,
                                  value: model.type,
                                  prefixIcon: const Icon(Icons.type_specimen,
                                      color: Colors.grey),
                                  items: model.searchTypes.map((value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: value.tr().text.bold.black.make(),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    model.type = value!;
                                    model.notifyListeners();
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                flex: 1,
                                child: PostShareRideTextField(
                                  enabled: false,
                                  onTap: () {
                                    if (model.type == "person" ||
                                        model.type == "person_package")
                                      context.nextPage(PostShareRideInputPage(
                                          type: "number_of_seat",
                                          model: model));
                                  },
                                  hintText: "1".tr(),
                                  prefixIcon: Icon(
                                    Icons.account_circle,
                                    size: 25,
                                    color: model.type == "person"
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                  controller: model.number_of_seat,
                                ),
                              ),
                            ],
                          ),
                          UiSpacer.vSpace(10),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: PostShareRideTextField(
                                  enabled: false,
                                  onTap: () => model.type == "package" ||
                                          model.type == "person_package"
                                      ? context.nextPage(PostShareRideInputPage(
                                          type: "Width", model: model))
                                      : null,
                                  hintText: "Width".tr(),
                                  prefixIcon: Icon(
                                    Icons.info,
                                    size: 25,
                                    color: model.type == "package"
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                  controller: model.widthController,
                                ),
                              ),
                              UiSpacer.hSpace(5),
                              Expanded(
                                flex: 1,
                                child: PostShareRideTextField(
                                  enabled: false,
                                  onTap: () => model.type == "package" ||
                                          model.type == "person_package"
                                      ? context.nextPage(PostShareRideInputPage(
                                          type: "Height", model: model))
                                      : null,
                                  hintText: "Height".tr(),
                                  prefixIcon: Icon(
                                    Icons.info,
                                    size: 25,
                                    color: model.type == "package"
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                  controller: model.heightController,
                                ),
                              ),
                            ],
                          ),
                          UiSpacer.vSpace(10),
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: PostShareRideTextField(
                                  enabled: false,
                                  onTap: () => model.type == "package"
                                      ? context.nextPage(PostShareRideInputPage(
                                          type: "Length", model: model))
                                      : null,
                                  hintText: "Length".tr(),
                                  prefixIcon: Icon(
                                    Icons.info,
                                    size: 25,
                                    color: model.type == "package"
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                  controller: model.lengthController,
                                ),
                              ),
                              UiSpacer.hSpace(5),
                              Expanded(
                                flex: 1,
                                child: PostShareRideTextField(
                                  enabled: false,
                                  onTap: () => model.type == "package"
                                      ? context.nextPage(PostShareRideInputPage(
                                          type: "Weight", model: model))
                                      : null,
                                  hintText: "Weight".tr(),
                                  prefixIcon: Icon(
                                    Icons.info,
                                    size: 25,
                                    color: model.type == "package"
                                        ? Colors.black
                                        : Colors.grey,
                                  ),
                                  controller: model.weightController,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                CustomButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      if (model.date.value.text.isEmpty)
                        model.date.text =
                            DateFormat("dd-MM-yyyy").format(DateTime.now());
                      context.nextPage(
                        SearchshareRideResultPage(model: model),
                      );
                    }
                  },
                  title: "next".tr(),
                ).px(15),
              ],
            ),
          ),
          bottomSheet: SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                          onPressed: () => context.nextPage(PostRidePage()),
                          title: "Post ride".tr())
                      .px(10),
                ),
                Expanded(
                  child: CustomButton(
                          onPressed: () => context.nextPage(SharedRidePage()),
                          title: "My trip".tr())
                      .px(10),
                ),
              ],
            ),
          ).pOnly(bottom: 15, left: 5, right: 5),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
