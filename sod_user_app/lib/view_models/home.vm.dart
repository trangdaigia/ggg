import 'dart:async';

import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:rx_shared_preferences/rx_shared_preferences.dart';
import 'package:sod_user/constants/api.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/global/global_variable.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/models/service.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/requests/order.request.dart';
import 'package:sod_user/requests/product.request.dart';
import 'package:sod_user/requests/service.request.dart';
import 'package:sod_user/requests/vendor.request.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/services/cart.service.dart';
import 'package:sod_user/services/local_storage.service.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/views/pages/auth/login.page.dart';
import 'package:sod_user/views/pages/product/amazon_styled_commerce_product_details.page.dart';
import 'package:sod_user/views/pages/product/product_details.page.dart';
import 'package:sod_user/views/pages/service/service_details.page.dart';
import 'package:sod_user/views/pages/vendor_details/vendor_details.page.dart';
import 'package:sod_user/views/pages/welcome/welcome.page.dart';
import 'package:velocity_x/velocity_x.dart';

import '../models/order.dart';

class HomeViewModel extends MyBaseViewModel {
  //
  HomeViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  int currentIndex = 0;
  PageController pageViewController = PageController(initialPage: 0);
  int totalCartItems = 0;
  StreamSubscription? homePageChangeStream;
  Widget homeView = WelcomePage();

  List<Order> orders = [];
  OrderRequest orderRequest = OrderRequest();

  @override
  void initialise() async {
    //
    handleAppLink();
    //determine if home view should be multiple vendor types or single vendor page
    if (AppStrings.isSingleVendorMode) {
      VendorType vendorType = VendorType.fromJson(AppStrings.enabledVendorType);
      homeView = NavigationService.vendorTypePage(
        vendorType,
        context: viewContext,
      );

      //require login
      if (vendorType.authRequired && !AuthServices.authenticated()) {
        await Navigator.push(
          viewContext,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              required: true,
            ),
          ),
        );
      }
      notifyListeners();
    }

    //start listening to changes to items in cart
    LocalStorageService.rxPrefs?.getIntStream(CartServices.totalItemKey).listen(
      (total) {
        if (total != null) {
          totalCartItems = total;
          notifyListeners();
        }
      },
    );

    //
    homePageChangeStream = AppService().homePageIndex.stream.listen(
      (index) {
        //
        onTabChange(index);
      },
    );
  }

  // Check only Receive Behalf Order
  fetchOrder({bool initialLoading = true}) async {
    if (initialLoading) {
      setBusy(true);
      refreshController.refreshCompleted();
    }
    try {
      final mOrders = await orderRequest.getOrders(page: 1);
      if (!initialLoading) {
        orders.addAll(mOrders);
        refreshController.loadComplete();
      } else {
        orders = mOrders;
      }
      print("Fetch Order Completed at home.vm.dart");
      clearErrors();
    } catch (error) {
      print("Fetch Order Error at home.vm.dart==> $error");
      setError(error);
    }
    setBusy(false);

    for (var order in orders) {
      if (order.taxiOrder != null) {
        //lobalVariable.updateCheckShowHomePage(1);
      }
      if (order.rentalVehicleRequests != null) {
        //GlobalVariable.updateCheckShowHomePage(1);
      }
    }
    print("GLOBAL CHECK AT home.vm.dart==> ${GlobalVariable.showHomePage}");
  }

  //
  // dispose() {
  //   super.dispose();
  //   homePageChangeStream.cancel();
  // }

  //
  onPageChanged(int index) {
    currentIndex = index;
    notifyListeners();
  }

  //
  onTabChange(int index) {
    try {
      currentIndex = index;
      pageViewController.animateToPage(
        currentIndex,
        duration: Duration(microseconds: 5),
        curve: Curves.bounceInOut,
      );
    } catch (error) {
      print("error ==> $error");
    }
    notifyListeners();
  }

  //
  handleAppLink() async {
    // Get any initial links
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();

    //
    if (initialLink != null) {
      final Uri deepLink = initialLink.link;
      openPageByLink(deepLink);
    }

    //
    FirebaseDynamicLinks.instance.onLink.listen(
      (dynamicLinkData) {
        //
        openPageByLink(dynamicLinkData.link);
      },
    ).onError(
      (error) {
        // Handle errors
        print("error opening link ==> $error");
      },
    );
  }

  //
  openPageByLink(Uri deepLink) async {
    final cleanLink = Uri.decodeComponent(deepLink.toString());
    if (cleanLink.contains(Api.appShareLink)) {
      //
      try {
        final isProductLink = cleanLink.contains("/product");
        final isVendorLink = cleanLink.contains("/vendor");
        final isServiceLink = cleanLink.contains("/service");
        final pathFragments = cleanLink.split("/");
        final dataId = pathFragments.last;

        if (isProductLink) {
          AlertService.showLoading();
          try {
            ProductRequest _productRequest = ProductRequest();
            Product product =
                await _productRequest.productDetails(int.parse(dataId));
            AlertService.stopLoading();
            if (!product.vendor.vendorType.slug.contains("commerce")) {
              Navigator.push(
                  viewContext,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailsPage(
                      product: product,
                    ),
                  ));
            } else {
              Navigator.push(
                viewContext,
                MaterialPageRoute(
                  builder: (context) => AmazonStyledCommerceProductDetailsPage(
                    product: product,
                  ),
                ),
              );
            }
          } catch (error) {
            print("error ==> $error");
            AlertService.stopLoading();
          }
        } else if (isVendorLink) {
          AlertService.showLoading();
          try {
            VendorRequest _vendorRequest = VendorRequest();
            Vendor vendor = await _vendorRequest.vendorDetails(
              int.parse(dataId),
              params: {'type': 'small'},
            );
            AlertService.stopLoading();
            Navigator.push(
              viewContext,
              MaterialPageRoute(
                builder: (context) => VendorDetailsPage(
                  vendor: vendor,
                ),
              ),
            );
          } catch (error) {
            print("error ==> $error");
            AlertService.stopLoading();
          }
        } else if (isServiceLink) {
          AlertService.showLoading();
          try {
            ServiceRequest _serviceRequest = ServiceRequest();
            Service service =
                await _serviceRequest.serviceDetails(int.parse(dataId));
            AlertService.stopLoading();
            Navigator.push(
              viewContext,
              MaterialPageRoute(
                builder: (context) => ServiceDetailsPage(service),
              ),
            );
          } catch (error) {
            print("error ==> $error");
            AlertService.stopLoading();
          }
        }
      } catch (error) {
        toastError("$error");
      }
    }
    print("Url Link ==> $cleanLink");
  }
}
