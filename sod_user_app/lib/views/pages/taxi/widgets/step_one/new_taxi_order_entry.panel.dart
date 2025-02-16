import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/models/tax_order_location.history.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/delivery_address/delivery_addresses.vm.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:sod_user/view_models/taxi_new_order_location_entry.vm.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_one/new_taxi_order_schedule.view.dart';
import 'package:sod_user/views/pages/taxi/widgets/step_one/new_taxi_pick_on_map.view.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/custom_timeline_connector.dart';
import 'package:sod_user/widgets/list_items/address.list_item.dart';
import 'package:sod_user/widgets/list_items/delivery_address.list_item.dart';
import 'package:sod_user/widgets/list_items/taxi_order_location_history.list_item.dart';
import 'package:sod_user/widgets/states/delivery_address.empty.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:sod_user/widgets/taxi_custom_text_form_field.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class NewTaxiOrderEntryPanel extends StatefulWidget {
  const NewTaxiOrderEntryPanel(this.taxiNewOrderViewModel, this.isShippingOrder,
      {Key? key})
      : super(key: key);

  final NewTaxiOrderLocationEntryViewModel taxiNewOrderViewModel;
  final bool isShippingOrder;

  @override
  State<NewTaxiOrderEntryPanel> createState() => _NewTaxiOrderEntryPanelState();
}

class _NewTaxiOrderEntryPanelState extends State<NewTaxiOrderEntryPanel> {
  late CustomListView ResultList;
  late CustomListView RecentList;
  late CustomListView SavedList;

  void showTopBanner(String message) {
    final scaffold = ScaffoldMessenger.of(context);
    final snackBar = SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: AppColor.primaryColor,
      duration: Duration(seconds: 2),
    );

