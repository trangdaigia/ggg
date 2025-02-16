import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:sod_user/models/real_estate.dart';
import 'package:sod_user/models/real_estate_category.dart';
import 'package:sod_user/requests/real_estate.request.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/views/pages/real_estate/widgets/real_estate_filter_overlay.dart';
import 'package:sod_user/view_models/base.view_model.dart';

class RealEstateSearchViewModel extends MyBaseViewModel {
  //
  RealEstateSearchViewModel(BuildContext context, {this.query}) {
    this.viewContext = context;
  }
  Map<String, dynamic>? query;
  StreamSubscription? authStateSub;
  List<RealEstate> realEstates = [];
  List<RealEstateCategory> categories = [];
  List<String> cities = ["Ho Chi minh"];
  String listStyle = "grid";
  List<String> directionList = [
    "North",
    "East",
    "West",
    "South",
    "Nort East",
    "Nort West",
    "South East",
    "South West"
  ];
  List<String> sortByList = ["price", "createdDate"];
  List<String> sellingTypes = ["Sell", "Rent"];
  String selectedSortBy = "createdDate";
  String selectedCity = "Ho Chi minh";
  Timer? _debounce;
  bool _loading = true;
  final GlobalKey<RealEstateFilterOverlayState> filterKey = GlobalKey();
  final double _endReachedThreshold = 200;
  final RealEstateRequest realEstateRequest = RealEstateRequest();
  final ScrollController scrollController = ScrollController();
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
      await Future.wait([getRealEstates(), getCategories()]);
      scrollController.addListener(_onScroll);
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

  void _onScroll() {
    if (!scrollController.hasClients || _loading) return;

    final thresholdReached =
        scrollController.position.extentAfter < _endReachedThreshold;

    if (thresholdReached) {
      nextPage();
    }
  }
  @override
void dispose() {
    _debounce?.cancel();
    super.dispose();
}

  Future<void> init() async {
    if (refreshController.isRefresh) {
      refreshController.refreshCompleted();
    }
    pageKey = GlobalKey();
    notifyListeners();

    await Future.wait([getRealEstates(), getCategories()]);
    listenToAuth();
  }

  Future<void> getRealEstates() async {
    try {
      setBusy(true);
      realEstates = await realEstateRequest.index(query: query);
      print(query);
      setBusy(false);
      print("Real estate number: ${realEstates.length}");
      clearErrors();
    } catch (error) {
      setError(error);
    }
  }

  Future<void> getCategories() async {
    try {

      categories = await realEstateRequest.getRealEstateCatagories();
    } catch (error) {
      setError(error);
    }
  }

  void addQuery(String s, dynamic t) async {
    if (query == null)
      query = {s: t.toString()};
    else {
      if (t == null)
        query!.remove(s);
      else
        query![s] = t.toString();
    }
    print("Query: ${query}");
    realEstateRequest.page = 1;
  }
  onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      addQuery("keyword", query);
      getRealEstates();
    });
}

  String? getQuery(String a) {
    if(query == null || query![a] == null)
      return null;
    return query![a];
  }

  void nextPage() async {
    if(!realEstateRequest.canLoadMore)
      return;
 try {
      setBusy(true);
      List<RealEstate> temp = await realEstateRequest.index(query: query);
      realEstates.addAll(temp);
      setBusy(false);
      print("Real estate number: ${realEstates.length}");
      clearErrors();
    } catch (error) {
      setError(error);
    }  
  }
  bool canLoadMore() {
    return realEstateRequest.canLoadMore;
  }
}
