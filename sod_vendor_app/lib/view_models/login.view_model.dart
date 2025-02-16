import 'package:cool_alert/cool_alert.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_vendor/constants/app_routes.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/constants/app_text_styles.dart';
import 'package:sod_vendor/models/api_response.dart';
import 'package:sod_vendor/requests/auth.request.dart';
import 'package:sod_vendor/services/auth.service.dart';
import 'package:sod_vendor/traits/qrcode_scanner.trait.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:sod_vendor/view_models/forgot_password.view_model.dart';
import 'package:sod_vendor/views/pages/auth/register.page.dart';
import 'package:sod_vendor/widgets/bottomsheets/account_verification_entry.dart';
import 'package:sod_vendor/widgets/bottomsheets/new_password_entry.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import 'base.view_model.dart';

class LoginViewModel extends MyBaseViewModel with QrcodeScannerTrait {
  //the text editing controllers
  TextEditingController emailTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();
  TextEditingController phoneTEC = new TextEditingController();
  Country? selectedCountry;
  bool otpLogin = AppStrings.enableOTPLogin;
  String? accountPhoneNumber;

  //
  AuthRequest _authRequest = AuthRequest();

  LoginViewModel(BuildContext context) {
    this.viewContext = context;
  }

  void initialise() async {
    //
    emailTEC.text = kReleaseMode ? "" : "manager@di4l.vn";
    passwordTEC.text = kReleaseMode ? "" : "123456";
    try {
      String countryCode = await Utils.getCurrentCountryCode();
      this.selectedCountry = Country.parse(countryCode);
      notifyListeners();
    } catch (error) {
      final code = AppStrings.countryCode
          .toUpperCase()
          .replaceAll("AUTO", "")
          .replaceAll("INTERNATIONAL", "")
          .split(",")[0];
      this.selectedCountry = Country.parse(code.toLowerCase());
    }
  }

