import 'package:flutter/material.dart';
import 'package:sod_user/models/payment_method.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/payment_method.list_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class PaymentMethodSelectionPage extends StatelessWidget {
  const PaymentMethodSelectionPage({
    required this.list,
    this.selected,
    Key? key,
  }) : super(key: key);

  final List<PaymentMethod> list;
  final PaymentMethod? selected;

  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "Payment Methods".tr(),
      body: VStack(
        [
          CustomListView(
            dataSet: list,
            separatorBuilder: (ctx, index) => UiSpacer.vSpace(10),
            itemBuilder: (ctx, index) {
              final paymentMethod = list[index];
              return PaymentOptionListItem(
                paymentMethod,
                onSelected: (paymentMethod) {
                  Navigator.pop(ctx, paymentMethod);
                },
              );
            },
          ).p12(),
        ],
      ),
    );
  }
}
