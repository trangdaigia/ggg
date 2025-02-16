import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/shared_ride.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_input.page.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_text_field.view.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class EditGeneralInfoPage extends StatefulWidget {
  final SharedRide sharedRide;
  final SharedRideViewModel model;
  const EditGeneralInfoPage(
      {Key? key, required this.sharedRide, required this.model})
      : super(key: key);

  @override
  State<EditGeneralInfoPage> createState() => _EditGeneralInfoPageState();
}

class _EditGeneralInfoPageState extends State<EditGeneralInfoPage> {
  @override
  void initState() {
    widget.model.departure.text = widget.sharedRide.departureName!;
    widget.model.destination.text = widget.sharedRide.destinationName!;
    widget.model.date.text = widget.sharedRide.startDate!;
    widget.model.time.text = widget.sharedRide.startTime!;
    widget.model.number_of_seat.text =
        widget.sharedRide.numberOfSeat.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColor.primaryColor,
          title: Text("Edit information".tr())),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                "Update your trip information".tr(),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              PostShareRideTextField(
                enabled: false,
                controller: widget.model.departure,
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
              const SizedBox(height: 10),
              PostShareRideTextField(
                enabled: false,
                controller: widget.model.destination,
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
              const SizedBox(height: 10),
              Row(
                children: [
                  Flexible(
                    flex: 1,
                    child: PostShareRideTextField(
                      enabled: false,
                      onTap: () => context.nextPage(PostShareRideInputPage(
                          type: "date", model: widget.model)),
                      controller: widget.model.date,
                      hintText: "today".tr(),
                      prefixIcon: const Icon(Icons.calendar_month, size: 25),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Flexible(
                    flex: 1,
                    child: PostShareRideTextField(
                      enabled: false,
                      onTap: () => context.nextPage(PostShareRideInputPage(
                          type: "time", model: widget.model)),
                      hintText: DateFormat("HH:mm").format(DateTime.now()),
                      prefixIcon: const Icon(Icons.access_time, size: 25),
                      controller: widget.model.time,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: PostShareRideTextField(
                      enabled: false,
                      onTap: () => context.nextPage(PostShareRideInputPage(
                          type: "number_of_seat", model: widget.model)),
                      hintText: "Number of seat".tr(),
                      prefixIcon: const Icon(Icons.chair, size: 25),
                      controller: widget.model.number_of_seat,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomButton(
        onPressed: () async {
          await widget.model.updateSharedRide(type: "general");
          Navigator.pop(context);
          Navigator.pop(context);
        },
        title: "Confirm".tr(),
      ).p(16),
    );
  }
}
