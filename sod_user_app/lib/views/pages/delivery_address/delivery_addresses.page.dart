import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/delivery_address/delivery_addresses.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/delivery_address.list_item.dart';
import 'package:sod_user/widgets/states/delivery_address.empty.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class DeliveryAddressesPage extends StatelessWidget {
  const DeliveryAddressesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DeliveryAddressesViewModel>.reactive(
      viewModelBuilder: () => DeliveryAddressesViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
            showAppBar: true,
            showLeadingAction: true,
            title: "Saved Places".tr(),
            isLoading: vm.isBusy,
            body: Column(children: [
              Expanded(
                flex: 11,
                child: CustomListView(
                  padding: EdgeInsets.fromLTRB(
                      10, 5, 10, context.percentHeight * 20),
                  dataSet: vm.deliveryAddresses,
                  isLoading: vm.busy(vm.deliveryAddresses),
                  emptyWidget: EmptyDeliveryAddress(),
                  errorWidget: LoadingError(
                    onrefresh: vm.fetchDeliveryAddresses,
                  ),
                  itemBuilder: (context, index) {
                    //
                    final deliveryAddress = vm.deliveryAddresses[index];
                    //
                    return DeliveryAddressListItem(
                      key: ValueKey(deliveryAddress.id),
                      action: deliveryAddress.address!.isNotEmpty,
                      deliveryAddress: deliveryAddress,
                      borderColor: Colors.grey.shade300,
                      onEditPressed: () =>
                          vm.editDeliveryAddress(deliveryAddress),
                      onDeletePressed: () => deliveryAddress.name
                                      ?.toString()
                                      .toLowerCase() ==
                                  "home" ||
                              deliveryAddress.name?.toString().toLowerCase() ==
                                  "work"
                          ? vm.updateDeliveryAddressWithoutUI(deliveryAddress)
                          : vm.deleteDeliveryAddress(deliveryAddress),
                    );
                  },
                  separatorBuilder: (context, index) =>
                      UiSpacer.verticalSpace(space: 5),
                ),
              ),
              Expanded(
                  flex: 1,
                  child: Container(
                      margin: EdgeInsets.symmetric(horizontal: Vx.dp10),
                      child: CustomButton(
                        // height: Vx.dp48,
                        icon: FlutterIcons.plus_ant,
                        isFixedHeight: true,
                        title: "Add new address".tr(),
                        iconColor: Colors.white,
                        color: context.primaryColor,
                        onPressed: vm.newDeliveryAddressPressed,
                      ).centered()))
            ]));
      },
    );
  }
}
