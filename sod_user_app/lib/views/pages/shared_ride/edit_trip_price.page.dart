import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/shared_ride.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/utils/vnd_text_formatter.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/widgets/post_share_ride_text_field.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';

class EditTripPricePage extends StatefulWidget {
  final SharedRide sharedRide;
  final SharedRideViewModel model;
  const EditTripPricePage(
      {Key? key, required this.sharedRide, required this.model})
      : super(key: key);

  @override
  State<EditTripPricePage> createState() => _EditTripPricePageState();
}

class _EditTripPricePageState extends State<EditTripPricePage> {
  final a = TextEditingController();
  int? minPrice, maxPrice;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    a.text = Utils.formatCurrencyVND(
            double.parse(widget.sharedRide.price.toString()))
        .split(" ")[0];
    widget.model.priceController.value = a.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        title: Text("Trip price".tr()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              const SizedBox(height: 15),
              Text(
                  "Please choose a price for each person in a suitable range for ride"
                      .tr()),
              const SizedBox(height: 15),
              Form(
                key: formKey,
                child: PostShareRideTextField(
                  validator: (value) {
                    if (value!.isEmpty) return 'Enter amount'.tr();
                    if (int.parse(widget.model.priceController.originalText) <
                        int.parse(widget.sharedRide.minPrice!))
                      return "${'Price cannot be less than'.tr()} ${widget.sharedRide.minPrice.toString()}";
                    if (int.parse(widget.model.priceController.originalText) >
                        int.parse(widget.sharedRide.maxPrice!))
                      return "${'Price cannot be more than'.tr()} ${widget.sharedRide.maxPrice.toString()}";
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
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                  suffix: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      Text("đ",
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Price range".tr()),
                    Row(
                      children: [
                        Text(
                          '${Utils.formatCurrencyVND(double.parse(widget.sharedRide.minPrice.toString()))} - ${Utils.formatCurrencyVND(double.parse(widget.sharedRide.maxPrice.toString()))}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 10),
                        const Text('vnd'),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomButton(
        onPressed: () async {
          if (formKey.currentState!.validate()) {
            await widget.model.updateSharedRide(type: "price");
            Navigator.pop(context);
            Navigator.pop(context);
          }
        },
        title: "Confirm".tr(),
      ).p(16),
    );
  }
}
