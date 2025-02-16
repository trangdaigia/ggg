import 'package:flutter/material.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/models/search.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/view_models/shared_ride.vm.dart';
import 'package:sod_user/views/pages/auth/login.page.dart';
import 'package:sod_user/views/pages/booking/booking.page.dart';
import 'package:sod_user/views/pages/callbackme/callbackme.page.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_address.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_address_detail.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_car_detail.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_car_photos.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_price.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_rental_options.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_requirement.dart';
import 'package:sod_user/views/pages/car_rental/add_rental_car/add_utilities.dart';
import 'package:sod_user/views/pages/car_rental/car_manage.dart/car_management.page.dart';
import 'package:sod_user/views/pages/car_rental/car_rental/pick_address.dart';
import 'package:sod_user/views/pages/car_rental/car_rental_management.page.dart';
import 'package:sod_user/views/pages/commerce/commerce.page.dart';
import 'package:sod_user/views/pages/food/food.page.dart';
import 'package:sod_user/views/pages/grocery/grocery.page.dart';
import 'package:sod_user/views/pages/real_estate/real_estate.page.dart';
import 'package:sod_user/views/pages/parcel/parcel.page.dart';
import 'package:sod_user/views/pages/pharmacy/pharmacy.page.dart';
import 'package:sod_user/views/pages/product/amazon_styled_commerce_product_details.page.dart';
import 'package:sod_user/views/pages/product/product_details.page.dart';
import 'package:sod_user/views/pages/search/product_search.page.dart';
import 'package:sod_user/views/pages/search/search.page.dart';
import 'package:sod_user/views/pages/search/service_search.page.dart';
import 'package:sod_user/views/pages/service/service.page.dart';
import 'package:sod_user/views/pages/shared_ride/search_share_ride.page.dart';
import 'package:sod_user/views/pages/taxi/taxi.page.dart';
import 'package:sod_user/views/pages/vendor/vendor.page.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_page.dart';

class NavigationService {
  static pageSelected(
    VendorType vendorType, {
    required BuildContext context,
    bool loadNext = true,
  }) async {
    Widget nextpage = vendorTypePage(
      vendorType,
      context: context,
    );

    //
    if (vendorType.authRequired && !AuthServices.authenticated()) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            required: true,
          ),
        ),
      );
      //
      if (result == null || !result) {
        return;
      }
    }
    //
    if (loadNext) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => nextpage,
        ),
      );
    }
  }

  static Widget vendorTypePage(
    VendorType vendorType, {
    required BuildContext context,
  }) {
    Widget homeView = VendorPage(vendorType);
    switch (vendorType.slug.toLowerCase()) {
      case "parcel":
        homeView = ParcelPage(vendorType);
        break;
      case "grocery":
        homeView = GroceryPage(vendorType);
        break;
      case "food":
        homeView = FoodPage(vendorType);
        break;
      case "pharmacy":
        homeView = PharmacyPage(vendorType);
        break;
      case "service":
        homeView = ServicePage(vendorType);
        break;
      case "booking":
        homeView = BookingPage(vendorType);
        break;
      case "taxi":
        homeView = TaxiPage(vendorType, true, false);
        break;
      case "rental driver":
        homeView = TaxiPage(vendorType, false, false);
        break;
      case "shipping":
        homeView = TaxiPage(vendorType, false, true);
        break;
      case "commerce":
        homeView = CommercePage(vendorType);
        break;
      case "shared ride":
        homeView = SearchRidePage();
        break;
      case "car rental":
      case "Car Rental":
        homeView = CarRentalManagementPage(vendorType: vendorType);
        break;
      case "call back me":
      case "Call Back Me":
        homeView = CallBackMePage(vendorType, true);
        break;
      case "jobfinder":
      case "Jobfinder":
        homeView = JobPage();
        break;
      case 'real estate':
      case "Real Estate":
        homeView = RealEstatePage(vendorType);
        break;
      default:
        homeView = VendorPage(vendorType);
        break;
    }
    return homeView;
  }

  ///special for product page
  Widget productDetailsPageWidget(Product product) {
    if (!product.vendor.vendorType.isCommerce) {
      return ProductDetailsPage(
        product: product,
      );
    } else {
      return AmazonStyledCommerceProductDetailsPage(
        product: product,
      );
    }
  }

  //
  Widget searchPageWidget(Search search) {
    if (search.vendorType == null) {
      return SearchPage(search: search);
    }
    //
    if (search.vendorType!.isProduct) {
      return ProductSearchPage(search: search);
    } else if (search.vendorType!.isService) {
      return ServiceSearchPage(search: search);
    } else {
      return SearchPage(search: search);
    }
  }

  Widget carRentalPage() {
    return PickAddressPage();
  }

  Widget carManagementPage() {
    return CarManagementPage();
  }

  Widget addCarRentalPage({
    required String type,
    required CarManagementViewModel model,
    SharedRideViewModel? shareRideModel,
  }) {
    if (type == "address") {
      return AddAddressPage(
        model: model,
        shareRideModel: shareRideModel,
      );
    } else if (type == "address_detail") {
      return AddAddressDetailPage(
        model: model,
      );
    } else if (type == "choose_photo") {
      return AddCarPhotosPage(
        model: model,
        shareRideModel: shareRideModel,
      );
    } else if (type == "utilities") {
      return AddUtilitiesPage(
        model: model,
        shareRideModel: shareRideModel,
      );
    } else if (type == "price") {
      return AddPricePage(
        model: model,
        shareRideModel: shareRideModel,
      );
    } else if (type == "requirement") {
      return AddRequirementPage(
        model: model,
        shareRideModel: shareRideModel,
      );
    } else if (type == "detail") {
      return AddCarDetailPage(
        model: model,
        shareRideModel: shareRideModel,
      );
    } else if (type == "rental_options") {
      return AddRentalOptions(
        model: model,
        shareRideModel: shareRideModel,
      );
    }
    return AddAddressPage(
      model: model,
      shareRideModel: shareRideModel,
    );
  }
}
