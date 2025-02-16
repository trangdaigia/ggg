import 'package:cool_alert/cool_alert.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/constants/app_routes.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/constants/app_text_styles.dart';
import 'package:sod_user/driver_lib/models/api_response.dart';
import 'package:sod_user/driver_lib/models/user.dart';
import 'package:sod_user/driver_lib/requests/auth.request.dart';
import 'package:sod_user/driver_lib/services/auth.service.dart';
import 'package:sod_user/driver_lib/traits/qrcode_scanner.trait.dart';
import 'package:sod_user/driver_lib/utils/hive.utils.dart';
import 'package:sod_user/driver_lib/utils/utils.dart';
import 'package:sod_user/driver_lib/views/pages/auth/register.page.dart';
import 'package:sod_user/driver_lib/views/pages/permission/permission.page.dart';
import 'package:sod_user/driver_lib/widgets/bottomsheets/account_verification_entry.dart';
import 'package:velocity_x/velocity_x.dart';

import 'base.view_model.dart';

class LoginViewModel extends MyBaseViewModel with QrcodeScannerTrait {
  //the text editing controllers
  TextEditingController emailTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();
  TextEditingController phoneTEC = new TextEditingController();
  late Country selectedCountry;
  String? accountPhoneNumber;
  bool otpLogin = false;

  //
  AuthRequest authRequest = AuthRequest();

  LoginViewModel(BuildContext context) {
    this.viewContext = context;
    final code = AppStrings.countryCode
        .toUpperCase()
        .replaceAll("AUTO", "")
        .replaceAll("INTERNATIONAL", "")
        .split(",")[0];
    this.selectedCountry = Country.parse(code.toLowerCase());
  }

  void initialise() async {
    //
    emailTEC.text = kReleaseMode ? "" : "driver@di4l.vn";
    passwordTEC.text = kReleaseMode ? "" : "123456";

    //
    //phone login
    try {
      String? countryCode = await Utils.getCurrentCountryCode();
      this.selectedCountry = Country.parse(countryCode);
    } catch (error) {
      this.selectedCountry = Country.parse("us");
    }
    notifyListeners();
  }

