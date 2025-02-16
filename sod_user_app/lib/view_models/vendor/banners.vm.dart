import 'package:flutter/material.dart' hide Banner;
import 'package:sod_user/models/banner.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/requests/banner.request.dart';
import 'package:sod_user/services/location.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/models/search.dart';
import 'package:velocity_x/velocity_x.dart';

class BannersViewModel extends MyBaseViewModel {
  BannersViewModel(
    BuildContext context,
    this.vendorType, {
    this.featured = false,
  }) {
    this.viewContext = context;
  }
  //
  BannerRequest _bannerRequest = BannerRequest();
  bool featured;
  VendorType? vendorType;
  //
  List<Banner> banners = [];
  int currentIndex = 0;

  //
  initialise() async {
    setBusy(true);
    try {
      print(LocationService.currenctAddress?.coordinates!.latitude ?? 0);
      print(LocationService.currenctAddress?.coordinates!.longitude ?? 0);
      banners = await _bannerRequest.banners(
        vendorTypeId: vendorType?.id,
        params: {
          "featured": featured ? "1" : "0",
          "latitude":
              LocationService.currenctAddress?.coordinates!.latitude ?? 0,
          "longitude":
              LocationService.currenctAddress?.coordinates!.longitude ?? 0,
        },
      );
      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  //
  bannerSelected(Banner banner) {
    if (banner.link != null && banner.link.isNotEmptyAndNotNull) {
      openWebpageLink(banner.link!);
    } else if (banner.vendor != null) {
      Navigator.of(viewContext).pushNamed(
        AppRoutes.vendorDetails,
        arguments: banner.vendor,
      );
    } else {
      Navigator.of(viewContext).pushNamed(
        AppRoutes.search,
        arguments: Search(category: banner.category),
      );
    }
  }
}
