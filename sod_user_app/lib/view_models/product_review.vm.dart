import 'package:flutter/material.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/models/product_review.dart';
import 'package:sod_user/models/product_review_stat.dart';
import 'package:sod_user/requests/product.request.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/views/pages/review/product_reviews.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ProductReviewViewModel extends MyBaseViewModel {
  //
  ProductReviewViewModel(
    BuildContext context,
    this.product,
    this.summary, {
    this.orderId,
  }) {
    this.viewContext = context;
  }

  //
  ProductRequest productRequest = ProductRequest();
  ScrollController scrollController = ScrollController();

  //
  bool summary = false;
  Product product;
  List<ProductReview> productReviews = [];
  List<ProductReviewStat> productReviewStats = [];
  int page = 1;

  //post rating
  double rating = 1;
  TextEditingController reviewTEC = TextEditingController();
  int? orderId;

  @override
  void initialise() async {
    super.initialise();
    //
    scrollController = ScrollController()..addListener(handleScrolling);

    if (!summary) {
      await getProductReviewSummary();
      await getProductReviews();
    } else {
      getProductReviewSummary();
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(handleScrolling);
    super.dispose();
  }

  void handleScrolling() {
    //at bottom, load more
    if (scrollController.offset >= scrollController.position.maxScrollExtent) {
      //
      if (!busy(scrollController)) {
        getProductReviews(false);
      }
    }
  }

  //
  Future<void> getProductReviews([bool initialLoading = true]) async {
    //
    if (initialLoading) {
      page = 1;
      productReviews = [];
      setBusyForObject(productReviews, true);
    } else {
      page += 1;
      setBusyForObject(scrollController, true);
    }

    try {
      List<ProductReview> mProductReviews = await productRequest.productReviews(
        page: page,
        queryParams: {
          "product_id": product.id,
        },
      );
      productReviews.addAll(mProductReviews);
      //
      if (mProductReviews.isEmpty && !initialLoading) {
        page -= 1;
      }
    } catch (error) {
      setError(error);
      print("load more error ==> $error");
    }

    if (initialLoading) {
      setBusyForObject(productReviews, false);
    } else {
      setBusyForObject(scrollController, false);
    }
  }

  Future<void> getProductReviewSummary() async {
    //
    setBusyForObject(productReviews, true);

    try {
      final apiResponse = await productRequest.productReviewSummary(
        queryParams: {
          "id": product.id,
        },
      );

      //
      final responseBody = apiResponse.body as Map;
      productReviews = (responseBody["latest_reviews"] as List)
          .map((e) => ProductReview.fromJson(e))
          .toList();

      //rating reviews
      productReviewStats = (responseBody["rating_summary"] as List)
          .map((e) => ProductReviewStat.fromJson(e))
          .toList();
    } catch (error) {
      setError(error);
      print("errorr ==> $error");
    }
    setBusyForObject(productReviews, false);
  }

  void openAllReviews() {
    Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => ProductReviewsPage(product),
      ),
    );
  }

  //POST REVIEW
  updateRating(String value) {
    rating = double.parse(value);
    notifyListeners();
  }

  submitReview() async {
    setBusyForObject(rating, true);
    try {
      final apiResponse = await productRequest.submitReview(
        params: {
          "product_id": product.id,
          "order_id": orderId,
          "rating": rating,
          "review": reviewTEC.text,
        },
      );
      //
      if (apiResponse.allGood) {
        await AlertService.success(
          title: "Product Review".tr(),
          text: "Product Review submitted successfully".tr(),
        );
        Navigator.pop(viewContext, true);
      } else {
        toastError("${apiResponse.message}");
      }
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(rating, false);
  }
}
