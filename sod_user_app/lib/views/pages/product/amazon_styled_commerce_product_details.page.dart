import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/product_details.vm.dart';
import 'package:sod_user/views/pages/product/widgets/add_to_cart.btn.dart';
import 'package:sod_user/views/pages/product/widgets/amazon/frequently_bought_together.view.dart';
import 'package:sod_user/views/pages/product/widgets/buy_now.btn.dart';
import 'package:sod_user/views/pages/product/widgets/commerce_product_options.dart';
import 'package:sod_user/views/pages/product/widgets/product_fav.btn.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/qty_stepper.dart';
import 'package:sod_user/widgets/buttons/share.btn.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/cards/custom_image_slider.dart';
import 'package:sod_user/widgets/html_text_view.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import 'widgets/amazon/amazon_customer_product_reviews.dart';

class AmazonStyledCommerceProductDetailsPage extends StatelessWidget {
  AmazonStyledCommerceProductDetailsPage({
    required this.product,
    Key? key,
  }) : super(key: key);

  final Product product;

  //
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProductDetailsViewModel>.reactive(
      viewModelBuilder: () => ProductDetailsViewModel(context, product),
      onViewModelReady: (model) => model.getProductDetails(),
      builder: (context, model, child) {
        return BasePage(
          showAppBar: true,
          title: "Product details".tr(),
          showLeadingAction: true,
          // elevation: 0,
          // appBarColor: Colors.transparent,
          // appBarItemColor: AppColor.primaryColor,
          isLoading: model.isBusy || model.busy(model.product),
          showCart: true,
          body: SmartRefresher(
            enablePullDown: true,
            controller: model.refreshController,
            onRefresh: () {
              model.refreshController.refreshCompleted();
              model.getProductDetails();
            },
            child: SingleChildScrollView(
              child: VStack(
                [
                  //visit vendor
                  VStack(
                    [
                      "Visit the %s Store"
                          .tr()
                          .fill([model.product.vendor.name])
                          .text
                          .color(AppColor.primaryColor)
                          .size(13)
                          .medium
                          .make()
                          .onInkTap(model.openVendorDetails),
                      UiSpacer.vSpace(5),
                      //product name
                      model.product.name.text.size(17).semiBold.make(),
                      UiSpacer.vSpace(5),
                      //rating
                      HStack(
                        [
                          VxRating(
                            size: 20,
                            maxRating: 5.0,
                            value: model.product.rating ?? 0,
                            isSelectable: false,
                            onRatingUpdate: (value) {},
                            selectionColor: AppColor.ratingColor,
                          ),
                          UiSpacer.hSpace(10),
                          "(${model.product.reviewsCount})"
                              .text
                              .color(AppColor.primaryColor)
                              .make(),
                        ],
                      ).onTap(() => scrollTo(model.productReviewsKey)),
                    ],
                  ).p20(),
                  //
                  Stack(
                    children: [
                      //images
                      if (model.checkedPhotos == null)
                        Container(
                          height: context.percentHeight * 32,
                          child: BusyIndicator().centered())
                      else if (model.checkedPhotos!.isEmpty)
                        Image.asset(
                          AppImages.appLogo,
                          fit: BoxFit.contain,
                          height: context.percentHeight * 32,
                        )
                      else
                        CustomImageSlider(
                          model.checkedPhotos as List<String>,
                          height: context.percentHeight * 32,
                          viewportFraction: 1.0,
                          autoplay: false,
                          boxFit: BoxFit.scaleDown,
                        ).py8(),
                      //fav
                      Positioned(
                        child: ProductFavButton(model: model),
                        bottom: 15,
                        left: !Utils.isArabic ? 15 : null,
                        right: !Utils.isArabic ? null : 15,
                      ),
                      //share link
                      Positioned(
                        child: ShareButton(model: model),
                        top: 0,
                        left: Utils.isArabic ? 5 : null,
                        right: Utils.isArabic ? null : 5,
                      )
                    ],
                  ),
                  //
                  UiSpacer.divider(height: 4, thickness: 5).py12(),
                  //price
                  HStack(
                    [
                      "Price:".tr().text.gray600.lg.make(),
                      UiSpacer.hSpace(model.product.showDiscount ? 6 : 4),
                      if (model.product.showDiscount)
                        "${AppStrings.currencySymbol} ${model.product.price}"
                            .currencyFormat()
                            .text
                            .color(AppColor.primaryColor)
                            .lg
                            .lineThrough
                            .semiBold
                            .make(),
                      if (model.product.showDiscount) UiSpacer.hSpace(8),
                      "${AppStrings.currencySymbol} ${model.product.sellPrice}"
                          .currencyFormat()
                          .text
                          .color(AppColor.primaryColor)
                          .xl3
                          .bold
                          .make()
                          .expand(),
                    ],
                  ).py4().px20(),
                  // UiSpacer.vSpace(),
                  //available stock
                  CustomVisibilty(
                    visible: model.product.hasStock,
                    child: VStack(
                      [
                        //options
                        // UiSpacer.divider(height: 4, thickness: 5).py12(),
                        CommerceProductOptions(model),
                        // UiSpacer.divider(height: 2, thickness: 1).py12(),
                        //action buttons
                        UiSpacer.vSpace(15),
                        //qty selector
                        HStack(
                          [
                            "Quantity".tr().text.semiBold.lg.make().expand(),
                            UiSpacer.hSpace(5),
                            QtyStepper(
                              defaultValue: model.product.selectedQty,
                              min: 1,
                              max: (model.product.availableQty != null &&
                                      model.product.availableQty! > 0)
                                  ? model.product.availableQty!
                                  : 20,
                              disableInput: true,
                              onChange: model.updatedSelectedQty,
                              actionIconColor: AppColor.primaryColor,
                            )
                                .box
                                .border(
                                  color: AppColor.primaryColor,
                                )
                                .roundedSM
                                .p1
                                .make(),
                          ],
                        ).px20(),
                        UiSpacer.vSpace(12),
                        //add to cart
                        AddToCartButton(model).wFull(context).px20(),
                        UiSpacer.vSpace(10),
                        //buy now
                        BuyNowButton(model).wFull(context).px20(),
                      ],
                    ),
                  ),
                  //no stock
                  CustomVisibilty(
                    visible: !model.product.hasStock,
                    child: "No stock"
                        .tr()
                        .text
                        .white
                        .makeCentered()
                        .p8()
                        .box
                        .red500
                        .roundedSM
                        .make()
                        .p8(),
                  ).px20(),

                  UiSpacer.divider(height: 2, thickness: 1).py12(),
                  //frequently bought together
                  FrequentlyBoughtTogetherView(model.product),
                  //product details
                  HtmlTextView(model.product.description).px20(),
                  UiSpacer.divider(height: 2, thickness: 1).py12(),

                  VStack(
                    [
                      // //product header
                      // CommerceProductDetailsHeader(
                      //   product: model.product,
                      //   model: model,
                      // ),
                      // UiSpacer.divider(),
                      // //price
                      // CommerceProductPrice(model: model),
                      // UiSpacer.divider(),
                      // //options
                      // CommerceProductOptions(model),
                      // UiSpacer.divider(),
                      // //qty
                      // CommerceProductQtyEntry(model: model),
                      // UiSpacer.divider(),
                      // //vendor/seller details
                      // CommerceSellerTile(model: model),
                      // UiSpacer.divider().pOnly(bottom: Vx.dp12),

                      // //product details
                      // HtmlTextView(model.product.description),

                      // //similar products
                      // SimilarCommerceProducts(product),
                      //customer reviews widget
                      UiSpacer.vSpace(20),
                      AmazonCustomerProductReview(
                        product: model.product,
                        key: model.productReviewsKey,
                      ),
                    ],
                  ).px20(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //
  scrollTo(GlobalKey viewKey) {
    if (viewKey.currentContext != null) {
      Scrollable.ensureVisible(viewKey.currentContext!);
    }
  }
}
