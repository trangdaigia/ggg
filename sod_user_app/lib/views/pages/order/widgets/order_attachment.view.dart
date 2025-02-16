import 'package:flutter/material.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/order_details.vm.dart';
import 'package:sod_user/widgets/custom_grid_view.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderAttachmentView extends StatelessWidget {
  const OrderAttachmentView(this.vm, {Key? key}) : super(key: key);

  final OrderDetailsViewModel vm;
  @override
  Widget build(BuildContext context) {
    return (vm.order.attachments != null && vm.order.attachments!.isNotEmpty)
        ? VStack(
            [
              "Attachments".tr().text.xl.semiBold.make(),
              UiSpacer.vSpace(10),
              CustomGridView(
                dataSet: vm.order.attachments!,
                noScrollPhysics: true,
                itemBuilder: (ctx, index) {
                  final attachment = vm.order.attachments![index];
                  return Column(
                    children: [
                      CustomImage(
                        imageUrl: attachment.link!,
                        canZoom: true,
                        width: double.infinity,
                        height: ctx.percentHeight * 14,
                        //make the image fit the container
                        boxFit: BoxFit.contain,
                      ),
                      //
                      // "${attachment.collectionName}".text.make().py2(),
                      "${index + 1}".text.make().py2(),
                    ],
                  );
                },
              ),
            ],
          ).p8().p12()
        : 0.heightBox;
  }
}
