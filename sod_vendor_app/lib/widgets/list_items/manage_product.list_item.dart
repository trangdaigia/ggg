import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/extensions/dynamic.dart';
import 'package:sod_vendor/models/product.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/widgets/busy_indicator.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:sod_vendor/widgets/currency_hstack.dart';
import 'package:sod_vendor/widgets/custom_image.view.dart';
import 'package:velocity_x/velocity_x.dart';

class ManageProductListItem extends StatelessWidget {
  //
  const ManageProductListItem(
    this.product, {
    this.isLoading = false,
    required this.onPressed,
    required this.onEditPressed,
    required this.onToggleStatusPressed,
    required this.onDeletePressed,
    Key? key,
  }) : super(key: key);

  //
  final Product product;
  final bool isLoading;
  final Function(Product) onPressed;
  final Function(Product) onEditPressed;
  final Function(Product) onToggleStatusPressed;
  final Function(Product) onDeletePressed;
  @override
  Widget build(BuildContext context) {
    //
    final currencySymbol = AppStrings.currencySymbol;

    //
    return VStack(
      [
        //
        HStack(
          [
            //
            Hero(
              tag: product.heroTag ?? product.id,
              child: CustomImage(imageUrl: product.photo)
                  .wh(Vx.dp48, Vx.dp48)
                  .box
                  .clip(Clip.antiAlias)
                  .roundedSM
                  .make(),
            ),

            //Details
            VStack(
              [
                //name
                product.name.text.lg.medium.maxLines(3).ellipsis.make(),
                //
                HStack(
                  [
                    //discount
                    product.showDiscount
                        ? CurrencyHStack(
                            [
                              currencySymbol.text.lineThrough.xs.make(),
                              product.price
                                  .currencyValueFormat()
                                  .text
                                  .lineThrough
                                  .lg
                                  .medium
                                  .make(),
                            ],
                          )
                        : UiSpacer.emptySpace(),
                    UiSpacer.horizontalSpace(space: 10),
                    //price
                    CurrencyHStack(
                      [
                        currencySymbol.text.lg.make(),
                        (product.showDiscount
                                ? product.discountPrice
                                : product.price)
                            .currencyValueFormat()
                            .text
                            .xl
                            .semiBold
                            .make(),
                      ],
                      crossAlignment: CrossAxisAlignment.end,
                    ),
                  ],
                ),
              ],
            ).px12().expand(),
          ],
        ).p8(),
        UiSpacer.divider(),
        //actions
        isLoading
            ? BusyIndicator(color: context.primaryColor).centered().p(20)
            : HStack(
                [
                  // Edit button
                  CustomButton(
                    height: 30,
                    icon: FlutterIcons.edit_fea,
                    onPressed: () => onEditPressed(product),
                    color: Colors.grey,
                  ),
                  // Toggle Status button
                  CustomButton(
                    height: 30,
                    icon: product.isActive != 1
                        ? FlutterIcons.check_ant
                        : FlutterIcons.close_ant,
                    onPressed: () => onToggleStatusPressed(product),
                    color:
                        product.isActive != 1 ? Colors.green : Colors.red[400],
                  ).px12(),
                  // Delete button
                  CustomButton(
                    loading: isLoading,
                    height: 30,
                    icon: FlutterIcons.delete_ant,
                    onPressed: () => onDeletePressed(product),
                    color: Colors.red,
                  ),
                ],
                alignment: MainAxisAlignment.spaceEvenly,
                crossAlignment: CrossAxisAlignment.center,
              ).centered().p8(),
        //
      ],
    ).onInkTap(() => onPressed(product)).card.make();
  }
}
