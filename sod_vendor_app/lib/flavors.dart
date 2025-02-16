enum Flavor {
  sod_vendor,
  sob_express_vendor,
  suc365_vendor,
  g47_vendor,
  appvietsob_vendor,
  vasone_vendor,
  fasthub_vendor,
  goingship_vendor,
  grabxanh_vendor,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.sod_vendor:
        return 'SOD Vendor';
      case Flavor.sob_express_vendor:
        return 'SOB Express Vendor';
      case Flavor.suc365_vendor:
        return 'SUC365 Vendor';
      case Flavor.g47_vendor:
        return 'G47 Vendor';
      case Flavor.appvietsob_vendor:
        return 'VietApp Cửa Hàng';
      case Flavor.fasthub_vendor:
        return 'Fasthub Vendor';
      case Flavor.vasone_vendor:
        return 'Vasone Vendor';
      case Flavor.goingship_vendor:
        return 'Going Cửa Hàng';
      case Flavor.grabxanh_vendor:
        return 'GrabXanh Cửa Hàng';
      default:
        return 'title';
    }
  }

}
