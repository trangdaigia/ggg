import 'dart:math';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geolocator/geolocator.dart';
import 'package:html/parser.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/tax_order_location.history.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/delivery_address/delivery_addresses.vm.dart';
import 'package:sod_user/view_models/main_search.vm.dart';
import 'package:sod_user/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:sod_user/views/pages/delivery_address/delivery_addresses.page.dart';
import 'package:sod_user/views/pages/taxi/taxi.page.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/arrow_indicator.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/list_items/delivery_address.list_item.dart';
import 'package:sod_user/widgets/list_items/dynamic_vendor.list_item.dart';
import 'package:sod_user/widgets/states/delivery_address.empty.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:sod_user/widgets/states/search.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:supercharged/supercharged.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../../../widgets/custom_list_view.dart';

class SavedLocationPage extends StatefulWidget {
  SavedLocationPage(this.vendor, this.taxiNewOrderViewModel, {Key? key})
      : super(key: key);
  final VendorType vendor;
  final NewTaxiOrderLocationEntryViewModel taxiNewOrderViewModel;

  @override
  State<SavedLocationPage> createState() => _SavedLocationPageState();
}

class _SavedLocationPageState extends State<SavedLocationPage> {
  final random = new Random();

  late CustomListView IconList;

  late CustomListView NewIconList;

  late CustomListView AddressList;

