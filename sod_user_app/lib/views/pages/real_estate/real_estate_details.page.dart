import 'package:banner_carousel/banner_carousel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/real_estate.dart';
import 'package:sod_user/view_models/real_estate_details.vm.dart';
import 'package:sod_user/views/pages/real_estate/widgets/real_estate_bottom_sheet.dart';
import 'package:sod_user/views/pages/real_estate/widgets/real_estate_features.dart';
import 'package:sod_user/views/pages/real_estate/widgets/real_estate_overview.dart';
import 'package:sod_user/views/pages/real_estate/widgets/real_estate_vendor.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:sod_user/widgets/html_text_view.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstateDetailsPage extends StatelessWidget {
  RealEstateDetailsPage({
    required this.realEstate,
    Key? key,
  }) : super(key: key);

  final RealEstate realEstate;
  //
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RealEstateDetailsViewModel>.reactive(
      viewModelBuilder: () => RealEstateDetailsViewModel(context, realEstate),
      onViewModelReady: (model) => model.getRealEstateDetails(),
      builder: (context, model, child) {
        return BasePage(
          title: model.realEstate.name,
          showAppBar: true,
          showLeadingAction: true,
          elevation: 0,
          appBarColor: AppColor.faintBgColor,
          appBarItemColor: AppColor.primaryColor,
          showCart: true,
          body: CustomScrollView(
            slivers: [
              //product image
              SliverToBoxAdapter(
                child: BannerCarousel(
                  customizedBanners: [
                    if (model.checkedPhotos == null)
                      BusyIndicator().centered()
                    else if (model.checkedPhotos!.length == 0)
                      "No image found".text.xl.bold.makeCentered()
                    else
                      ...model.checkedPhotos!.map((photoPath) {
                        return Container(
                          child: CustomImage(
                            imageUrl: photoPath,
                            boxFit: BoxFit.contain,
                            canZoom: true,
                          ),
                        );
                      }).toList()
                  ],
                  customizedIndicators: IndicatorModel.animation(
                    width: 10,
                    height: 6,
                    spaceBetween: 2,
                    widthAnimation: 50,
                  ),
                  margin: EdgeInsets.zero,
                  height: context.percentHeight * 20,
                  width: context.percentWidth * 100,
                  activeColor: AppColor.primaryColor,
                  disableColor: Colors.grey.shade300,
                  animation: true,
                  borderRadius: 0,
                  indicatorBottom: true,
                ).box.color(AppColor.faintBgColor).make(),
              ),
              SliverToBoxAdapter(
                    child:  model.isBusy ? BusyIndicator() : VStack(
                      [
                        //Product header
                        RealEstateOverview(model.realEstate).p12(),
                        Divider(
                          color: Theme.of(context).dividerColor,
                          thickness: 10,
                        ),
                        5.heightBox,
                        "Feature".tr().text.xl.semiBold.make().px12(),
                        RealEstateFeatures(model.realEstate).px12(),
                        Divider(
                          color: Theme.of(context).dividerColor,
                          thickness: 10,
                        ),
                        5.heightBox,
                        //Product description
                        "Description".tr().text.xl.semiBold.make().px12(),
                        HtmlTextView(model.realEstate.description).px12(),
                        Divider(
                          color: Theme.of(context).dividerColor,
                          thickness: 10,
                        ),
                        5.heightBox,
                        "Location".tr().text.xl.semiBold.make().px12(),
                        SizedBox(
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: LatLng(model.realEstate.latitude,
                                    model.realEstate.longtitude),
                                zoom: 13),
                            scrollGesturesEnabled: true,
                            zoomGesturesEnabled: true,
                            zoomControlsEnabled: false,
                            markers: {
                              Marker(
                                  markerId: MarkerId("location"),
                                  position: LatLng(model.realEstate.latitude,
                                      model.realEstate.longtitude))
                            },
                          ).p12(),
                        ),
                        Divider(
                          color: Theme.of(context).dividerColor,
                          thickness: 10,
                        ),
                        5.heightBox,
                        "Price history".tr().text.xl.semiBold.make().px12(),
                        SizedBox(
                          height: 200,
                          child: model.realEstate.prices == null
                              ? BusyIndicator().centered()
                              : LineChart(
                                  LineChartData(
                                    gridData: FlGridData(show: true),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                        reservedSize: 45,
                                        showTitles: true,
                                      )),
                                      rightTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      topTitles: AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(
                                        showTitles: true,
                                        // reservedSize: 22,
                                        interval: 1,
                                        getTitlesWidget: (value, meta) {
                                          // Map x-axis values to readable dates
                                          if (value.toInt() <
                                              model.realEstate.prices!.length) {
                                            final price = model.realEstate
                                                .prices![value.toInt()];
                                            return (price.formattedDate ??
                                                    "${price.priceDate.day} / ${price.priceDate.month}")
                                                .text
                                                .make()
                                                .pOnly(top: 4);
                                          }
                                          return ''.text.make();
                                        },
                                      )),
                                    ),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: Border(
                                        left: const BorderSide(
                                            color: Colors.transparent),
                                        right: const BorderSide(
                                            color: Colors.transparent),
                                        top: const BorderSide(
                                            color: Colors.transparent),
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: model.realEstate.prices!
                                            .asMap()
                                            .entries
                                            .map(
                                              (entry) => FlSpot(
                                                entry.key.toDouble(),
                                                entry.value.price,
                                              ),
                                            )
                                            .toList(),
                                        isCurved: true,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        belowBarData: BarAreaData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                        ).p12(),
                        Divider(
                          color: Theme.of(context).dividerColor,
                          thickness: 10,
                        ),
                        model.realEstate.vendor == null ? BusyIndicator() :  RealEstateVendor(model.realEstate.vendor!).p12(),
                        40.heightBox,
                      ],
                    )
                        .box
                        .outerShadow3Xl
                        .color(context.theme.colorScheme.background)
                        .clip(Clip.antiAlias)
                        .make(),
                  ),
            ],
          ).box.color(AppColor.faintBgColor).make(),
          bottomSheet: RealEstateBottomSheet(model),
        );
      },
    );
  }
}
