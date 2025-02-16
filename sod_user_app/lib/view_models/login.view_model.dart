import 'dart:developer';

import 'package:cool_alert/cool_alert.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dartx/dartx.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/constants/app_text_styles.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/requests/auth.request.dart';
import 'package:sod_user/requests/vehicle.request.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/services/social_media_login.service.dart';
import 'package:sod_user/traits/qrcode_scanner.trait.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/forgot_password.view_model.dart';
import 'package:sod_user/views/pages/auth/forgot_password.page.dart';
import 'package:sod_user/views/pages/auth/phone_number.page.dart';
import 'package:sod_user/views/pages/auth/register.page.dart';
import 'package:sod_user/widgets/bottomsheets/account_verification_entry.dart';
import 'package:sod_user/widgets/bottomsheets/new_password_entry.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'base.view_model.dart';

import 'package:sod_user/driver_lib/services/auth.service.dart' as driverLib;

class LoginViewModel extends MyBaseViewModel with QrcodeScannerTrait {
  //the text editing controllers
  TextEditingController phoneTEC = new TextEditingController();
  TextEditingController emailTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();

  //
  AuthRequest authRequest = AuthRequest();
  VehicleRequest vehicleRequest = VehicleRequest();
  SocialMediaLoginService socialMediaLoginService = SocialMediaLoginService();
  bool otpLogin = AppStrings.enableOTPLogin;
  Country? selectedCountry;
  String? accountPhoneNumber;

  LoginViewModel(BuildContext context) {
    this.viewContext = context;
    selectedCountry = Country.parse(AppStrings.defaultCountryCode);
  }

  void initialise() async {
    //
    emailTEC.text = kReleaseMode ? "" : "client@di4l.vn";
    // emailTEC.text = kReleaseMode ? "" : "thanh.lehuu@di4l.vn";
    passwordTEC.text = kReleaseMode ? "" : "123456";

    //phone login
    try {
      String countryCode = await Utils.getCurrentCountryCode();
      this.selectedCountry = Country.parse(countryCode);
      notifyListeners();
    } catch (error) {
      this.selectedCountry = Country.parse(AppStrings.defaultCountryCode);
    }
  }

