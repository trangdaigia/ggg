import 'dart:io';

import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/services/app.service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sod_user/driver_lib/requests/auth.request.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

import '../requests/area.request.dart';

class EditProfileViewModel extends MyBaseViewModel {
  Driver? currentUser;
  File? newPhoto;
  //the textediting controllers
  TextEditingController nameTEC = new TextEditingController();
  TextEditingController emailTEC = new TextEditingController();
  TextEditingController phoneTEC = new TextEditingController();
  String? genderSelected = "male";

  Map<String, List<Map<String, String>>> areas = {
    'countries': [],
    'states': [],
    'cities': [],
  };

  //
  AuthRequest _authRequest = AuthRequest();
  final _areaRequest = AreaRequest();
  final picker = ImagePicker();

  EditProfileViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    //
    currentUser = await AuthServices.getCurrentDriver();
    print(currentUser?.toJson());
    nameTEC.text = currentUser!.user.name;
    emailTEC.text = currentUser!.user.email ?? "";
    phoneTEC.text = currentUser!.user.phone ?? "";

    void updateFormValue(String field, String? id) {
      final value = id == '-1' ? null : id;
      formBuilderKey.currentState?.fields[field]?.didChange(value);
    }

    // updateFormValue('country_id', currentUser!.user.countryId);
    // updateFormValue('state_id', currentUser!.user.stateId);
    // updateFormValue('city_id', currentUser!.user.cityId);

    fetchArea();
    notifyListeners();
  }

  //
  void changePhoto() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      newPhoto = File(pickedFile.path);
      //
      newPhoto = await AppService().compressFile(
        newPhoto!,
        quality: 30,
      );
    } else {
      newPhoto = null;
    }

    notifyListeners();
  }

  //
  processUpdate() async {
    //
    if (formBuilderKey.currentState!.saveAndValidate()) {
      //
      setBusy(true);

      //
      final apiResponse = await _authRequest.updateProfile(
        photo: newPhoto,
        name: nameTEC.text,
        email: emailTEC.text,
        phone: phoneTEC.text,
        gender: genderSelected,
        countryId: formBuilderKey.currentState?.fields['country_id']?.value,
        stateId: formBuilderKey.currentState?.fields['state_id']?.value,
        cityId: formBuilderKey.currentState?.fields['city_id']?.value,
      );

      //
      setBusy(false);

      //update local data if all good
      if (apiResponse.allGood) {
        //everything works well
        await AuthServices.saveUser(apiResponse.body["user"]);
      }

      //
      CoolAlert.show(
        context: viewContext,
        type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
        title: "Profile Update".tr(),
        text: apiResponse.message,
        onConfirmBtnTap: apiResponse.allGood
            ? () {
                //
                Navigator.pop(viewContext);
                Navigator.pop(viewContext, true);
              }
            : null,
      );
    }
  }

  changeGender(gender) {
    genderSelected = gender;
    notifyListeners();
  }

  Future<void> fetchArea() async {
    areas['countries'] = await _areaRequest.getCountries();

    notifyListeners();
  }

  Future<void> onSelectedCountry(String? countryId) async {
    if (countryId == null) return;

    // Đặt lại danh sách tỉnh và state_id và city_id
    areas['states'] = [];
    areas['cities'] = [];
    formBuilderKey.currentState?.fields['state_id']?.didChange(null);
    formBuilderKey.currentState?.fields['city_id']?.didChange(null);

    areas['states'] = await _areaRequest.getStates(countryId);

    notifyListeners();
  }

  Future<void> onSelectedState(String? stateId) async {
    if (stateId == null) return;

    // Đặt lại danh sách thành phố và city_id và giá trị city trong form về null
    areas['cities'] = [];
    formBuilderKey.currentState?.fields['city_id']?.didChange(null);

    print(stateId);
    areas['cities'] = await _areaRequest.getCities(stateId);

    notifyListeners();
  }

  void onSelectedCity(String? cityId) {
    if (cityId == null) return;

    notifyListeners();
  }
}
