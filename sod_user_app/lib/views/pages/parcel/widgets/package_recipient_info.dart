import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/view_models/new_parcel.vm.dart';
import 'package:sod_user/views/pages/parcel/widgets/form_step_controller.dart';
import 'package:sod_user/views/pages/parcel/widgets/list_item/package_stop_recipient.view.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:velocity_x/velocity_x.dart';

class PackageRecipientInfo extends StatelessWidget {
  const PackageRecipientInfo({
    required this.vm,
    Key? key,
  }) : super(key: key);

  final NewParcelViewModel vm;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: vm.recipientInfoFormKey,
      child: VStack(
        [
          //
          CustomListView(
            dataSet: !AppStrings.enableParcelMultipleStops
                ? [0, 1]
                : vm.recipientNamesTEC,
            itemBuilder: (context, index) {
              DeliveryAddress stop;
              if (index == 0) {
                stop = vm.packageCheckout.pickupLocation!;
              } else if (!AppStrings.enableParcelMultipleStops) {
                stop = vm.packageCheckout.dropoffLocation!;
              } else {
                stop = vm
                    .packageCheckout.stopsLocation![index - 1].deliveryAddress!;
              }
              final recipientNameTEC = vm.recipientNamesTEC[index];
              final recipientPhoneTEC = vm.recipientPhonesTEC[index];
              final noteTEC = vm.recipientNotesTEC[index];
              //
              return PackageStopRecipientView(
                stop,
                recipientNameTEC,
                recipientPhoneTEC,
                noteTEC,
                isOpen: index == vm.openedRecipientFormIndex,
                index: index + 1,
              );
            },
            padding: EdgeInsets.only(top: Vx.dp16),
          ).expand(),

          //
          FormStepController(
            onPreviousPressed: () => vm.nextForm(2),
            onNextPressed: vm.validateRecipientInfo,
          ),
        ],
      ),
    );
  }
}
