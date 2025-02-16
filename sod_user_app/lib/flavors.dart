enum Flavor {
  sod_user,
  sob_express,
  suc365_user,
  g47_user,
  appvietsob_user,
  vasone,
  fasthub_user,
  goingship,
  grabxanh,
  inux,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.sod_user:
        return 'SOD User';
      case Flavor.sob_express:
        return 'SOB Express';
      case Flavor.suc365_user:
        return 'SUC365 User';
      case Flavor.g47_user:
        return 'G47 User';
      case Flavor.appvietsob_user:
        return 'VietApp';
      case Flavor.vasone:
        return 'Vasone';
      case Flavor.fasthub_user:
        return 'Fasthub User';
      case Flavor.goingship:
        return 'Goingship';
      case Flavor.grabxanh:
        return 'GoXanh';
      case Flavor.inux:
        return 'Inux';
      default:
        return 'title';
    }
  }

}
