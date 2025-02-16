import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/driver_lib/views/pages/vehicle/detail_vehicle.page.dart';
import 'package:sod_user/driver_lib/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class VehicleListItem extends StatefulWidget {
  VehicleListItem({
    required this.vehicle,
    Key? key,
    this.onpress,
    this.canChangeStatus = true,
    required this.onLongpress,
    required this.onDisable,
  }) : super(key: key);

//
  final Vehicle vehicle;
  final bool canChangeStatus;
  final Function()? onpress;
  final Function() onLongpress;
  final Function() onDisable;
  @override
  State<VehicleListItem> createState() => _VehicleListItemState();
}

class _VehicleListItemState extends State<VehicleListItem> {
  @override
  Widget build(BuildContext context) {
    return VStack(
      [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: widget.vehicle.verified!
              ? Colors.grey.shade50
              : Colors.grey.shade200,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailVehiclePage(
                    vehicle: widget.vehicle,
                  ),
                ),
              );
            },
            onLongPress:
                widget.vehicle.verified == false ? null : widget.onLongpress,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: Stack(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Positioned(
                    right: 0,
                    // left: 0,
                    top: 0,
                    child: Image(
                      image: AssetImage(widget.vehicle.verified ?? false
                          ? 'assets/images/approved.png'
                          : "assets/images/unverified.png"), // Replace with your image path
                      // size: 20, // Icon size
                      // color: AppColor.deliveredColor,
                      fit: BoxFit.contain,
                    ).box.width(20).height(20).make(),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      VStack(
                        [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomImage(
                              imageUrl: widget.vehicle.vehicleType!.photo,
                            ).wh(40, 40).pOnly(bottom: 4),
                          ),
                          if (!(widget.vehicle.verified ?? false))
                            RichText(
                              text: TextSpan(
                                text: "Unverified".tr(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                            )
                        ],
                        crossAlignment: CrossAxisAlignment.center,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: widget.vehicle.vehicleType!.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        " - ${widget.vehicle.service?.name ?? ""}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "${widget.vehicle.carModel?.carMake?.name ?? ""} ${widget.vehicle.carModel?.carMake?.name != null ? "-" : ""} ${widget.vehicle.carModel?.name ?? ""}",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              widget.vehicle.regNo != null
                                  ? "${widget.vehicle.regNo} - ${widget.vehicle.color}"
                                  : "Lái xe hộ".tr(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Visibility(
                          visible: (widget.vehicle.verified ?? false) &&
                              widget.canChangeStatus,
                          child: Switch(
                              activeTrackColor: AppColor.deliveredColor,
                              inactiveTrackColor: AppColor.closeColor,
                              inactiveThumbColor: Colors.white,
                              trackOutlineColor: WidgetStatePropertyAll<Color>(
                                  Colors.transparent),
                              value: widget.vehicle.isActive == 1,
                              onChanged: (e) {
                                print("Vehicle: $e");
                                if (e && widget.vehicle.verified != false)
                                  widget.onLongpress();
                                else
                                  widget.onDisable();
                              }))
                    ],
                  ).px12().py8(),
                ],
              ),
            ),
          ),
        ),
        // widget.vehicle.verified! && widget.vehicle.isActive != 1
        //     ? Text(
        //         "Long press to switch vehicle".tr(),
        //         style: TextStyle(
        //           fontSize: 12,
        //           color: Colors.grey.shade600,
        //           fontStyle: FontStyle.italic,
        //         ),
        //       )
        //     : SizedBox(
        //         height: 5,
        //       )
      ],
    );
  }
}
