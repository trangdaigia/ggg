import 'package:basic_utils/basic_utils.dart';
import 'package:inspection/inspection.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class CustomFormBuilderValidator {
  //
  static String? required(dynamic value, {String? errorTitle}) {
    if (value == null ||
        (value is String && (value.isEmpty || value.trim().isEmpty))) {
      print('Lỗi ở value: ${value.toString()}');
      return errorTitle ?? 'This field cannot be empty'.tr();
    }
    return null;
  }

  //
  static String? email(String? value, {String? errorTitle}) {
    if (value == null || !EmailUtils.isEmail(value)) {
      return errorTitle ?? 'Invalid email address'.tr();
    }
    return null;
  }

  static String? numeric(String? value, {String? errorTitle}) {
    return inspection(
      value,
      "numeric",
      locale: translator.activeLocale.languageCode,
    );
    // if (value == null || double.tryParse(value) != null) {
    //   return errorTitle ?? 'This field must be numeric'.tr();
    // }
    // return null;
  }

  static String? compose(List<String?> validators) {
    for (var validatorResult in validators) {
      return validatorResult;
    }
    return null;
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
