import 'package:sod_user/models/category.dart';
import 'package:sod_user/models/tag.dart';
import 'package:sod_user/models/vendor_type.dart';

class Search {
  String? type = "";
  Category? category;
  Category? subcategory;
  VendorType? vendorType;
  int? vendorId;
  int? showType;
  SearchType? viewType;
  bool? byLocation = true;
  bool? showProductsTag = false;
  bool? showVendorsTag = false;
  bool? showServicesTag = false;
  bool? showProvidesTag = false;
  String? sort = "asc";
  String? layoutType = "grid";
  String? minPrice;
  String? maxPrice;
  List<Tag>? tags = [];

  Search({
    this.type = "",
    this.category,
    this.subcategory,
    this.vendorType,
    this.vendorId,
    this.showType,
    this.viewType = SearchType.vendorProducts,
  });

  void genApiType(int selectTagId) {
    switch (selectTagId) {
      case 1:
        type = "vendor";
        break;
      case 2:
        type = "product";
        break;
      case 3:
        type = "service";
        break;
      default:
        type = "product";
    }
  }

  bool showOnlyVendors() {
    // 1 = vendors
    // 2 = products
    // 3 = services
    // 4 = vendors & products
    // 5 = vendors & services
    return showType == 1;
  }

  bool showVendors() {
    List<int> showTypeCheckes = [1, 4, 5];
    List<SearchType> viewTypeCheckes = [
      SearchType.vendors,
      SearchType.vendorProducts,
      SearchType.vendorServices
    ];
    return viewTypeCheckes.contains(viewType) ||
        showTypeCheckes.contains(showType);
  }

  bool showProducts() {
    return ([SearchType.vendorProducts, SearchType.products]
            .contains(viewType)) ||
        [2, 4].contains(showType);
  }

  bool showServices() {
    return ([SearchType.vendorServices, SearchType.services]
            .contains(viewType)) ||
        [3, 5].contains(showType);
  }
}

enum SearchType {
  vendors,
  products,
  services,
  vendorProducts,
  vendorServices,
}

enum SearchFilterType {
  best,
  sales,
  you,
  fresh,
  discount,
  featured,
}
