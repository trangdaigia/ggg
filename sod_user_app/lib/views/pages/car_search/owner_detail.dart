import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/view_models/car_rental.view_model.dart';
import 'package:sod_user/views/pages/car_search/car_rental_card.dart';
import 'package:sod_user/views/pages/car_search/car_search.page.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/custom_image.view.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:sod_user/widgets/states/loading.shimmer.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class OwnerDetailPage extends StatefulWidget {
  OwnerDetailPage({
    super.key,
    required this.model,
    required this.owner,
    required this.dropOffLocation,
    required this.pickUpLocation,
    required this.bottomSheet,
    required this.selectedRoute,
  });
  final User owner;
  final CarRentalViewModel model;
  final ValueNotifier<String> dropOffLocation;
  final ValueNotifier<String> pickUpLocation;
  ValueNotifier<Widget> bottomSheet;
  ValueNotifier<int> selectedRoute;
  @override
  State<OwnerDetailPage> createState() => _OwnerDetailPageState();
}

class _OwnerDetailPageState extends State<OwnerDetailPage> {
  final controller = CarouselSliderController();
  int activeIndex = 0;
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<CarRentalViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => widget.model,
        onViewModelReady: (viewModel) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            viewModel.ownerVehicle.clear();
            await widget.model.getOwnerVehicle(
                widget.model.type == 'xe tự lái' ? 0 : 1, widget.owner.id);
          });
        },
        builder: (context, viewModel, child) {
          return BasePage(
            showAppBar: true,
            showLeadingAction: true,
            leading: Container(
              margin: EdgeInsets.all(5),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey),
              ),
              child: Icon(
                Icons.close,
                color: Colors.black,
              ),
            ).onInkTap(() {
              Navigator.pop(context);
            }),
            title: 'Tài khoản'.tr(),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CustomImage(
                    imageUrl: widget.owner.photo,
                  ).box.roundedFull.shadowSm.make().wh(100, 100),
                  '${widget.owner.name}'.text.semiBold.lg.make().pOnly(top: 10),
                  'Ngày tham gia: ${DateFormat('dd/MM/yyyy').format(widget.owner.createdAt!)}'
                      .text
                      .make()
                      .pOnly(top: 10),
                  Container(
                    padding: EdgeInsets.all(5),
                    width: MediaQuery.of(context).size.width / 3,
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_car, color: Colors.green),
                        '${widget.owner.trip} ${'Ride'.tr().toLowerCase()}'
                            .text
                            .lg
                            .semiBold
                            .make(),
                      ],
                    ),
                  ).pOnly(top: 10),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green.shade50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            'Response rate'
                                .tr()
                                .text
                                .color(Colors.grey)
                                .center
                                .make()
                                .pOnly(bottom: 10),
                            '${widget.owner.responseRate}'.text.bold.make()
                          ],
                        ).w(MediaQuery.of(context).size.width / 4),
                        SizedBox(width: 16),
                        Column(
                          children: [
                            'Agreement rate'
                                .tr()
                                .text
                                .color(Colors.grey)
                                .center
                                .make()
                                .pOnly(bottom: 10),
                            '${widget.owner.rateOfAgreement}'.text.bold.make()
                          ],
                        ).w(MediaQuery.of(context).size.width / 4),
                        SizedBox(width: 16),
                        Column(
                          children: [
                            'Response within'
                                .tr()
                                .text
                                .color(Colors.grey)
                                .center
                                .make()
                                .pOnly(bottom: 10),
                            '${widget.owner.feedbackIn} ${'min'.tr()}'
                                .text
                                .bold
                                .make()
                          ],
                        ).w(MediaQuery.of(context).size.width / 4),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.model.type == 'xe tự lái'
                          ? '${'Self drive'.tr()} (${viewModel.ownerVehicle.length} xe)'
                              .text
                              .xl
                              .semiBold
                              .make()
                          : '${'With driver'.tr()} (${viewModel.ownerVehicle.length} xe)'
                              .text
                              .xl
                              .semiBold
                              .make(),
                      IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                                barrierColor: Colors.transparent,
                                enableDrag: false,
                                isScrollControlled: true,
                                useRootNavigator: true,
                                context: context,
                                useSafeArea: true,
                                builder: (context) => BasePage(
                                      showAppBar: true,
                                      showLeadingAction: true,
                                      leading: Container(
                                        margin: EdgeInsets.all(5),
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          color: Colors.black,
                                        ),
                                      ).onInkTap(() {
                                        Navigator.pop(context);
                                      }),
                                      title: 'Tài khoản'.tr(),
                                      body: Container(
                                          margin: EdgeInsets.symmetric(
                                              vertical: 5, horizontal: 10),
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height -
                                              150,
                                          child: CustomListView(
                                              separator: 10,
                                              canRefresh: true,
                                              refreshController: viewModel
                                                  .refreshOwnerVehicleController,
                                              onRefresh: () => widget.model
                                                  .getOwnerVehicle(
                                                      widget.model.type ==
                                                              'xe tự lái'
                                                          ? 0
                                                          : 1,
                                                      widget.owner.id),
                                              isLoading: viewModel.isBusy,
                                              dataSet: viewModel.ownerVehicle,
                                              hasError: viewModel.hasError,
                                              errorWidget:
                                                  LoadingError(onrefresh: () {
                                                widget.model.getOwnerVehicle(
                                                    widget.model.type ==
                                                            'xe tự lái'
                                                        ? 0
                                                        : 1,
                                                    widget.owner.id);
                                              }),
                                              emptyWidget: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Center(
                                                    heightFactor: 40,
                                                    child: Text(
                                                      'no_data'.tr(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              itemBuilder: (context, index) {
                                                return CarRentalCard(
                                                  index: index,
                                                  dropOffLocation:
                                                      widget.dropOffLocation,
                                                  selectedRoute:
                                                      widget.selectedRoute,
                                                  bottomSheet:
                                                      widget.bottomSheet,
                                                  pickUpLocation:
                                                      widget.pickUpLocation,
                                                  model: viewModel,
                                                  carRental: viewModel
                                                      .ownerVehicle[index],
                                                );
                                              })),
                                    ));
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 15,
                          ))
                    ],
                  ).pOnly(top: 20, bottom: 5),
                  viewModel.ownerVehicle.isNotEmpty
                      ? SizedBox(
                          height: 450,
                          width: double.infinity,
                          child: CarouselSlider.builder(
                              carouselController: controller,
                              itemCount: viewModel.ownerVehicle.length,
                              itemBuilder: (context, index, realIndex) {
                                return CarRentalCard(
                                  index: index,
                                  dropOffLocation: widget.dropOffLocation,
                                  selectedRoute: widget.selectedRoute,
                                  bottomSheet: widget.bottomSheet,
                                  pickUpLocation: widget.pickUpLocation,
                                  model: widget.model,
                                  carRental: viewModel.ownerVehicle[index],
                                );
                              },
                              options: CarouselOptions(
                                  viewportFraction: 1.0,
                                  disableCenter: true,
                                  enableInfiniteScroll: false,
                                  enlargeCenterPage: true,
                                  onPageChanged: (index, reason) =>
                                      setState(() => activeIndex = index))),
                        ).pOnly(bottom: 10)
                      : LoadingShimmer(),
                ],
              ).centered().pSymmetric(h: 15, v: 15),
            ),
          );
        });
  }
}