  late CustomListView NewAddressList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.theme.colorScheme.surface,
      body: NestedScrollView(
          floatHeaderSlivers: true,
          headerSliverBuilder: (BuildContext context, bool innerBoxScrolled) {
            return <Widget>[
              SliverPersistentHeader(
                delegate: MySliverAppBar(
                    expandedHeight: 250,
                    vendor: this.widget.vendor,
                    taxiNewOrdVM: widget.taxiNewOrderViewModel),
                pinned: true,
              ),
            ];
          },
          body: ViewModelBuilder<DeliveryAddressesViewModel>.reactive(
              viewModelBuilder: () => DeliveryAddressesViewModel(context),
              onViewModelReady: (vm) => vm.initialise(),
              builder: (context, vm, child) {
                return Container(
                    child: VStack(
                  [
                    //Address List
                    AddressList = CustomListView(
                      refreshController: vm.refreshController,
                      padding: EdgeInsets.fromLTRB(8, 40, 8, 0),
                      dataSet: vm.deliveryAddresses
                          .where((e) => e.address.isNotNullOrEmpty)
                          .take(3)
                          .toList(),
                      isLoading: vm.busy(vm.deliveryAddresses),
                      emptyWidget: EmptyDeliveryAddress(),
                      errorWidget: LoadingError(
                        onrefresh: vm.fetchDeliveryAddresses,
                      ),
                      itemBuilder: (context, index) {
                        final deliveryAddress = AddressList.dataSet[index];
                        return DeliveryAddressListItem(
                          delete: false,
                          action: deliveryAddress.address!.isNotEmpty,
                          deliveryAddress: deliveryAddress,
                          borderColor: Colors.grey.shade300,
                          onEditPressed: () {
                            widget.taxiNewOrderViewModel.onDestinationSelected(
                                TaxiOrderLocationHistory(
                                    latitude: deliveryAddress.latitude!,
                                    longitude: deliveryAddress.longitude!,
                                    address: deliveryAddress.address!,
                                    name: deliveryAddress.name!));
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          UiSpacer.verticalSpace(space: 5),
                    ),
                    //
                    ListTile(
                      title: "Saved Places".tr().text.xl.make(),
                      trailing: ArrowIndicator(20).onTap(
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DeliveryAddressesPage()),
                        ),
                      ),
                    ),
                    //Icon list
                    SizedBox(
                        height: 130,
                        child: HStack(
                            alignment: MainAxisAlignment.center,
                            crossAlignment: CrossAxisAlignment.center,
                            [
                              IconList = CustomListView(
                                  scrollDirection: Axis.horizontal,
                                  refreshController: vm.refreshController,
                                  dataSet: vm.deliveryAddresses,
                                  // .takeWhile(
                                  //     (value) => value.address.isNotNullOrEmpty)
                                  // .toList(),
                                  isLoading: vm.busy(vm.deliveryAddresses),
                                  emptyWidget: SizedBox.shrink(),
                                  errorWidget: LoadingError(
                                    onrefresh: vm.fetchDeliveryAddresses,
                                  ),
                                  itemBuilder: (context, index) {
                                    final IconData icon;
                                    final address = vm.deliveryAddresses[index];
                                    switch (address.name
                                        ?.toString()
                                        .toLowerCase()) {
                                      case "home":
                                        icon = FlutterIcons.home_ant;
                                        break;
                                      case "work":
                                        icon = FlutterIcons.work_mdi;
                                        break;
                                      default:
                                        icon = FlutterIcons.heart_ant;
                                    }
                                    return Container(
                                      padding: EdgeInsets.all(5),
                                      width: 80,
                                      child: VStack(
                                          crossAlignment:
                                              CrossAxisAlignment.center,
                                          spacing: 10,
                                          [
                                            Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    shape: CircleBorder(),
                                                    padding: EdgeInsets.all(20),
                                                  ),
                                                  onPressed: (() {
                                                    widget.taxiNewOrderViewModel
                                                        .onDestinationSelected(
                                                            TaxiOrderLocationHistory(
                                                                latitude: address
                                                                    .latitude!,
                                                                longitude: address
                                                                    .longitude!,
                                                                address: address
                                                                    .address!,
                                                                name: address
                                                                    .name!));
                                                  }),
                                                  child: Icon(
                                                    icon,
                                                    size: 20,
                                                  ),
                                                ),
                                                //if user didn't saved address yet
                                                Visibility(
                                                  visible: address
                                                      .address.isNullOrEmpty,
                                                  child: Icon(Icons.add,
                                                          color: Colors.blue)
                                                      .box
                                                      .white
                                                      .roundedFull
                                                      .make()
                                                      .onInkTap(() {
                                                    vm.editDeliveryAddress(
                                                        address);
                                                  }),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "${address.name?.toString().toUpperCase()}",
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ]),
                                    ).onInkTap(() {
                                      address.address.isNullOrEmpty
                                          ? vm.editDeliveryAddress(address)
                                          : widget.taxiNewOrderViewModel
                                              .onDestinationSelected(
                                                  TaxiOrderLocationHistory(
                                                      latitude:
                                                          address.latitude!,
                                                      longitude:
                                                          address.longitude!,
                                                      address: address.address!,
                                                      name: address.name!));
                                    });
                                  }),
                              UiSpacer.hSpace(20),
                              ListView(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(5),
                                    width: 80,
                                    child: VStack(
                                      crossAlignment: CrossAxisAlignment.center,
                                      spacing: 10,
                                      [
                                        Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: CircleBorder(),
                                                padding: EdgeInsets.all(20),
                                              ),
                                              onPressed: () {
                                                vm.newDeliveryAddressPressed();
                                              },
                                              child: Icon(
                                                  FlutterIcons.heart_ant,
                                                  size: 20),
                                            ),
                                            Icon(Icons.add, color: Colors.blue)
                                                .box
                                                .white
                                                .roundedFull
                                                .make(),
                                          ],
                                        ),
                                        Text(
                                            "${"New".tr().toString().toUpperCase()}",
                                            overflow: TextOverflow.ellipsis),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            ])).scrollHorizontal()
                  ],
                ));
              })),
    );
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final VendorType vendor;
  final NewTaxiOrderLocationEntryViewModel taxiNewOrdVM;
  MySliverAppBar(
      {required this.expandedHeight,
      required this.vendor,
      required this.taxiNewOrdVM});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var searchBarOffset = expandedHeight - shrinkOffset - 20;
    final proportion = 2 - (expandedHeight / searchBarOffset);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        Opacity(
          opacity: percent,
          child: AppBar(
            centerTitle: false,
            automaticallyImplyLeading: false,
            leading: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                style: ButtonStyle(),
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            toolbarHeight: expandedHeight,
            backgroundColor: AppColor.primaryColor,
            actions: [
              Align(
                heightFactor: 35,
                alignment: Alignment.topRight,
                child: TextButton.icon(
                        onPressed: taxiNewOrdVM.handleChooseOnMap,
                        style: TextButton.styleFrom(
                            foregroundColor: context.backgroundColor,
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20))),
                        icon: Icon(Icons.map_outlined),
                        label: "Map".tr().text.scale(1).make())
                    .onInkTap(() {
                  taxiNewOrdVM.handleChooseOnMap;
                }),
              ).px12(),
            ],
            title: Wrap(
              direction: Axis.vertical,
              verticalDirection: VerticalDirection.down,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          "Travel".tr().text.semiBold.xl2.color(Colors.white).make().py(4),
                          "Wherever you're going, let's get you there!"
                              .tr()
                              .text
                              .color(Colors.white)
                              .xl
                              .maxLines(3)
                              .overflow(TextOverflow.clip)
                              .make()
                        ],
                      ),
                    ).px12(),
                    Image.asset(
                      "assets/images/icons/taxi.png",
                      width: 120,
                      height: 120,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
        // nền dưới cho nút ấn where to?, tạo cảm nó nằm giữa appbar và body
        Positioned(
            left: 0,
            right: 0,
            bottom: -5,
            height: 30,
            child: Container(
              color: Colors.white,
            )),
        (percent < 0.93 && percent > 0.0)
            ? Positioned(
                //top: searchBarOffset,
                left: 0,
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TaxiPage(vendor, false, false)),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 5,
                              spreadRadius: 5)
                        ]),
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    alignment: Alignment.centerLeft,
                    child: MediaQuery(
                      data: MediaQuery.of(context)
                          .copyWith(textScaler: TextScaler.linear(1)),
                      child: Text(
                        "Where to?".tr().toString(),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ).px12().py8(),
                    ),
                  ).px12(),
                ),
              )
            : Opacity(
                opacity: percent < 0.93 && percent > 0.0 ? percent : 1.0,
                child: AppBar(
                  centerTitle: false,
                  automaticallyImplyLeading: true,
                  backgroundColor: AppColor.primaryColor,
                  title: Opacity(
                    opacity:
                        percent < 0.93 && percent > 0.0 ? 1 - percent : 1.0,
                    child: HStack(
                      [
                        "Where to?"
                            .tr()
                            .text
                            .semiBold
                            .lg
                            .color(Colors.black)
                            .make()
                            .px12()
                            .expand(),
                        CustomVisibilty(
                          visible: AppStrings.canScheduleTaxiOrder,
                          child: Icon(
                            FlutterIcons.calendar_ant,
                            size: 18,
                            color: AppColor.primaryColor,
                          ).onInkTap(() {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      TaxiPage(vendor, false, false)),
                            );
                          }).p2(),
                        ),
                      ],
                    )
                        .px12()
                        .py8()
                        .box
                        .color(Colors.white)
                        .shadowXs
                        .withRounded(value: 5)
                        .make()
                        .onInkTap(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TaxiPage(vendor, false, false)),
                      );
                    }),
                  ),
                ),
              ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;
  @override
  double get minExtent => kToolbarHeight * 2 - 25;
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}
