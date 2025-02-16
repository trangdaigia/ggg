import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/models/review.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:sod_user/driver_lib/constants/app_routes.dart';
import 'package:sod_user/driver_lib/requests/review.request.dart';

class ProfileDetailViewModel extends MyBaseViewModel {
  Driver? currentUser;
  List<Review> reviewFormOrther = [];
  List<Review> myReview = [];

  TabController? tabController;

  ProfileDetailViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    // request song song để tăng tốc độ
    getCurrentUser();
    getReviewFormOrther();
    getMyReview();
  }

  Future<void> getCurrentUser() async {
    setBusyForObject(currentUser, true);
    currentUser = await AuthServices.getCurrentDriver();
    setBusyForObject(currentUser, false);
  }

  Future<void> getReviewFormOrther() async {
    setBusyForObject(reviewFormOrther, true);
    reviewFormOrther = await ReviewRequest.getReviewed();
    reviewFormOrther.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setBusyForObject(reviewFormOrther, false);
  }

  Future<void> getMyReview() async {
    setBusyForObject(myReview, true);
    myReview = await ReviewRequest.getMytReview();
    myReview.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    setBusyForObject(myReview, false);
  }

  Future<void> refreshReviewsFromOther() async {
    reviewFormOrther = await ReviewRequest.getReviewed(forceRefresh: true);
    reviewFormOrther.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> refreshMyReview() async {
    myReview = await ReviewRequest.getMytReview(forceRefresh: true);
    myReview.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void setTabController(TabController tabController) =>
      this.tabController = tabController;

  void editProfile() async {
    if (busy(currentUser)) return;
    final result = await Navigator.of(viewContext).pushNamed(
      AppRoutes.editProfileRoute,
    );

    if (result != null && result is bool && result) {
      initialise();
    }
  }
}