    scaffold.showSnackBar(snackBar);
  }

  void handleNextButtonPress() {
    final taxiVM = widget.taxiNewOrderViewModel.taxiViewModel;

    // Ensure pickup and dropoff locations are checked correctly
    if (taxiVM.pickupLocation == null ||
        (taxiVM.pickupLocation?.address?.isEmpty ?? true) ||
        taxiVM.dropoffLocation == null ||
        (taxiVM.dropoffLocation?.address?.isEmpty ?? true)) {
      // Show the top banner message
      showTopBanner("Hệ thống đang bận. Vui lòng nhập lại địa chỉ!");

      // Clear text fields if the addresses are null
      if (taxiVM.pickupLocation == null ||
          (taxiVM.pickupLocation?.address?.isEmpty ?? true)) {
        taxiVM.pickupLocationTEC.clear();
      }
      if (taxiVM.dropoffLocation == null ||
          (taxiVM.dropoffLocation?.address?.isEmpty ?? true)) {
        taxiVM.dropoffLocationTEC.clear();
      }
    } else {
      // If all conditions are met, proceed to the next step
      widget.taxiNewOrderViewModel.moveToNextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TaxiViewModel taxiVM = widget.taxiNewOrderViewModel.taxiViewModel;
    return VxBox(
      child: taxiVM.isBusy
          ? BusyIndicator().centered().p20()
          : VStack(
              [
                VStack(
                  [
                    //Title
                    HStack(
                      [
                        Icon(
                          FlutterIcons.close_ant,
                        ).onTap(widget.taxiNewOrderViewModel.closePanel),
                        "Your route".tr().text.bold.xl.make().px12().expand(),
                      ],
                    ),
                    UiSpacer.verticalSpace(),
                    //schedule order
                    NewTaxiOrderScheduleView(widget.taxiNewOrderViewModel),
                    //entry
                    HStack(
                      [
                        //
                        CustomTimelineConnector(height: 50),
                        UiSpacer.hSpace(10),
                        //Text Field
                        VStack(
                          [
                            TaxiCustomTextFormField(
                              hintText: "Pickup Location".tr(),
                              controller: taxiVM.pickupLocationTEC,
                              focusNode: taxiVM.pickupLocationFocusNode,
                              onChanged: (String keyword) {
                                keyword = taxiVM.pickupLocationTEC.text;
                                widget.taxiNewOrderViewModel
                                    .searchPlace(keyword);
                              },
                              clear: true,
                            ),
                            UiSpacer.vSpace(5),
                            TaxiCustomTextFormField(
                              hintText: widget.isShippingOrder
                                  ? "Dropoff Location".tr()
                                  : "Drop Off Location".tr(),
                              controller: taxiVM.dropoffLocationTEC,
                              focusNode: taxiVM.dropoffLocationFocusNode,
                              onChanged: (String keyword) {
                                keyword = taxiVM.dropoffLocationTEC.text;
                                widget.taxiNewOrderViewModel
                                    .searchPlace(keyword);
                              },
                              clear: true,
                            ),
                            UiSpacer.vSpace(5),
                          ],
                        ).expand(),
                      ],
                    ),
                  ],
                )
                    .p20()
                    .safeArea()
                    .box
                    .shadowSm
                    .color(context.theme.colorScheme.background)
                    .make(),
                Expanded(
                  flex: 11,
                  child: Stack(
                    children: [
                      //result search list
                      Visibility(
                        visible: widget.taxiNewOrderViewModel.places != null,
                        child: ResultList = CustomListView(
                          padding: EdgeInsets.zero,
                          isLoading: widget.taxiNewOrderViewModel
                              .busy(widget.taxiNewOrderViewModel.places),
                          dataSet: widget.taxiNewOrderViewModel.places != null
                              ? widget.taxiNewOrderViewModel.places!
                              : [],
                          itemBuilder: (contex, index) {
                            final place =
                                widget.taxiNewOrderViewModel.places![index];

                            print("checkadress");
                            print(place.toMap());
                            return AddressListItem(
                              place,
                              onAddressSelected: widget
                                  .taxiNewOrderViewModel.onAddressSelected,
                            );
                          },
                          separatorBuilder: (ctx, index) => UiSpacer.divider(),
                        ),
                      ),
                      //tabs
                      Visibility(
                        visible: ResultList.dataSet.isEmpty,
                        child: ViewModelBuilder<
                                DeliveryAddressesViewModel>.reactive(
                            viewModelBuilder: () =>
                                DeliveryAddressesViewModel(context),
                            onViewModelReady: (deliveryaddresstaxiVM) =>
                                deliveryaddresstaxiVM.initialise(),
                            builder: (context, deliveryaddresstaxiVM, child) {
                              return ContainedTabBarView(
                                callOnChangeWhileIndexIsChanging: true,
                                tabBarProperties: TabBarProperties(
                                  alignment: TabBarAlignment.center,
                                  isScrollable: true,
                                  labelPadding: EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 0,
                                  ),
                                  //
                                  padding: EdgeInsets.all(0),
                                  labelColor: AppColor.primaryColor,
                                  unselectedLabelColor: AppColor.primaryColor,
                                  labelStyle:
                                      context.textTheme.bodyLarge!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  unselectedLabelStyle:
                                      context.textTheme.bodyLarge!.copyWith(),
                                ),
                                tabs: [
                                  Tab(child: "Recent".tr().text.make()),
                                  Tab(child: "Saved".tr().text.make())
                                ],
                                views: [
                                  //recent address list
                                  RecentList = CustomListView(
                                    padding: EdgeInsets.fromLTRB(8, 27, 8, 10),
                                    dataSet: widget.taxiNewOrderViewModel
                                        .previousAddresses,
                                    isLoading:
                                        widget.taxiNewOrderViewModel.busy(
                                      widget.taxiNewOrderViewModel
                                          .previousAddresses,
                                    ),
                                    emptyWidget: EmptyDeliveryAddress(),
                                    errorWidget: LoadingError(
                                      onrefresh: deliveryaddresstaxiVM
                                          .fetchDeliveryAddresses,
                                    ),
                                    itemBuilder: (context, index) {
                                      final orderAddressHistory = widget
                                          .taxiNewOrderViewModel
                                          .previousAddresses[index];
                                      return TaxiOrderHistoryListItem(
                                          orderAddressHistory,
                                          onPressed: ((orderAddressHistory) {
                                        if (taxiVM.pickupLocationFocusNode
                                                .hasFocus ||
                                            taxiVM.pickupLocationTEC.text
                                                .isNullOrEmpty) {
                                          taxiVM.pickupLocation = null;
                                          //Change value
                                          taxiVM.pickupLocation =
                                              DeliveryAddress(
                                                  address: orderAddressHistory
                                                      .address,
                                                  longitude: orderAddressHistory
                                                      .longitude,
                                                  latitude: orderAddressHistory
                                                      .latitude,
                                                  name:
                                                      orderAddressHistory.name);
                                          //Change address text display on textfield
                                          final _newValue =
                                              orderAddressHistory.address;
                                          taxiVM.pickupLocationTEC.text =
                                              _newValue;
                                          taxiVM.pickupLocationTEC.value
                                              .copyWith(
                                                  text: _newValue,
                                                  selection: TextSelection
                                                      .fromPosition(
                                                          TextPosition(
                                                              offset: _newValue
                                                                  .length)));
                                        } else if (taxiVM.dropoffLocationTEC.text
                                                .isNullOrEmpty ||
                                            taxiVM.dropoffLocationFocusNode
                                                .hasFocus ||
                                            taxiVM.pickupLocationTEC.text
                                                .isNotNullOrEmpty) {
                                          try {
                                            widget.taxiNewOrderViewModel
                                                .onDestinationSelected(
                                                    orderAddressHistory);
                                            //Change address text display on textfield
                                            final _newValue =
                                                orderAddressHistory.address;
                                            taxiVM.dropoffLocationTEC.text =
                                                _newValue;
                                            taxiVM.dropoffLocationTEC.value
                                                .copyWith(
                                                    text: _newValue,
                                                    selection: TextSelection
                                                        .fromPosition(
                                                            TextPosition(
                                                                offset: _newValue
                                                                    .length)));
                                          } catch (error) {
                                            debugPrint("Error ===> $error");
                                            taxiVM.dropoffLocationTEC.clear();
                                            taxiVM.dropoffLocation = null;
                                            taxiVM.notifyListeners();
                                          }
                                        }
                                      }));
                                    },
                                    separatorBuilder: (ctx, index) =>
                                        UiSpacer.divider(),
                                  ),
                                  //Saved addrress list
                                  SavedList = CustomListView(
                                    refreshController:
                                        deliveryaddresstaxiVM.refreshController,
                                    padding: EdgeInsets.fromLTRB(8, 27, 8, 10),
                                    dataSet:
                                        deliveryaddresstaxiVM.deliveryAddresses,
                                    isLoading: deliveryaddresstaxiVM.busy(
                                        deliveryaddresstaxiVM
                                            .deliveryAddresses),
                                    emptyWidget: EmptyDeliveryAddress(),
                                    errorWidget: LoadingError(
                                      onrefresh: deliveryaddresstaxiVM
                                          .fetchDeliveryAddresses,
                                    ),
                                    itemBuilder: (context, index) {
                                      final deliveryAddress =
                                          deliveryaddresstaxiVM
                                              .deliveryAddresses[index];
                                      return DeliveryAddressListItem(
                                        delete: false,
                                        action:
                                            deliveryAddress.address!.isNotEmpty,
                                        deliveryAddress: deliveryAddress,
                                        borderColor: Colors.grey.shade300,
                                        onEditPressed: () {
                                          if (taxiVM.pickupLocationTEC.text
                                                  .isNullOrEmpty ||
                                              taxiVM.pickupLocationFocusNode
                                                  .hasFocus) {
                                            //Change value
                                            taxiVM.pickupLocation = null;
                                            taxiVM.pickupLocation =
                                                deliveryAddress;
                                            //Change address text display on textfield
                                            final _newValue =
                                                deliveryAddress.address!;
                                            taxiVM.pickupLocationTEC.text =
                                                _newValue;
                                            taxiVM.pickupLocationTEC.value
                                                .copyWith(
                                                    text: _newValue,
                                                    selection: TextSelection
                                                        .fromPosition(
                                                            TextPosition(
                                                                offset: _newValue
                                                                    .length)));
                                          } else if (taxiVM.dropoffLocationTEC
                                                  .text.isNullOrEmpty ||
                                              taxiVM.dropoffLocationFocusNode
                                                  .hasFocus) {
                                            taxiVM.dropoffLocation = null;
                                            //Change value
                                            widget.taxiNewOrderViewModel
                                                .onDestinationSelected(
                                                    TaxiOrderLocationHistory(
                                                        latitude:
                                                            deliveryAddress
                                                                .latitude!,
                                                        longitude:
                                                            deliveryAddress
                                                                .longitude!,
                                                        address: deliveryAddress
                                                            .address!,
                                                        name: deliveryAddress
                                                            .name!));
                                            //Change address text display on textfield
                                            final _newValue =
                                                deliveryAddress.address!;

                                            taxiVM.dropoffLocationTEC.text =
                                                _newValue;
                                            taxiVM.dropoffLocationTEC.value
                                                .copyWith(
                                                    text: _newValue,
                                                    selection: TextSelection
                                                        .fromPosition(
                                                            TextPosition(
                                                                offset: _newValue
                                                                    .length)));
                                          }
                                        },
                                      );
                                      // }
                                    },
                                    separatorBuilder: (context, index) =>
                                        UiSpacer.verticalSpace(space: 5),
                                  ),
                                ],
                              );
                            }),
                      ),
                    ],
                  ),
                ),

                //select on map
                NewTaxiPickOnMapButton(
                  taxiNewOrderViewModel: widget.taxiNewOrderViewModel,
                ),
                //button Next
                Visibility(
                  visible: !taxiVM.pickupLocationFocusNode.hasFocus &&
                      !taxiVM.dropoffLocationFocusNode.hasFocus,
                  child: CustomButton(
                    title: "Next".tr(),
                    onPressed: handleNextButtonPress,
                  ).p8().safeArea(top: false),
                ),
              ],
            ),
    )
        .color(taxiVM.isBusy
            ? context.theme.colorScheme.background.withOpacity(0.5)
            : context.theme.colorScheme.background)
        .make()
        .pOnly(bottom: context.mq.viewInsets.bottom);
  }
}
