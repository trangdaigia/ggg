import 'package:flutter/material.dart';
import 'package:sod_user/flavors.dart';
import 'package:sod_user/models/job.dart';
import 'package:sod_user/models/job_category.dart';
import 'package:sod_user/requests/job.request.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_more.dart';

class JobViewModel extends MyBaseViewModel {
  JobViewModel(BuildContext context) {
    this.viewContext = context;
  }

  JobRequest _jobRequest = JobRequest();

  List<JobCategory> categories = [];
  RefreshController refreshController = RefreshController();

  List<Job> job = [];

  initialise({bool all = false}) async {
    setBusy(true);
    try {
      job = await _jobRequest.jobsList();
      categories = await _jobRequest.jobsCategory();
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  void onPressedJobCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobMore(showAll: true, categoryId: null),
      ),
    );
  }

  void onPressedJobUrgent(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            JobMore(isUrgent: true, showAll: true, categoryId: null),
      ),
    );
  }

  String getAppImage() {
    switch (F.appFlavor) {
      case Flavor.sod_user:
        return "assets/images/app_icons/sod_user/icon-transparent.png";
      case Flavor.sob_express:
        return "assets/images/app_icons/sob_express/icon.png";
      case Flavor.suc365_user:
        return "assets/images/app_icons/suc365_user/icon-transparent.png";
      case Flavor.g47_user:
        return "assets/images/app_icons/g47_user/icon-transparent.png";
      case Flavor.appvietsob_user:
        return "assets/images/app_icons/appvietsob_user/icon-transparent.png";
      case Flavor.vasone:
        return "assets/images/app_icons/vasone/icon.png";
      case Flavor.fasthub_user:
        return "assets/images/app_icons/fasthub_user/icon.png";
      case Flavor.goingship:
        return "assets/images/app_icons/goingship/icon-transparent.png";
      case Flavor.grabxanh:
        return "assets/images/app_icons/shipxanh/icon-transparent.png";
      default:
        return "assets/images/app_icons/sod_user/icon-transparent.png";
    }
  }
}