  void processLogin() async {
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      //

      setBusy(true);

      final apiResponse = await _authRequest.loginRequest(
        email: emailTEC.text,
        password: passwordTEC.text,
      );
      await handleDeviceLogin(apiResponse);

      setBusy(false);
    }
  }

  //QRCode login
  void initateQrcodeLogin() async {
    //
    final loginCode = await openScanner(viewContext);
    if (loginCode == null) {
      toastError("Operation failed/cancelled".tr());
    } else {
      setBusy(true);

      try {
        final apiResponse = await _authRequest.qrLoginRequest(
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

  ///
  ///
  ///
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
        // Clear data on the Old user.
        if (AuthServices.currentUser != null) {
          print("Current User when Login is ==> ${AuthServices.currentUser}");
          AuthServices.currentUser = null;
        }

        //everything works well
        //firebase auth
        final fbToken = apiResponse.body["fb_token"];
        await FirebaseAuth.instance.signInWithCustomToken(fbToken);
        await AuthServices.saveUser(apiResponse.body["user"]);
        await AuthServices.saveVendor(apiResponse.body["vendor"]);
        await AuthServices.setAuthBearerToken(apiResponse.body["token"]);
        await AuthServices.isAuthenticated();
        Navigator.of(viewContext).pushNamedAndRemoveUntil(
          AppRoutes.homeRoute,
          (route) => false,
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
        text: "$error",
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
    /*
    final url = Api.register;
    openExternalWebpageLink(url);
    */
  }

  void processOTPLogin({withPassword = false}) async {
    //
    // Validate returns true if the form is valid, otherwise false.
    if (phoneTEC.text.isNotEmpty && phoneTEC.text[0] == "0")
      phoneTEC.text = phoneTEC.text.substring(1);
    if (formKey.currentState!.validate()) {
      //
      accountPhoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";
      if (withPassword) {
        final apiResponse = await _authRequest.loginRequest(
          phone: accountPhoneNumber,
          password: passwordTEC.text,
        );
        await handleDeviceLogin(apiResponse);
        return;
      }
      setBusyForObject(otpLogin, true);
      //phone number verification
      final apiResponse = await _authRequest.verifyPhoneAccount(
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
        print("Login with Firebase OTP is turning on!!!");
        processFirebaseOTPVerification();
        return;
      }
      if (AppStrings.isCustomOtp) {
        print("Login with OTP is turning on!!!");
        processCustomOTPVerification();
        return;
      }
    }
  }

  //PROCESSING VERIFICATION
  Future<bool> processFirebaseOTPVerification(
      {bool changePassword = true}) async {
    setBusyForObject(otpLogin, true);
    bool result = false;
    //firebase authentication
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: accountPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // firebaseVerificationId = credential.verificationId;
        // verifyFirebaseOTP(credential.smsCode);
        print("verificationCompleted ==>  Yes");
        result = true;
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
        showVerificationEntry(changePassword: changePassword);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        print("codeAutoRetrievalTimeout called");
      },
    );
    setBusyForObject(otpLogin, false);
    return result;
  }

  Future<bool> processCustomOTPVerification({changePassword = true}) async {
    setBusyForObject(otpLogin, true);
    try {
      print("OTP Gateway ==> ${AppStrings.otpGateway.toLowerCase()}");
      if (AppStrings.otpGateway.toLowerCase() == "fpt") {
        accountPhoneNumber = accountPhoneNumber!.substring(3);
        if (!accountPhoneNumber!.startsWith('0')) {
          accountPhoneNumber = "0" + accountPhoneNumber!;
        }
      }
      await _authRequest.sendOTP(accountPhoneNumber!);
      return showVerificationEntry(changePassword: changePassword);
    } catch (error) {
      viewContext.showToast(
          msg: "$error", bgColor: Colors.red, textColor: Colors.white);
      return false;
    } finally {
      setBusyForObject(otpLogin, false);
    }
  }

  //
  Future<bool> showVerificationEntry({changePassword = true}) async {
    //
    setBusy(false);
    //
    final result = await Navigator.push<bool>(
      viewContext,
      MaterialPageRoute(
        builder: (context) => AccountVerificationEntry(
          vm: this,
          phone: accountPhoneNumber!,
          onSubmit: (smsCode) async {
            //
            bool verificationResult = false;
            if (AppStrings.isFirebaseOtp) {
              verificationResult = await verifyFirebaseOTP(smsCode,
                  changePassword: changePassword);
            } else {
              verificationResult = await verifyCustomOTP(smsCode,
                  changePassword: changePassword);
            }
            Navigator.pop(viewContext, verificationResult);
          },
          onResendCode: () async {
            if (!AppStrings.isCustomOtp) {
              return;
            }
            try {
              final response = await _authRequest.sendOTP(accountPhoneNumber!);
              toastSuccessful(response.message);
            } catch (error) {
              viewContext.showToast(msg: "$error", bgColor: Colors.red);
            }
          },
        ),
      ),
    );
    return result ?? false;
  }

  //
  Future<bool> verifyFirebaseOTP(String smsCode,
      {changePassword = true}) async {
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
      await finishOTPLogin(phoneAuthCredential, changePassword: changePassword);
      return true;
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
      return false;
    } finally {
      setBusyForObject(otpLogin, false);
    }
    //
  }

  Future<bool> verifyCustomOTP(String smsCode, {changePassword = true}) async {
    //
    setBusy(true);
    // Sign the user in (or link) with the credential
    try {
      accountPhoneNumber = accountPhoneNumber!.replaceFirst('0', '+84');
      final apiResponse = await _authRequest.verifyOTP(
        accountPhoneNumber!,
        smsCode,
        isLogin: changePassword,
      );
      if (!apiResponse.allGood) throw Exception(apiResponse.message);
      if (apiResponse.body["user"]["role_name"] != "manager") {
        await CoolAlert.show(
            context: viewContext,
            type: CoolAlertType.error,
            title: "Login".tr(),
            text: translator.translate(
                "Your phone number is already been registered. Please contact us via Zalo or our hotline for support. We're here to assist you!",
                {"emergencyHotline": AppStrings.emergencyContact}));
        return false;
      }
      if (changePassword) {
        await showModalBottomSheet(
          context: viewContext,
          isScrollControlled: true,
          constraints: BoxConstraints.tightFor(width: double.infinity),
          builder: (context) {
            return ViewModelBuilder<ForgotPasswordViewModel>.reactive(
              viewModelBuilder: () => ForgotPasswordViewModel(context),
              onViewModelReady: (model) => model.initialise(),
              builder: (context, viewModel, child) => NewPasswordEntry(
                vm: viewModel,
                onSubmit: (password) {
                  finishChangeAccountPassword(apiResponse.body['token']);
                  Navigator.pop(viewContext);
                },
              ),
            );
          },
        );
        await handleDeviceLogin(apiResponse);
        return true;
      } else {
        return true;
      }
    } catch (error) {
      print("ERROR when Verify with Custom OTP ==> $error}");
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
      return false;
    } finally {
      setBusy(false);
    }
    //
  }

  finishChangeAccountPassword(firebaseToken) async {
    //
    setBusy(true);
    final apiResponse = await _authRequest.resetPasswordRequest(
      phone: accountPhoneNumber!,
      password: passwordTEC.text,
      firebaseToken: !AppStrings.isCustomOtp ? firebaseToken : null,
      customToken: AppStrings.isCustomOtp ? firebaseToken : null,
    );
    setBusy(false);

    CoolAlert.show(
      context: viewContext,
      type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
      title: "Change Password".tr(),
      text: apiResponse.message,
      onConfirmBtnTap: () {
        Navigator.of(viewContext).popUntil((route) => route.isFirst);
      },
    );
  }

  //Login to with firebase token
  finishOTPLogin(AuthCredential authCredential, {changePassword = true}) async {
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
      final apiResponse = await _authRequest.verifyFirebaseToken(
        accountPhoneNumber!,
        firebaseToken!,
      );
      if (changePassword)
        await showModalBottomSheet(
          context: viewContext,
          isScrollControlled: true,
          constraints: BoxConstraints.tightFor(width: double.infinity),
          builder: (context) {
            return ViewModelBuilder<ForgotPasswordViewModel>.reactive(
              viewModelBuilder: () => ForgotPasswordViewModel(context),
              onViewModelReady: (model) => model.initialise(),
              builder: (context, viewModel, child) => NewPasswordEntry(
                vm: viewModel,
                onSubmit: (password) {
                  finishChangeAccountPassword(apiResponse.body['token']);
                  Navigator.pop(viewContext);
                },
              ),
            );
          },
        );
      //
      await handleDeviceLogin(apiResponse);
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(otpLogin, false);
  }

  showCountryDialPicker() {
    showCountryPicker(
      //Chỉnh lại textField tìm kiếm
      countryListTheme: CountryListThemeData(
        backgroundColor: Colors.grey.shade800,
        textStyle: AppTextStyle.h4TitleTextStyle(
          fontWeight: FontWeight.w400,
          color: Theme.of(viewContext).textTheme.bodyLarge!.color,
        ),
        // Optional. Sets the border radius for the bottom sheet.
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
}
