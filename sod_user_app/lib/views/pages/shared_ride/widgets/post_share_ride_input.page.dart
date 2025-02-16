import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/services/geocoder.service.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_text_field.view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/address.list_item.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/services/alert.service.dart';

class PostShareRideInputPage extends StatefulWidget {
  final String? type;
  final SharedRideViewModel model;
  PostShareRideInputPage({Key? key, this.type, required this.model})
      : super(key: key);

  @override
  State<PostShareRideInputPage> createState() => _PostShareRideInputPageState();
}

class _PostShareRideInputPageState extends State<PostShareRideInputPage> {
  int seat = 1;
  DateTime now = DateTime.now();
  List<Address>? places = [];
  bool isLoadingPlaces = false;

  Timer? _debounce;

  @override
  dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> searchPlace(String keyword) async {
    if (keyword.isEmpty) return;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 1000),
      () async {
        try {
          setState(() {
            isLoadingPlaces = true;
          });
          print('places $keyword');
          places = await GeocoderService().findAddressesFromQuery(keyword);
          setState(() {
            isLoadingPlaces = false;
          });
          print('places found ==> ${places?.length}');
        } catch (error) {
          print("search error ==> $error");
          places = [];
        }
      },
    );
  }

  onAddressSelected(Address address) async {
    AlertService.showLoading();
    try {
      address = await GeocoderService().fecthPlaceDetails(address);
      final lat = address.coordinates!.latitude;
      final long = address.coordinates!.longitude;
      final addressLine = address.addressLine!;

      List<Placemark> placeMarks = await placemarkFromCoordinates(lat, long);
      widget.type == "departure"
          ? widget.model.departureCity = placeMarks.first.administrativeArea
          : widget.model.destinationCity = placeMarks.first.administrativeArea;
      widget.type == "departure"
          ? widget.model.departure.text = addressLine
          : widget.model.destination.text = addressLine;
      widget.type == "departure"
          ? widget.model.depatureLatLong = LatLng(lat, long)
          : widget.model.destinationLatLong = LatLng(lat, long);
      //
      places = [];
    } catch (error) {
      print("error ===> $error");
    }
    AlertService.stopLoading();
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          if (widget.type == "departure" || widget.type == "destination")
            Column(
              children: [
                PostShareRideTextField(
                  controller: widget.type == "departure"
                      ? widget.model.departure
                      : widget.model.destination,
                  hintText: widget.type!.tr(),
                  prefixIcon: Icon(widget.type == "departure"
                      ? CupertinoIcons.location
                      : CupertinoIcons.location_solid),
                  onChanged: (value) => searchPlace(value),
                ),
                Visibility(
                  visible: places != null,
                  child: CustomListView(
                    padding: EdgeInsets.zero,
                    isLoading: isLoadingPlaces,
                    dataSet: places ?? [],
                    itemBuilder: (contex, index) {
                      final place = places![index];
                      return AddressListItem(
                        place,
                        onAddressSelected: onAddressSelected,
                      );
                    },
                    separatorBuilder: (_, __) => UiSpacer.divider(),
                  ),
                ),
              ],
            ).p(16),
          //
          if (widget.type == "date")
            CalendarDatePicker(
              onDateChanged: (DateTime value) {
                DateFormat dateFormat = DateFormat("dd-MM-yyyy");
                widget.model.date.text = dateFormat.format(value);
              },
              lastDate: now.add(const Duration(days: 3650)),
              firstDate: now,
              initialDate: now,
            ),
          if (widget.type == "time")
            TimePickerSpinner(
              is24HourMode: true,
              minutesInterval: 1,
              time: now.add(Duration(hours: 3)),
              isShowSeconds: false,
              normalTextStyle: const TextStyle(
                  fontSize: 30,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold),
              highlightedTextStyle: const TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              itemHeight: 80,
              spacing: 50,
              isForce2Digits: true,
              onTimeChange: (time) {
                if (DateTime.now().add(Duration(hours: 3)).isAfter(
                    now.copyWith(hour: time.hour, minute: time.minute + 1))) {
                  context.showToast(
                      msg: "Departure time should be at least 3 hours from now"
                          .tr());
                  return;
                }
                DateFormat dateFormat = DateFormat("HH:mm");
                widget.model.time.text = dateFormat.format(time);
              },
            ),
          if (widget.type == "number_of_seat")
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                "How many people do you want to carry for this ride"
                    .tr()
                    .text
                    .bold
                    .black
                    .size(15)
                    .make(),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (seat == 1) return;
                        setState(() => seat--);
                        widget.model.number_of_seat.text = seat.toString();
                      },
                      icon: const Icon(CupertinoIcons.minus_circle,
                          color: Colors.blue, size: 35),
                    ),
                    seat.toString().text.size(70).bold.black.make(),
                    IconButton(
                      onPressed: () {
                        setState(() => seat++);
                        widget.model.number_of_seat.text = seat.toString();
                      },
                      icon: const Icon(CupertinoIcons.plus_circle,
                          color: Colors.blue, size: 35),
                    ),
                  ],
                )
              ],
            ),
          if (widget.type == "Width" ||
              widget.type == "Height" ||
              widget.type == "Length" ||
              widget.type == "Weight")
            Container(
              padding: const EdgeInsets.all(15),
              child: PostShareRideTextField(
                enabled: true,
                controller: widget.type == "Width"
                    ? widget.model.widthController
                    : widget.type == "Height"
                        ? widget.model.heightController
                        : widget.type == "Length"
                            ? widget.model.lengthController
                            : widget.model.weightController,
                hintText: widget.type!.tr(),
                prefixIcon: Icon(Icons.info),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
        ],
      ),
      bottomSheet: CustomButton(
        onPressed: () => Navigator.pop(context),
        title: "Confirm".tr(),
      ).p(15),
    );
  }
}
