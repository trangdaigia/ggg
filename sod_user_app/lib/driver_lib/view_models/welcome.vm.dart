import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_routes.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';

class WelcomeViewModel extends MyBaseViewModel {
  //
  WelcomeViewModel(BuildContext context) {
    this.viewContext = context;
  }

  int selectedPage = 0;
  String pageTitle = "";

  pageSelected(int page, String title) async {
    if (page == 1 && !(await AuthServices.authenticated())) {
      Navigator.of(viewContext).pushNamed(AppRoutes.loginRoute);
    } else {
      selectedPage = page;
      pageTitle = title;
      notifyListeners();
    }
  }
}
