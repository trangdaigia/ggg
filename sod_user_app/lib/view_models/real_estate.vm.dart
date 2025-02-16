import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sod_user/models/real_estate.dart';
import 'package:sod_user/models/real_estate_category.dart';
import 'package:sod_user/requests/real_estate.request.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';

class RealEstateViewModel extends MyBaseViewModel {
  //
  RealEstateViewModel(BuildContext context) {
    this.viewContext = context;
  }

  StreamSubscription? authStateSub;
  List<RealEstate> realEstates = [];
  List<RealEstateCategory> realEstateCategories = [];
  RealEstateRequest realEstateRequest = RealEstateRequest();
  //
  //
  initialise({bool initial = true}) async {
    //
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted();
    }

    if (!initial) {
      pageKey = GlobalKey();
      notifyListeners();
    }

    try {
      setBusy(true);
      await Future.wait([getRealEstates(), getQuatityByCategory()]);
    } finally {
      setBusy(false);
    }
    listenToAuth();
  }

  listenToAuth() {
    authStateSub = AuthServices.listenToAuthState().listen((event) {
      genKey = GlobalKey();
      notifyListeners();
    });
  }

  Future<void> init() async {
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted();
    }
    pageKey = GlobalKey();
    notifyListeners();

    await Future.wait([getRealEstates(), getQuatityByCategory()]);
    listenToAuth();
  }

  Future<void> getRealEstates() async {
    try {
      realEstates = await realEstateRequest.index();
      clearErrors();
    } catch (error) {
      setError(error);
    }
  }

  Future<void> getQuatityByCategory() async {
    try {
      realEstateCategories = await realEstateRequest.getRealEstateCatagories();
    } catch (error) {
      setError(error);
    }
  }
}