  toggleLoginType() {
    otpLogin = !otpLogin;
    notifyListeners();
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

  void processOTPLogin({withPassword = false}) async {
    try {
      //
      // Validate returns true if the form is valid, otherwise false.
      if (phoneTEC.text.isNotEmpty && phoneTEC.text[0] == "0")
        phoneTEC.text = phoneTEC.text.substring(1);
      if (formKey.currentState!.validate()) {
        //
        setBusyForObject(otpLogin, true);
        accountPhoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";

        if (withPassword) {
          final apiResponse = await authRequest.loginRequest(
            phone: accountPhoneNumber,
            password: passwordTEC.text,
          );
          if (!apiResponse.allGood) {
            await handleOTPLoginError(apiResponse);
            return;
          }
          await Future.wait([
            AuthServices.setTempPassword(passwordTEC.text),
            handleDeviceLogin(apiResponse)
          ] as Iterable<Future>);
          return;
        }
        //phone number verification
        final apiResponse = await authRequest.verifyPhoneAccount(
          accountPhoneNumber!,
        );

        if (!apiResponse.allGood) {
          handleOTPLoginError(apiResponse);
          return;
        }
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
    } finally {
      setBusyForObject(otpLogin, false);
      setBusy(false);
    }
  }

  handleOTPLoginError(ApiResponse apiResponse) async {
    if (apiResponse.message!.contains(accountPhoneNumber ?? '') ||
        apiResponse.message!.contains("exist")) {
      final result = await CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Login".tr(),
          text:
              "${apiResponse.message}. ${"Do you want to create new account?".tr()}",
          confirmBtnText: "Sign Up".tr(),
          cancelBtnText: "Retry".tr(),
          showCancelBtn: true,
          onConfirmBtnTap: () async {
            Navigator.of(AppService().navigatorKey.currentState!.context)
                .pop(true);
          },
          onCancelBtnTap: () =>
              Navigator.of(AppService().navigatorKey.currentState!.context)
                  .pop(false));
      if (result ?? false) openRegister(phone: phoneTEC.text);
    } else
      await CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Login".tr(),
          text: apiResponse.message);
    return;
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
        log("Error message ==> ${e.message}");
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
      await authRequest.sendOTP(accountPhoneNumber!);
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
              final response = await authRequest.sendOTP(accountPhoneNumber!);
              toastSuccessful(
                  response.message ?? "Code sent successfully".tr());
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
      final apiResponse = await authRequest.verifyOTP(
        accountPhoneNumber!,
        smsCode,
        isLogin: changePassword,
      );
      if (!apiResponse.allGood) throw Exception(apiResponse.message);
      if (changePassword) {
        await showModalBottomSheet(
          context: viewContext,
          isScrollControlled: true,
          constraints: BoxConstraints.tightFor(width: double.infinity),
          builder: (context) {
            return ViewModelBuilder<ForgotPasswordViewModel>.reactive(
              viewModelBuilder: () => ForgotPasswordViewModel(context),
              onViewModelReady: (model) => model.initialise(),
              builder: (context, viewModel, child) => Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: NewPasswordEntry(
                    vm: viewModel,
                    onSubmit: (password) {
                      finishChangeAccountPassword(apiResponse.body['token']);
                      Navigator.pop(viewContext);
                    },
                  )),
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
    final apiResponse = await authRequest.resetPasswordRequest(
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
      final apiResponse = await authRequest.verifyFirebaseToken(
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

  //REGULAR LOGIN
  void processLogin() async {
    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      //
      setBusy(true);
      final apiResponse = await authRequest.loginRequest(
        email: emailTEC.text,
        password: passwordTEC.text,
      );
      await AuthServices.setTempPassword(passwordTEC.text);
      //
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
        final apiResponse = await authRequest.qrLoginRequest(
          code: loginCode,
        );
        //
        await handleDeviceLogin(apiResponse);
      } catch (error) {
        print("QR Code login error ==> $error");
      }
      setBusy(false);
    }
  }

  ///
  ///
  ///
  Future<dynamic> handleDeviceLogin(ApiResponse apiResponse) async {
    try {
      if (apiResponse.hasError()) {
        //there was an error
        await AuthServices.removeTempPassword();
        CoolAlert.show(
          context: viewContext,
          type: CoolAlertType.error,
          title: "Login Failed".tr(),
          text: apiResponse.message,
        );
      } else {
        if (AuthServices.currentUser != null) {
          print("Current User when Login is ==> ${AuthServices.currentUser}");
          AuthServices.currentUser = null;
        }
        //everything works well
        //firebase auth
        setBusy(true);
        final fbToken = apiResponse.body["fb_token"];
        await AuthServices.setAuthBearerToken(apiResponse.body["token"]);
        if (apiResponse.body['user']["phone"] == null ||
            apiResponse.body['user']["phone"]!.isEmpty) {
          setBusy(false);
          final result =
              (await Navigator.of(viewContext).push<bool>(MaterialPageRoute(
                      builder: (context) => PhoneNumberInputPage(
                            model: this,
                          )))) ??
                  false;
          if (!result) throw "You need to provide phone number to continue";
          setBusy(true);
          final updateProfileApiResponse = await authRequest.updateProfile(
              phone: accountPhoneNumber,
              email: apiResponse.body["user"]['email'],
              name: apiResponse.body['user']['name']);
          if (!updateProfileApiResponse.allGood) {
            AuthServices.setAuthBearerToken("");
            throw updateProfileApiResponse.message ?? "";
          } else {
            apiResponse.body['user']["phone"] = accountPhoneNumber!;
          }
        }
        (await Future.wait([
          AuthServices.isAuthenticated(),
          FirebaseAuth.instance.signInWithCustomToken(fbToken)
        ]));
        final currentUser =
            await AuthServices.saveUser(apiResponse.body["user"]);
        final documentRequest = currentUser?.documentRequest;
        if ((documentRequest == null || documentRequest.status != "pending"))
          AuthServices.setIsDriverWaitingForApproval(false);
        else
          AuthServices.setIsDriverWaitingForApproval(true);
        if (currentUser?.roles.firstOrNullWhere((e) => e.name == "driver") !=
            null) {
          final vehicles = await vehicleRequest.vehicles();
          apiResponse.body["user"]['vehicles'] =
              vehicles.map((e) => e.toJson()).toList();
          print(apiResponse.body["user"]['vehicles']);
          final driver =
              await AuthServices.saveDriver(apiResponse.body["user"]);
          await Future.wait([
            // driverLib.AuthServices.saveVehicle(driver.vehicle?.toJson()),
          ]);
          await Future.wait([
            driverLib.AuthServices.syncDriverData(driver!),
            driverLib.AuthServices.setAuthBearerToken(
                apiResponse.body['token']),
            driverLib.AuthServices.isAuthenticated()
          ]);
        }
        //go to home
        setBusy(false);
        Navigator.of(AppService().navigatorKey.currentState!.context)
            .pushNamedAndRemoveUntil(
          AppRoutes.homeRoute,
          (route) => route.isFirst,
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
      String errorMessage;

      if (error is Error) {
        print("Error when logging in: ${error.stackTrace}");
        errorMessage = "An unexpected error occurred!";
      } else if (error is Exception) {
        errorMessage = error.toString();
      } else if (error is String) {
        errorMessage = error;
      } else {
        errorMessage = "Unknown error occurred!";
      }

      CoolAlert.show(
        context: AppService().navigatorKey.currentState!.context,
        type: CoolAlertType.error,
        title: "Login Failed".tr(),
        text: errorMessage,
      );
    } finally {
      notifyListeners();
      setBusy(false);
    }
  }

  ///
  openRegister({
    String? email,
    String? name,
    String? phone,
  }) async {
    await Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder: (context) => RegisterPage(
          email: email,
          name: name,
          phone: phone,
        ),
      ),
    );
    return;
  }

  void openForgotPassword() {
    Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder: (context) => ForgotPasswordPage(),
      ),
    );
  }

  Future<bool> verifyPhoneNumber() async {
    try {
      setBusy(true);
      final phoneNumber = "+${selectedCountry?.phoneCode}${phoneTEC.text}";
      final apiResponse = await authRequest.verifyPhoneAccount(phoneNumber);
      if (!apiResponse.allGood && apiResponse.code == 400) {
        accountPhoneNumber = phoneTEC.text;
        if (AppStrings.enableOTPLogin) {
          if (AppStrings.isFirebaseOtp) {
            print("Login with Firebase OTP is turning on!!!");
            return processFirebaseOTPVerification(changePassword: false);
          }
          if (AppStrings.isCustomOtp) {
            print("Login with OTP is turning on!!!");
            return processCustomOTPVerification(changePassword: false);
          }
        }
        return true;
      } else {
        CoolAlert.show(
            context: AppService().navigatorKey.currentContext!,
            type: CoolAlertType.error,
            title: "Register phone number",
            text: "The phone number is already been registered");
        return false;
      }
    } finally {
      setBusy(false);
    }
  }
}