  void processLogin() async {
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      //
      setBusy(true);
      final apiResponse = await authRequest.loginRequest(
        email: emailTEC.text,
        password: passwordTEC.text,
      );
      await handleDeviceLogin(apiResponse);
      //
      setBusy(false);
    }
  }

  toggleLoginType() {
    otpLogin = !otpLogin;
    notifyListeners();
  }

  //START OTP RELATED METHODS
  showCountryDialPicker() {
    showCountryPicker(
      //Chỉnh lại textField tìm kiếm
      countryListTheme: CountryListThemeData(
        backgroundColor: Colors.grey.shade800,
        textStyle: AppTextStyle.h4TitleTextStyle(
          fontWeight: FontWeight.w400,
          color: Theme.of(viewContext).textTheme.bodyLarge!.color,
        ),
        // Optional. Sets the border radius for the bottomsheet.
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        searchTextStyle: AppTextStyle.h4TitleTextStyle(
          fontWeight: FontWeight.w400,
          color: Theme.of(viewContext).textTheme.bodyLarge!.color,
        ),
        // Optional. Styles the search field.
        inputDecoration: InputDecoration(
          labelText: 'Search',
          labelStyle: AppTextStyle.h5TitleTextStyle(
              color: Theme.of(viewContext).textTheme.bodyLarge!.color),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(viewContext).textTheme.bodyLarge!.color!,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(viewContext).textTheme.bodyLarge!.color!,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(viewContext).textTheme.bodyLarge!.color!,
            ),
          ),
        ),
      ),
      //
      context: viewContext,
      showPhoneCode: true,
      onSelect: countryCodeSelected,
    );
  }

  countryCodeSelected(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  void processOTPLogin() async {
    //
    accountPhoneNumber = "+${selectedCountry.phoneCode}${phoneTEC.text}";
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      setBusyForObject(otpLogin, true);
      //phone number verification
      final apiResponse = await authRequest.verifyPhoneAccount(
        accountPhoneNumber!,
      );

      if (!apiResponse.allGood) {
        CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Login".tr(),
          text: apiResponse.message,
        );
        setBusyForObject(otpLogin, false);
        return;
      }

      setBusyForObject(otpLogin, false);
      //
      if (AppStrings.isFirebaseOtp) {
        processFirebaseOTPVerification();
      } else {
        processCustomOTPVerification();
      }
    }
  }

  //PROCESSING VERIFICATION
  processFirebaseOTPVerification() async {
    setBusyForObject(otpLogin, true);
    //firebase authentication
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: accountPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // firebaseVerificationId = credential.verificationId;
        // verifyFirebaseOTP(credential.smsCode);
        print("verificationCompleted ==>  Yes");
        // finishOTPLogin(credential);
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
        setBusyForObject(otpLogin, false);
      },
      codeSent: (String verificationId, int? resendToken) async {
        firebaseVerificationId = verificationId;
        print("codeSent ==>  $firebaseVerificationId");
        showVerificationEntry();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("codeAutoRetrievalTimeout called");
      },
    );
    setBusyForObject(otpLogin, false);
  }

  processCustomOTPVerification() async {
    setBusyForObject(otpLogin, true);
    try {
      if (AppStrings.otpGateway.toLowerCase() == "fpt") {
        accountPhoneNumber = accountPhoneNumber!.substring(3);
        if (!accountPhoneNumber!.startsWith('0')) {
          accountPhoneNumber = "0" + accountPhoneNumber!;
        }
      }

      await authRequest.sendOTP(accountPhoneNumber!);
      setBusyForObject(otpLogin, false);
      showVerificationEntry();
    } catch (error) {
      setBusyForObject(otpLogin, false);
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
            } else {
              verifyCustomOTP(smsCode);
            }

            Navigator.pop(viewContext);
          },
          onResendCode: AppStrings.isCustomOtp
              ? () async {
                  try {
                    final response =
                        await authRequest.sendOTP(accountPhoneNumber!);
                    toastSuccessful(response.message ?? "Success".tr());
                  } catch (error) {
                    viewContext.showToast(msg: "$error", bgColor: Colors.red);
                  }
                }
              : null,
        ),
      ),
    );
  }

  //
  void verifyFirebaseOTP(String smsCode) async {
    //
    setBusyForObject(otpLogin, true);

    // Sign the user in (or link) with the credential
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
        verificationId: firebaseVerificationId!,
        smsCode: smsCode,
      );

      //
      await finishOTPLogin(phoneAuthCredential);
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(otpLogin, false);
  }

  void verifyCustomOTP(String smsCode) async {
    //
    setBusy(true);
    // Sign the user in (or link) with the credential
    try {
      accountPhoneNumber = accountPhoneNumber!.replaceFirst('0', '+84');
      final apiResponse = await authRequest.verifyOTP(
        accountPhoneNumber!,
        smsCode,
        isLogin: true,
      );

      //
      await handleDeviceLogin(apiResponse);
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusy(false);
  }

  //Login to with firebase token
  finishOTPLogin(AuthCredential authCredential) async {
    //
    setBusyForObject(otpLogin, true);
    // Sign the user in (or link) with the credential
    try {
      //
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        authCredential,
      );
      //
      String? firebaseToken = await userCredential.user!.getIdToken();
      final apiResponse = await authRequest.verifyFirebaseToken(
        accountPhoneNumber!,
        firebaseToken!,
      );
      //
      await handleDeviceLogin(apiResponse);
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(otpLogin, false);
  }

//END OTP RELATED METHODS

  //QRCode login
  void initateQrcodeLogin() async {
    //
    final loginCode = await openScanner(viewContext);
    if (loginCode == null) {
      toastError("Operation failed/cancelled".tr());
    } else {
      setBusy(true);

      try {
        final apiResponse = await authRequest.qrLoginRequest(
          code: loginCode,
        );
        //
        handleDeviceLogin(apiResponse);
      } catch (error) {
        print("QR Code login error ==> $error");
      }

      setBusy(false);
    }
  }

  handleDeviceLogin(ApiResponse apiResponse) async {
    try {
      if (apiResponse.hasError()) {
        //there was an error
        CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Login Failed".tr(),
          text: apiResponse.message,
        );
      } else {
        if (AuthServices.currentUser != null) {
          AuthServices.currentUser = null;
        }
        //check it the user is a driver
        final user = User.fromJson(apiResponse.body["user"]);
        if (user.role != "driver") {
          CoolAlert.show(
            context: viewContext,
            type: CoolAlertType.error,
            title: "Login Failed".tr(),
            text: "Unauthorized user access".tr(),
          );
          return;
        }
        //everything works well
        //firebase auth
        final fbToken = apiResponse.body["fb_token"];
        await FirebaseAuth.instance.signInWithCustomToken(fbToken);
        final driver = await AuthServices.saveUser(apiResponse.body["user"]);
        if (driver.isTaxiDriver && apiResponse.body["vehicle"] != null) {
          await AuthServices.saveVehicle(apiResponse.body["vehicle"]);
          await AuthServices.syncDriverData(apiResponse.body);
        }
        await AuthServices.setAuthBearerToken(apiResponse.body["token"]);
        await AuthServices.isAuthenticated();
        await Hive.deleteFromDisk();
        // Navigator.of(viewContext).pushNamedAndRemoveUntil(
        //   AppRoutes.homeRoute,
        //   (route) => false,
        // );
        viewContext.nextAndRemoveUntilPage(PermissionPage());
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
        text: "${error}",
      );
    }
  }

  void openForgotPassword() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.forgotPasswordRoute,
    );
  }

  void openRegistrationlink() async {
    viewContext.nextPage(RegisterPage());
    //final url = Api.register;
    // openExternalWebpageLink(url);
  }
}
