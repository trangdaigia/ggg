import 'package:flutter/material.dart';
import 'package:sod_user/requests/job.request.dart';
import 'package:sod_user/view_models/base.view_model.dart';

class JobAddViewModel extends MyBaseViewModel {
  final TextEditingController fullNameTEC = new TextEditingController();
  final TextEditingController phoneNumberTEC = new TextEditingController();

  JobRequest _jobRequest = JobRequest();

  Future<void> initialise({bool all = false}) async {
    setBusy(true);
    try {
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  // Future<void> onPressedApplyJob(BuildContext context) async {
  //   final result = await _jobRequest.applyJob({
  //     "full_name": fullNameTEC.text,
  //     "phone_number": phoneNumberTEC.text,
  //   });

  //   if (result.allGood) {
  //     Navigator.pop(context);
  //   } else {
  //     setError(result.message!);
  //   }
  // }
}
