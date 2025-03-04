import 'package:basic_utils/basic_utils.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:inspection/inspection.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class FormValidator {
  //For name form validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Invalid name'.tr();
    }
    return null;
  }

  //For email address form validation
  static String? validateEmail(String? value) {
    if (value == null || !EmailUtils.isEmail(value)) {
      return 'Invalid email address'.tr();
    }
    return null;
  }

  //For email address form validation
  static String? validatePhone(String? value, {String? name}) {
    return Inspection().inspect(
      value,
      'required|numeric|min:3|max:16',
      name: name,
      locale: translator.activeLocale.languageCode,
    );
  }

  //For email address form validation
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty || value.length < 6) {
      return 'Password must be more than 6 character'.tr();
    }
    return null;
  }

  static String? validateEmpty(String? value, {String? errorTitle}) {
    if (value == null || value.trim().isEmpty) {
      return '%s is empty'.tr().fill(["$errorTitle"]);
    }
    return null;
  }


  static String? validateDeliveryAddress(
    String value, {
    String? errorTitle,
    required DeliveryAddress deliveryaddress,
    required Vendor vendor,
  }) {
    print("Here");
    //
    final validation = validateEmpty(value, errorTitle: errorTitle);
    return validation;

    //cities,states & countries
    /*
    print("Countries ==> ${vendor.countries}");
    print("Countries ==> ${deliveryaddress.country}");
    final foundCountry = vendor.countries.firstWhere(
      (element) =>
          element.toLowerCase() == "${deliveryaddress.country}".toLowerCase(),
      orElse: () => null,
    );

    //
    return null;

    //states
    final foundState = vendor.states.firstWhere(
      (element) =>
          element.toLowerCase() == "${deliveryaddress.state}".toLowerCase(),
      orElse: () => null,
    );

    //
    return null;

    //cities
    final foundCity = vendor.cities.firstWhere(
      (element) =>
          element.toLowerCase() == "${deliveryaddress.city}".toLowerCase(),
      orElse: () => null,
    );

    //
    return null;
    return "Vendor does not service selected location".tr();
    */
  }

  static String? validateCustom(
    String? value, {
    String? name,
    String rules = "required",
  }) {
    return Inspection().inspect(
      value,
      rules,
      name: name,
      locale: translator.activeLocale.languageCode,
    );
  }
}
