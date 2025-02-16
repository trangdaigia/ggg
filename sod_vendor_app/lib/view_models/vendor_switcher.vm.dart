import 'package:sod_vendor/models/user.dart';
import 'package:sod_vendor/models/vendor.dart';
import 'package:sod_vendor/requests/vendor.request.dart';
import 'package:sod_vendor/services/app.service.dart';
import 'package:sod_vendor/services/auth.service.dart';
import 'package:sod_vendor/view_models/base.view_model.dart';

class VendorSwitcherBottomSheetViewModel extends MyBaseViewModel {
  List<Vendor> vendors = [];

  fetchMyVendors() async {
    setBusyForObject(vendors, true);

    try {
      vendors = await VendorRequest().myVendors();
    } catch (error) {
      print("VendorSwitcherBottomSheetViewModel.fetchMyVendors: $error");
      toastError("$error");
    }
    setBusyForObject(vendors, false);
  }

  switchVendor(Vendor vendor) async {
    setBusy(true);
    setBusyForObject(vendor.id, true);
    try {
      await VendorRequest().switchVendor(vendor);
      //set the new vendor
      User currentUser = await AuthServices.getCurrentUser(force: true);
      currentUser.vendor_id = vendor.id;
      AuthServices.saveUser(currentUser.toJson());
      AuthServices.saveVendor(vendor.toJson());
      AuthServices.subscribeToFirebaseTopic("v_${vendor.id}", clear: true);
      AuthServices.subscribeToFirebaseTopic(
          "${AuthServices.currentUser?.role}");

      //reload app
      AppService().reloadApp();
    } catch (error) {
      print("VendorSwitcherBottomSheetViewModel.switchVendor: $error");
      toastError("$error");
    }
    setBusy(false);
    setBusyForObject(vendor.id, false);
  }
}
