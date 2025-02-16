import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/shared_ride.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/search_share_ride.page.dart';
import 'package:sod_user/views/pages/shared_ride/shared_ride_details.page.dart';
import 'package:sod_user/widgets/states/loading.shimmer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SharedRidePage extends StatefulWidget {
  const SharedRidePage({Key? key}) : super(key: key);

  @override
  State<SharedRidePage> createState() => _SharedRidePageState();
}

class _SharedRidePageState extends State<SharedRidePage> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SharedRideViewModel>.reactive(
      viewModelBuilder: () => SharedRideViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => context.nextPage(SearchRidePage()),
                icon: Icon(Icons.arrow_back),
              ),
              title: Text("Share Ride".tr()),
              backgroundColor: AppColor.primaryColor,
            ),
            body: SafeArea(
              child: Container(
                margin: const EdgeInsets.only(top: 10),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 3),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20)),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: TabBar(
                        splashBorderRadius: BorderRadius.circular(20),
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11),
                        unselectedLabelStyle: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11),
                        indicator: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                        ),
                        dividerColor: Colors.transparent,
                        labelPadding: EdgeInsets.zero,
                        indicatorPadding: EdgeInsets.symmetric(horizontal: -10),
                        labelColor: Colors.black,
                        unselectedLabelColor: Colors.blue,
                        tabs: [
                          Tab(text: "Searched ride".tr()),
                          Tab(text: "Posting ride".tr()),
                          Tab(text: "Posted ride".tr()),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          mySharedRideListWidget(model.searchRefreshController,
                              model.bookedSharedRides, model),
                          mySharedRideListWidget(
                              model.nonExpiredRefreshController,
                              model.nonExpiredsharedRides,
                              model),
                          mySharedRideListWidget(model.expiredRefreshController,
                              model.expiredsharedRides, model),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  mySharedRideListWidget(RefreshController controller,
      List<SharedRide> rideList, SharedRideViewModel model) {
    return model.busy(model.sharedRides)
        ? LoadingShimmer()
        : rideList.isEmpty
            ? UiSpacer.emptySpace()
            : SizedBox(
                child: SmartRefresher(
                  enablePullDown: true,
                  enablePullUp: false,
                  controller: controller,
                  onRefresh: model.initialise,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: rideList.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => context.nextPage(SharedRideDetailsPage(
                          sharedRide: rideList[index],
                          model: model,
                          type: rideList == model.bookedSharedRides
                              ? "history"
                              : "my_ride",
                        )),
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 7.5, horizontal: 15),
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey[350]!,
                                blurRadius: 40,
                                spreadRadius: 1,
                                offset: const Offset(0, 15),
                              ),
                            ],
                            color: Colors.white,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(20)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[300],
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_today),
                                      const SizedBox(width: 5),
                                      Text(
                                        rideList[index].startDate!,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                                height: 60,
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  rideList[index]
                                                      .departureName!,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )),
                                            const SizedBox(height: 5),
                                            Container(
                                              padding: const EdgeInsets.only(left: 10, top: 5, right: 15, bottom: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[300],
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.access_time),
                                                  const SizedBox(width: 5),
                                                  Text(rideList[index]
                                                      .startTime!),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.arrow_right_alt_rounded),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              height: 60,
                                              alignment: Alignment.topLeft,
                                              child: Text(rideList[index].destinationName!,
                                                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                              )
                                            ),
                                            const SizedBox(height: 5),
                                            Container(
                                              padding: EdgeInsets.only(left: 10, top: 5, right: 15, bottom: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[300],
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(10)),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(Icons.access_time),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                      rideList[index].endTime!),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                const Divider(color: Colors.grey),
                                Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: VStack(
                                    [
                                      if (rideList[index].type == "person") ...[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 3),
                                          child: HStack(
                                            alignment:
                                                MainAxisAlignment.spaceAround,
                                            [
                                              Expanded(
                                                  child: "Number of seat"
                                                      .tr()
                                                      .text
                                                      .bold
                                                      .black
                                                      .make()),
                                              "${rideList[index].numberOfSeat} ${"spot".tr()}"
                                                  .text
                                                  .bold
                                                  .black
                                                  .make(),
                                            ],
                                          ),
                                        ),
                                        UiSpacer.divider(color: Colors.black),
                                      ],
                                      if (rideList[index].type ==
                                          "package") ...[
                                        HStack(
                                          alignment:
                                              MainAxisAlignment.spaceAround,
                                          [
                                            Expanded(
                                                child: "Package price"
                                                    .tr()
                                                    .text
                                                    .bold
                                                    .black
                                                    .make()),
                                            Utils.formatCurrencyVND(
                                                    double.parse(rideList[index]
                                                            .package!
                                                            .price ??
                                                        "0"))
                                                .text
                                                .bold
                                                .black
                                                .make(),
                                          ],
                                        ).py(3),
                                        UiSpacer.divider(color: Colors.black),
                                      ],
                                      HStack(
                                        alignment:
                                            MainAxisAlignment.spaceAround,
                                        [
                                          Expanded(
                                              child: 'Trip price'
                                                  .tr()
                                                  .text
                                                  .bold
                                                  .black
                                                  .make()),
                                          Utils.formatCurrencyVND(double.parse(
                                                  rideList[index]
                                                      .price
                                                      .toString()))
                                              .text
                                              .bold
                                              .black
                                              .make(),
                                        ],
                                      ).py(3),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
  }
}
