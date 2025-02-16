import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/shared_ride/shared_ride_details.page.dart';
import 'package:sod_user/widgets/states/loading.shimmer.dart';
import 'package:sod_user/widgets/states/search.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchshareRideResultPage extends StatefulWidget {
  final SharedRideViewModel model;
const SearchshareRideResultPage({Key? key, required this.model})
      : super(key: key);

  @override
  State<SearchshareRideResultPage> createState() =>
      SearchshareRideResultPageState();
}

class SearchshareRideResultPageState extends State<SearchshareRideResultPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SharedRideViewModel>.reactive(
      disposeViewModel: false,
      viewModelBuilder: () => widget.model,
      onViewModelReady: (model) {
        print('type: ${widget.model.type}');
        print(widget.model.date.text);
        print(widget.model.departureCity);
        print(widget.model.destinationCity);
        print(int.tryParse(widget.model.number_of_seat.text));
        print(widget.model.type);

        model.searchMap.addAll({
          "status": "new",
          "is_search": "1",
          "history": "0",
          "start_date": widget.model.date.text,
          "departure_city": widget.model.departureCity,
          "destination_city": widget.model.destinationCity,
          "number_of_seat": int.tryParse(widget.model.number_of_seat.text),
          "type": widget.model.type,
          "width": int.tryParse(widget.model.widthController.text),
          "height": int.tryParse(widget.model.heightController.text),
          "length": int.tryParse(widget.model.lengthController.text),
          "weight": int.tryParse(widget.model.weightController.text)
        });
        Map<String, dynamic> tempSearch = model.searchMap;
        tempSearch.addAll({'sort_time': 'asc'});
      model.getSharedRides(tempSearch);
      },
      builder: (context, model, child) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            key: scaffoldKey,
            endDrawer: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
              color: Colors.white,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.filter_alt),
                      Text("Filter by".tr()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("Price".tr(),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Map<String, dynamic> tempSearch = model.searchMap;
                      tempSearch.addAll({'sort_price': 'desc'});
                      model.updateFilterOption("descendingPrice");
                      model.getSharedRides(tempSearch);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: model.chooseFilterOption == "descendingPrice"
                            ? AppColor.primaryColor
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value:
                                model.chooseFilterOption == "descendingPrice",
                            onChanged: (value) {
                              Map<String, dynamic> tempSearch = model.searchMap;
                              tempSearch.addAll({'sort_price': 'desc'});
                              model.updateFilterOption("descendingPrice");
                              model.getSharedRides(tempSearch);
                            },
                          ),
                          Text("Descending".tr()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Map<String, dynamic> tempSearch = model.searchMap;
                      tempSearch.addAll({'sort_price': 'asc'});
                      model.updateFilterOption("ascendingPrice");
                      model.getSharedRides(tempSearch);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: model.chooseFilterOption == "ascendingPrice"
                            ? AppColor.primaryColor
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                            value: model.chooseFilterOption == "ascendingPrice",
                            onChanged: (value) {
                              Map<String, dynamic> tempSearch = model.searchMap;
                              tempSearch.addAll({'sort_price': 'asc'});
                              model.updateFilterOption("ascendingPrice");
                              model.getSharedRides(tempSearch);
                            },
                          ),
                          Text("Ascending".tr()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Start time".tr(),
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Map<String, dynamic> tempSearch = model.searchMap;
                      tempSearch.addAll({'sort_time': 'asc'});
                      model.updateFilterOption("earliest");
                      model.getSharedRides(tempSearch);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: model.chooseFilterOption == "earliest"
                            ? AppColor.primaryColor
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                              value: model.chooseFilterOption == "earliest",
                              onChanged: (value) {
                                Map<String, dynamic> tempSearch =
                                    model.searchMap;
                                tempSearch.addAll({'sort_time': 'asc'});
                                model.updateFilterOption("earliest");
                                model.getSharedRides(tempSearch);
                              }),
                          Text("Earliest".tr()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Map<String, dynamic> tempSearch = model.searchMap;
                      tempSearch.addAll({'sort_time': 'desc'});
                      model.updateFilterOption("latest");
                      model.getSharedRides(tempSearch);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: model.chooseFilterOption == "latest"
                            ? AppColor.primaryColor
                            : Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          Checkbox(
                              value: model.chooseFilterOption == "latest",
                              onChanged: (value) {
                                Map<String, dynamic> tempSearch =
                                    model.searchMap;
                                tempSearch.addAll({'sort_time': 'desc'});
                                model.updateFilterOption("latest");
                                model.getSharedRides(tempSearch);
                              }),
                          Text("Latest".tr()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              actions: [
                IconButton(
                  onPressed: () => scaffoldKey.currentState!.openEndDrawer(),
                  icon: Icon(Icons.filter_alt),
                ),
              ],
              title: Text("Ride list".tr()),
              backgroundColor: AppColor.primaryColor,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColor.primaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: widget.model.departureCity!.text.bold.xl
                                  .white.center.ellipsis
                                  .make(),
                            ),
                            const Icon(Icons.arrow_right, color: Colors.white),
                            Expanded(
                              child: widget.model.destinationCity!.text.bold.xl
                                  .white.center.ellipsis
                                  .make(),
                            ),
                          ],
                        ),
                        UiSpacer.vSpace(10),
                        if (widget.model.type == "person") ...[
                          "${widget.model.date.text}, ${widget.model.number_of_seat.text} ${'Person'.tr()}"
                              .text
                              .white
                              .lg
                              .bold
                              .make(),
                        ],
                        if (widget.model.type == "package") ...[
                          "${widget.model.date.text}, ${"Width".tr()}: ${widget.model.widthController.text} ${'Cm'.tr()}, ${"Height".tr()}: ${widget.model.heightController.text} ${'Cm'.tr()}, ${"Length".tr()}: ${widget.model.lengthController.text} ${'Cm'.tr()}, ${"Weight".tr()}: ${widget.model.weightController.text} ${'Kg'.tr()}"
                              .text
                              .white
                              .lg
                              .bold
                              .center
                              .make(),
                        ],
                        "${model.bookableShareRides.length} ${'Ride'.tr()}"
                            .text
                            .white
                            .lg
                            .bold
                            .make(),
                      ],
                    ),
                  ),
                  model.busy(model.bookableShareRides)
                      ? LoadingShimmer()
                      : model.bookableShareRides.isEmpty
                          ? EmptySearch()
                          : SizedBox(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.7,
                              child: SmartRefresher(
                                enablePullDown: true,
                                enablePullUp: false,
                                controller: model.refreshController,
                                onRefresh: () =>
                                    model.getSharedRides(model.searchMap),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics:
                                      const AlwaysScrollableScrollPhysics(),
                                  itemCount: model.bookableShareRides.length,
                                  itemBuilder: (context, index) {
                                    final currentRide =
                                        model.bookableShareRides[index];
                                    return GestureDetector(
                                      onTap: () {
                                        context.nextPage(
                                          SharedRideDetailsPage(
                                              type: "search",
                                              sharedRide: currentRide,
                                              model: model),
                                        );
                                      },
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
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(20)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 15),
                                          child: Column(
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[300],
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(20)),
                                                ),
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.calendar_today),
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      currentRide.startDate!,
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          currentRide
                                                              .departureName!
                                                              .text
                                                              .bold
                                                              .black
                                                              .make(),
                                                          const SizedBox(
                                                              height: 5),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(3),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .blue[300],
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          10)),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const Icon(Icons
                                                                    .access_time),
                                                                const SizedBox(
                                                                    width: 5),
                                                                Text(currentRide
                                                                    .startTime!),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Icon(Icons.arrow_right),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 10),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          currentRide
                                                              .destinationName!
                                                              .text
                                                              .bold
                                                              .black
                                                              .make(),
                                                          const SizedBox(
                                                              height: 5),
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(3),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .blue[300],
                                                              borderRadius:
                                                                  const BorderRadius
                                                                      .all(
                                                                      Radius.circular(
                                                                          10)),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                const Icon(Icons
                                                                    .access_time),
                                                                const SizedBox(
                                                                    width: 5),
                                                                Text(currentRide
                                                                    .endTime!),
                                                              ],
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            child:
                                                                CachedNetworkImage(
                                                              imageUrl:
                                                                  currentRide
                                                                      .user!
                                                                      .photo,
                                                              height: 40,
                                                              width: 40,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 5),
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              currentRide.user!
                                                                  .name.text
                                                                  .textStyle(
                                                                      TextStyle(
                                                                          fontSize:
                                                                              12))
                                                                  .bold
                                                                  .black
                                                                  .make(),
                                                              Row(
                                                                children: [
                                                                  Text(
                                                                    double.parse(currentRide
                                                                            .user!
                                                                            .rating!)
                                                                        .ceil()
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .yellow),
                                                                  ),
                                                                  Icon(
                                                                      Icons
                                                                          .star,
                                                                      size: 13,
                                                                      color: Colors
                                                                          .yellow),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    VStack(
                                                      [
                                                        "${'Trip price'.tr()}: ${Utils.formatCurrencyVND(double.parse(currentRide.price.toString()))}"
                                                            .text
                                                            .black
                                                            .bold
                                                            .make(),
                                                        if (currentRide.type ==
                                                            "package") ...[
                                                          "${'Package price'.tr()}: ${Utils.formatCurrencyVND(double.parse(currentRide.package!.price.toString()))}"
                                                              .text
                                                              .black
                                                              .bold
                                                              .make(),
                                                        ],
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
