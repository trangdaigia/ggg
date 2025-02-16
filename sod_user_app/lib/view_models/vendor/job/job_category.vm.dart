import 'package:sod_user/flavors.dart';
import 'package:sod_user/models/job_category.dart';
import 'package:sod_user/requests/job.request.dart';
import 'package:sod_user/view_models/base.view_model.dart';

class JobCategoryViewModel extends MyBaseViewModel {
  JobRequest _jobRequest = JobRequest();

  List<JobCategory> categories = [];

  Future<List<JobCategory>> initialise({bool all = false}) async {
    setBusy(true);
    try {
      categories = await _jobRequest.jobsCategory();
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
    return categories;
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
