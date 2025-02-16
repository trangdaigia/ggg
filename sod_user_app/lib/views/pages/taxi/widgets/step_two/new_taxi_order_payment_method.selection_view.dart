import 'package:flutter/material.dart';
import 'package:sod_user/view_models/taxi_new_order_summary.vm.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:sod_user/widgets/directional_chevron.dart';
import 'package:velocity_x/velocity_x.dart';

class NewTaxiOrderPaymentMethodSelectionView extends StatelessWidget {
  const NewTaxiOrderPaymentMethodSelectionView({
    required this.vm,
    this.hasBorder = false,
    Key? key,
  }) : super(key: key);

  final NewTaxiOrderSummaryViewModel vm;
  final bool hasBorder;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: hasBorder // Kiểm tra biến hasBorder
            ? Border(
                right: BorderSide(
                  color: Color.fromARGB(255, 195, 191, 191),
                  width: 1.0,
                ),
              )
            : null, 
      ),
      child:  HStack(
        [
          CustomImage(
            imageUrl: vm.taxiViewModel.selectedPaymentMethod!.photo,
          ).wh(30, 30),
          "${vm.taxiViewModel.selectedPaymentMethod!.name}"
              .text
              .make()
              .px12()
              .expand(),
          //DirectionalChevron(),
        ],
      )
          .onInkTap(
            vm.openPaymentMethodSelection,
          )
          .box
          .roundedSM
          .color(const Color.fromARGB(230,234,245,255))
          .px8
          .make(),
      );
    }
}
