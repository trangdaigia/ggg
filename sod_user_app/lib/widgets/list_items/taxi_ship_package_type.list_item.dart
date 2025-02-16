import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_ui_styles.dart';
import 'package:sod_user/models/taxi_ship_package_type.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/view_models/taxi_new_ship_order_infor.vm.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class TaxiShipPackageListItem extends StatelessWidget {
  const TaxiShipPackageListItem(
    this.vm,
    this.taxiShipPackageType, {
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  final TaxiShipPackageType taxiShipPackageType;
  final Function onPressed;
  final NewTaxiShipOrderInforViewModel vm;
  @override
  Widget build(BuildContext context) {
    //
    final isSelected = vm.taxiViewModel.selectedPackageType != null && 
                       vm.taxiViewModel.selectedPackageType!.id == taxiShipPackageType.id;

    // dynamic fontsize
    final screen_width = MediaQuery.of(context).size.width;
    var fontsize = 14.0;
    // extra small mobile device
    if (screen_width <= 480){
      fontsize = 10.0;
    }
    // small mobile device
    else if (screen_width>480 && screen_width <= 960){
      fontsize = 12.0;
    }
    return AnimationConfiguration.staggeredList(
      position: taxiShipPackageType.id,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: InkWell(
            onTap: () => this.onPressed(),
            child: CustomButton(
              iconColor: vm.taxiViewModel.selectedPackageType != null && vm.taxiViewModel.selectedPackageType!.id == taxiShipPackageType.id ? null : Colors.black,
              icon: vm.packageTypeIconMap.containsKey(taxiShipPackageType.name)?
                    vm.packageTypeIconMap[taxiShipPackageType.name] : vm.packageTypeIconMap["default"],
              iconSize: 18,
              color: vm.taxiViewModel.selectedPackageType != null && vm.taxiViewModel.selectedPackageType!.id == taxiShipPackageType.id ? null : Color.fromARGB(255, 228, 228, 228),
              shapeRadius: 14,
               titleStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
                fontSize: fontsize,
                overflow: TextOverflow.ellipsis,
              ),
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0.5),
              title: this.taxiShipPackageType.name.tr(),
              onPressed: this.onPressed,
            ),
          )
          .box
          .clip(Clip.antiAlias)
          .withRounded(value: 10)
          .color(context.theme.colorScheme.background)
          .make()
          .pOnly(bottom: Vx.dp20),
        ),
      ),
    );
  }
}
