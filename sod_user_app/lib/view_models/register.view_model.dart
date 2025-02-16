import 'package:cool_alert/cool_alert.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/requests/auth.request.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/widgets/bottomsheets/account_verification_entry.dart';
import 'package:velocity_x/velocity_x.dart';

import 'base.view_model.dart';

class RegisterViewModel extends MyBaseViewModel {
  //
  AuthRequest _authRequest = AuthRequest();

  // FirebaseAuth auth = FirebaseAuth.instance;
  //the text editing controllers
  TextEditingController nameTEC =
      new TextEditingController(text: !kReleaseMode ? "John Doe" : "");
  TextEditingController emailTEC =
      new TextEditingController(text: !kReleaseMode ? "john@mail.com" : "");
  TextEditingController phoneTEC =
      new TextEditingController(text: !kReleaseMode ? "557484181" : "");
  TextEditingController passwordTEC =
      new TextEditingController(text: !kReleaseMode ? "password" : "");
  TextEditingController referralCodeTEC = new TextEditingController();
  TextEditingController taxCodeTEC =
      new TextEditingController(text: !kReleaseMode ? "123456789" : "");
  Country? selectedCountry;
  String? accountPhoneNumber;
  bool agreed = false;
  bool otpLogin = AppStrings.enableOTPLogin;

  RegisterViewModel(BuildContext context) {
    this.viewContext = context;
    this.selectedCountry = Country.parse(AppStrings.defaultCountryCode);
  }

  void initialise() async {
    try {
      String countryCode = await Utils.getCurrentCountryCode();
      this.selectedCountry = Country.parse(countryCode);
      notifyListeners();
    } catch (error) {
      print("Error when fetching Country Code: ${error}");
      
    this.selectedCountry = Country.parse(AppStrings.defaultCountryCode);
    }
  }

  //
  showCountryDialPicker() {
    showCountryPicker(
      context: viewContext,
      showPhoneCode: true,
      onSelect: countryCodeSelected,
    );
  }

  countryCodeSelected(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  void processRegister() async {
    //
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate() && agreed) {
      //
      //
      if (phoneTEC.text[0] == "0") {
        phoneTEC.text = phoneTEC.text.substring(1);
      }
      accountPhoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";
      final forbiddenWord = Utils.checkForbiddenWordsInString(nameTEC.text);
      if (forbiddenWord != null) {
        await CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Warning forbidden words".tr(),
          text: "Account information contains forbidden word".tr() +
              ": $forbiddenWord",
        );
        setBusy(false);
        return;
      }

      if (AppStrings.enableOTPLogin && AppStrings.otpGateway != "none") {
        if (AppStrings.isFirebaseOtp) {
          processFirebaseOTPVerification();
          print("Verify Account with Firebase OTP is turning on.");
          return;
        } else if (AppStrings.isCustomOtp) {
          print("Verify Account with Custom OTP is turning on.");
          processCustomOTPVerification();
          return;
        }
        finishAccountRegistration();
      } else {
        finishAccountRegistration();
      }
    }
  }

  //PROCESSING VERIFICATION
  processFirebaseOTPVerification() async {
    setBusy(true);
    //firebase authentication
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: accountPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // firebaseVerificationId = credential.verificationId;
        // verifyFirebaseOTP(credential.smsCode);
        finishAccountRegistration();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          viewContext.showToast(
              msg: "Invalid Phone Number".tr(), bgColor: Colors.red);
        } else {
          viewContext.showToast(
              msg: e.message ?? "Failed".tr(), bgColor: Colors.red);
        }
        //
        setBusy(false);
      },
      codeSent: (String verificationId, int? resendToken) async {
        firebaseVerificationId = verificationId;
        showVerificationEntry();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("codeAutoRetrievalTimeout called");
      },
    );
  }

  processCustomOTPVerification() async {
    setBusy(true);
    try {
      print(
          "Process Custom OTP Verify ==> ${AppStrings.otpGateway.toLowerCase()}");
      if (AppStrings.otpGateway.toLowerCase() == "fpt") {
        accountPhoneNumber = accountPhoneNumber!.substring(3);
        if (!accountPhoneNumber!.startsWith('0')) {
          accountPhoneNumber = "0" + accountPhoneNumber!;
        }
      }
      await _authRequest.sendOTP(accountPhoneNumber!);
      setBusy(false);
      showVerificationEntry();
    } catch (error) {
      setBusy(false);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
  }

  //
  void showVerificationEntry() async {
    //
    setBusy(false);
    //
    await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => AccountVerificationEntry(
          vm: this,
          phone: accountPhoneNumber!,
          onSubmit: (smsCode) {
            //
            if (AppStrings.isFirebaseOtp) {
              verifyFirebaseOTP(smsCode);
            } else if (AppStrings.isCustomOtp) {
              verifyCustomOTP(smsCode);
            }
            Navigator.pop(viewContext);
          },
          onResendCode: AppStrings.isCustomOtp
              ? () async {
                  try {
                    final response =
                        await _authRequest.sendOTP(accountPhoneNumber!);
                    toastSuccessful("${response.message}");
                  } catch (error) {
                    viewContext.showToast(msg: "$error", bgColor: Colors.red);
                  }
                }
              : () {},
        ),
      ),
    );
  }

  //
  void verifyFirebaseOTP(String smsCode) async {
    //
    setBusyForObject(firebaseVerificationId, true);

    // Sign the user in (or link) with the credential
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: firebaseVerificationId!,
        smsCode: smsCode,
      );

      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      await finishAccountRegistration();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(firebaseVerificationId, false);
  }

  void verifyCustomOTP(String smsCode) async {
    //
    setBusyForObject(firebaseVerificationId, true);
    // Sign the user in (or link) with the credential
    try {
      accountPhoneNumber = accountPhoneNumber!.replaceFirst('0', '+84');
      await _authRequest.verifyOTP(
          accountPhoneNumber!, AppStrings.enableOtp ? smsCode : "");
      await finishAccountRegistration();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(firebaseVerificationId, false);
  }

///////
  ///
  Future<void> finishAccountRegistration() async {
    setBusy(true);

    final apiResponse = await _authRequest.registerRequest(
      name: nameTEC.text,
      email: emailTEC.text.isEmpty ? null : emailTEC.text,
      phone: accountPhoneNumber!,
      countryCode: selectedCountry!.countryCode,
      password: passwordTEC.text,
      code: referralCodeTEC.text,
      taxCode: taxCodeTEC.text,
    );

    setBusy(false);

    try {
      if (apiResponse.hasError()) {
        //there was an error
        CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Registration Failed".tr(),
          text: apiResponse.message?.tr(),
        );
      } else {
        //everything works well
        //firebase auth
        final fbToken = apiResponse.body["fb_token"];
        await FirebaseAuth.instance.signInWithCustomToken(fbToken);
        await AuthServices.saveUser(apiResponse.body["user"]);
        await AuthServices.setAuthBearerToken(apiResponse.body["token"]);
        await AuthServices.isAuthenticated();
        Navigator.of(viewContext).pushNamedAndRemoveUntil(
          AppRoutes.homeRoute,
          (_) => false,
        );
      }
    } on FirebaseAuthException catch (error) {
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "Login Failed".tr(),
        text: "${error.message}",
      );
    } catch (error) {
      CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "Login Failed".tr(),
        text: error is Map ? "${error['message'] ?? error}" : "$error",
      );
    }
  }

  void openLogin() async {
    Navigator.pop(viewContext);
  }

  verifyRegistrationOTP(String text) {}
}
