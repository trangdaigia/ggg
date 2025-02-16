import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/shared_ride.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/edit_general_info.page.dart';
import 'package:sod_user/views/pages/shared_ride/edit_note.page.dart';
import 'package:sod_user/views/pages/shared_ride/edit_trip_price.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class EditTripPage extends StatefulWidget {
  const EditTripPage({Key? key, required this.sharedRide, required this.model}) : super(key: key);

  final SharedRide sharedRide;
  final SharedRideViewModel model;

  @override
  State<EditTripPage> createState() => _EditTripPageState();
}

class _EditTripPageState extends State<EditTripPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit trip".tr()), backgroundColor: AppColor.primaryColor),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Text(
                "Update your trip information".tr(),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                child: GestureDetector(
                  onTap: () => context.nextPage(EditGeneralInfoPage(sharedRide: widget.sharedRide, model: widget.model)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "General information".tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Departure, destination, start date, number of people".tr()),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_right),
                    ],
                  ),
                ),
              ),
              const Divider(color: Colors.grey),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                child: GestureDetector(
                  onTap: () => context.nextPage(EditTripPricePage(sharedRide: widget.sharedRide, model: widget.model)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Trip price".tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Update trip price".tr())
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_right),
                    ],
                  ),
                ),
              ),
              const Divider(color: Colors.grey),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
                child: GestureDetector(
                  onTap: () => context.nextPage(EditNotePage(sharedRide: widget.sharedRide, model: widget.model)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Note".tr(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text("Note for passenger".tr())
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_right),
                    ],
                  ),
                ),
              ),
              const Divider(color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
