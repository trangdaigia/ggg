import 'dart:io';

import 'package:sod_user/driver_lib/services/alert.service.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/requests/auth.request.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class DocumentRequestViewModel extends MyBaseViewModel {
  //
  AuthRequest _authRequest = AuthRequest();
  Driver? currentUser;
  List<File> selectedDocuments = [];
  //
  void initialise() async {
    currentUser = (await AuthServices.getCurrentDriver());
    fetchMyProfile();
  }

  fetchMyProfile() async {
    setBusy(true);
    try {
      currentUser = await _authRequest.getMyDetails();
    } catch (error) {
      print(error);
    }
    setBusy(false);
  }

  //
  void onDocumentsSelected(List<File> documents) {
    selectedDocuments = documents;
    notifyListeners();
  }

  submitDocuments() async {
    //if no document is selected
    if (selectedDocuments.isEmpty) {
      toastError("Please select a document".tr());
      return;
    }

    setBusyForObject(selectedDocuments, true);

    try {
      //
      final apiResponse = await _authRequest.submitDocumentsRequest(
        docs: selectedDocuments,
      );

      if (apiResponse.allGood) {
        await AlertService.success(
          title: "Document Request".tr(),
          text: "${apiResponse.message}",
        );
        //
        fetchMyProfile();
        //
      } else {
        toastError("${apiResponse.message}");
      }
    } catch (error) {
      toastError("$error");
    }

    setBusyForObject(selectedDocuments, false);
  }
}
