import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/car_drop_down.button.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_input.page.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_text_field.view.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class PostRidePage extends StatefulWidget {
  const PostRidePage({Key? key}) : super(key: key);

  @override
  State<PostRidePage> createState() => _PostRidePageState();
}

class _PostRidePageState extends State<PostRidePage>
    with AutomaticKeepAliveClientMixin<PostRidePage> {
  late SharedRideViewModel model;

  @override
  void initState() {
    super.initState();
    model = SharedRideViewModel(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<SharedRideViewModel>.reactive(
      viewModelBuilder: () => model,
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          customAppbar: PreferredSize(
            preferredSize: Size.fromHeight(60),
            child: AppBar(
              backgroundColor: AppColor.primaryColor,
              title: VStack(
                crossAlignment: CrossAxisAlignment.start,
                [
                  "Post ride".tr().text.white.lg.bold.make(),
                  "Post ride to intercept passenger with the same route"
                      .tr()
                      .text
                      .white
                      .sm
                      .maxLines(1)
                      .overflow(TextOverflow.ellipsis)
                      .make(),
                ],
              ),
            ),
          ),
          body: VStack(
            [
              Container(
                color: Colors.green[100],
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  padding: const EdgeInsets.all(15),
                  child: Form(
                    key: model.formKey,
                    child: VStack(
                      axisSize: MainAxisSize.min,
                      [
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
                          context.nextPage(PostShareRideInputPage(
                              type: "departure", model: model));
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
                          onTap: () => context.nextPage(PostShareRideInputPage(
                              type: "destination", model: model)),
                          controller: model.destination,
                          hintText: "destination".tr(),
                          prefixIcon: const Icon(CupertinoIcons.location_solid),
                          validator: (String? value) {
                            if (value!.isNotEmpty) {
                              return null;
                            } else {
                              return 'Destination cannot be empty'.tr();
                            }
                          },
                        ),
                        UiSpacer.vSpace(10),
                        HStack(
                          [
                            Flexible(
                              flex: 1,
                              child: PostShareRideTextField(
                                enabled: false,
                                onTap: () => context.nextPage(
                                    PostShareRideInputPage(
                                        type: "date", model: model)),
                                controller: model.date,
                                hintText: "today".tr(),
                                prefixIcon:
                                    const Icon(Icons.calendar_month, size: 25),
                              ),
                            ),
                            UiSpacer.hSpace(15),
                            const SizedBox(width: 15),
                            Flexible(
                              flex: 1,
                              child: PostShareRideTextField(
                                enabled: false,
                                onTap: () => context.nextPage(
                                    PostShareRideInputPage(
                                        type: "time", model: model)),
                                hintText:
                                    DateFormat("HH:mm").format(DateTime.now().add(Duration(hours: 3))),
                                prefixIcon:
                                    const Icon(Icons.access_time, size: 25),
                                controller: model.time,
                              ),
                            ),
                          ],
                        ),
                        UiSpacer.vSpace(10),
                        CarDropDownButton(
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
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CustomButton(
                onPressed: () async {
                  model.checkCanProceedToInfoScreen();
                },
                title: "next".tr(),
              ).px(15),
            ],
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
