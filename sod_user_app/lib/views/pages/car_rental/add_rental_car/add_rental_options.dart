import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class AddRentalOptions extends StatefulWidget {
  const AddRentalOptions(
      {super.key,
      required this.model,
      this.showNext = true,
      this.data,
      this.shareRideModel});
  final bool showNext;
  final CarRental? data;
  final CarManagementViewModel model;
  final SharedRideViewModel? shareRideModel;

  @override
  State<AddRentalOptions> createState() => _AddRentalOptionsState();
}

class _AddRentalOptionsState extends State<AddRentalOptions> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.data != null) {
      widget.model.rental_options = widget.data!.rental_options;
    } else {
      widget.model.rental_options = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BasePage(
        showAppBar: true,
        showLeadingAction: true,
        title: 'Rental options'.tr(),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            'Choose to rent a car with a driver, self-drive or both'
                .tr()
                .text
                .make(),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Radio<int>(
                      value: 0,
                      groupValue: widget.model.rental_options,
                      onChanged: (value) {
                        setState(() {
                          widget.model.rental_options = value!;
                        });
                      },
                    ),
                    'Self drive'.tr().text.make(),
                  ],
                ),
                Row(
                  children: [
                    Radio<int>(
                      value: 1,
                      groupValue: widget.model.rental_options,
                      onChanged: (value) {
                        setState(() {
                          widget.model.rental_options = value!;
                        });
                      },
                    ),
                    'With driver'.tr().text.make(),
                  ],
                ),
                Row(
                  children: [
                    Radio<int>(
                      value: 2,
                      groupValue: widget.model.rental_options,
                      onChanged: (value) {
                        setState(() {
                          widget.model.rental_options = value!;
                        });
                      },
                    ),
                    'Both'.tr().text.make(),
                  ],
                ),
              ],
            ),
          ]),
        ),
        bottomNavigationBar: widget.showNext
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: CustomButton(
                      title: 'next'.tr().capitalized,
                      onPressed: () {
                        context.nextPage(
                          NavigationService().addCarRentalPage(
                            shareRideModel: widget.shareRideModel,
                            model: widget.model,
                            type: "requirement",
                          ),
                        );
                      },
                    )))
            : Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: CustomButton(
                      title: 'update'.tr(),
                      loading: isLoading,
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await widget.model.changeCarRentalOption(
                          id: widget.data!.id.toString(),
                          rental_options: widget.model.rental_options!,
                        );
                        setState(() {
                          isLoading = false;
                        });
                      },
                    ))));
  }
}
