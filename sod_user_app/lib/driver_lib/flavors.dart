enum Flavor {

  sod_delivery,
  sob_express_admin,
  suc365_driver,
  g47_driver,
  appvietsob_delivery,
  vasone_driver,
  fasthub_delivery,
  goingship_driver,
  grabxanh_driver,
  inux_driver
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.sod_delivery:
        return 'SOD Delivery';
      case Flavor.sob_express_admin:
        return 'SOB Express Admin';
      case Flavor.suc365_driver:
        return 'SUC365 Driver';
      case Flavor.g47_driver:
        return 'G47 Driver';
      case Flavor.appvietsob_delivery:
        return 'VietApp Tài Xế';
      case Flavor.vasone_driver:
        return 'Vasone Driver';
      case Flavor.fasthub_delivery:
        return 'Fasthub Delivery';
      case Flavor.goingship_driver:
        return 'Going Tài Xế';
      case Flavor.grabxanh_driver:
        return 'GrabXanh Tài Xế';
      case Flavor.inux_driver:
        return 'Inux Driver';
      default:
        return 'title';
    }
  }
}
