import 'package:cool_alert/cool_alert.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sim_country_code/flutter_sim_country_code.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/requests/auth.request.dart';
import 'package:sod_vendor/widgets/bottomsheets/account_verification_entry.dart';
import 'package:sod_vendor/widgets/bottomsheets/new_password_entry.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import '../constants/app_text_styles.dart';
import 'base.view_model.dart';
import 'package:velocity_x/velocity_x.dart';

class ForgotPasswordViewModel extends MyBaseViewModel {
  //the textediting controllers
  TextEditingController phoneTEC = new TextEditingController();
  TextEditingController passwordTEC = new TextEditingController();
  TextEditingController emailTEC = new TextEditingController();

  AuthRequest _authRequest = AuthRequest();
  FirebaseAuth auth = FirebaseAuth.instance;
  late Country selectedCountry;
  String? accountPhoneNumber;
  String? emailAddress;
  //
  String? firebaseToken;
  String? firebaseVerificationId;
  String? emailResetToken;

  ForgotPasswordViewModel(BuildContext context) {
    this.viewContext = context;
    this.selectedCountry = Country.parse(
      "us",
    );
  }

  void initialise() async {
    try {
      this.selectedCountry = Country.parse(
        await FlutterSimCountryCode.simCountryCode ?? "US",
      );
    } catch (error) {
      print(error);
    } finally {
      notifyListeners();
    }
  }

//
  showCountryDialPicker() {
    showCountryPicker(
      //Chỉnh lại textField tìm kiếm
      countryListTheme: CountryListThemeData(
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

  //
  countryCodeSelected(Country country) {
    selectedCountry = country;
    notifyListeners();
  }

  //verify on the server to see if there is an account associated with the supplied phone number
  processForgotPassword() async {
    accountPhoneNumber = "+${selectedCountry.phoneCode}${phoneTEC.text}";
    emailAddress = emailTEC.text.trim();

    // Validate returns true if the form is valid, otherwise false.
    if (formKey.currentState!.validate()) {
      //
      setBusy(true);
      // check if enable otp is enable
      if (AppStrings.enableEmailLogin && !AppStrings.enableOtp) {
        // Check if email is registered
        final apiResponse =
            await _authRequest.verifyEmailAccount(emailAddress!);
        if (apiResponse.allGood) {
          // if email is registered
          processEmailForgotPassword(emailAddress!);
        } else {
          CoolAlert.show(
            context: viewContext,
            type: CoolAlertType.error,
            title: "Forgot Password".tr(),
            text: apiResponse.message,
          );
        }
      } else {
        if (AppStrings.otpGateway == "none") {
          await CoolAlert.show(
              context: viewContext,
              type: CoolAlertType.info,
              title: "Forget Password".tr(),
              text: translator.translate(
                  "Forgot your password? Please contact us via Zalo or our hotline for support. We're here to assist you!",
                  {"contact": AppStrings.emergencyContact}));
          Navigator.of(viewContext).pop();
          setBusy(false);
          return;
        }
        final apiResponse =
            await _authRequest.verifyPhoneAccount(accountPhoneNumber!);
        if (apiResponse.allGood) {
          //
          final phoneNumber = apiResponse.body["phone"];
          accountPhoneNumber = phoneNumber;
          if (!AppStrings.isCustomOtp) {
            processFirebaseForgotPassword(phoneNumber);
          } else {
            processCustomForgotPassword(phoneNumber);
          }
        } else {
          CoolAlert.show(
            context: viewContext,
            type: CoolAlertType.error,
            title: "Forgot Password".tr(),
            text: apiResponse.message,
          );
        }
      }
      setBusy(false);
    }
  }

  //initiate the otp sending to provided phone
  processFirebaseForgotPassword(String phoneNumber) async {
    setBusy(true);

    //
    //firebase authentication
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        //
        UserCredential userCredential = await auth.signInWithCredential(
          credential,
        );

        //fetch user id token
        firebaseToken = await userCredential.user?.getIdToken();
        firebaseVerificationId = credential.verificationId;

        //
        setBusy(false);
        showNewPasswordEntry();
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          viewContext.showToast(msg: "Invalid Phone Number".tr());
        } else {
          viewContext.showToast(msg: e.message ?? "Failed".tr());
        }
        setBusy(false);
      },
      codeSent: (String verificationId, int? resendToken) {
        firebaseVerificationId = verificationId;
        showVerificationEntry();
        setBusy(false);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        //
        // firebaseVerificationId = verificationId;
        // showVerificationEntry();
        // setBusy(false);
      },
    );
  }

  //
  processCustomForgotPassword(String phoneNumber) async {
    setBusy(true);
    try {
      await _authRequest.sendOTP(phoneNumber);
      setBusy(false);
      showVerificationEntry();
    } catch (error) {
      setBusy(false);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
  }

  processEmailForgotPassword(String email) async {
    setBusy(true);
    try {
      await _authRequest.sendEmailOTP(email!);
      setBusy(false);
      showEmailVerificationEntry();
    } catch (error) {
      setBusy(false);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
  }

  //show a bottomsheet to the user for verification code entry
  void showVerificationEntry() {
    //
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      builder: (context) {
        return AccountVerificationEntry(
          vm: this,
          onSubmit: (smsCode) {
            //
            print("sms code ==> $smsCode");
            if (!AppStrings.isCustomOtp) {
              verifyFirebaseOTP(smsCode);
            } else {
              verifyCustomOTP(smsCode);
            }
            Navigator.pop(viewContext);
          },
        );
      },
    );
  }

  //verify the provided code with the firebase server
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

      UserCredential userCredential = await auth.signInWithCredential(
        phoneAuthCredential,
      );
      //
      firebaseToken = await userCredential.user?.getIdToken();
      showNewPasswordEntry();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(firebaseVerificationId, false);
  }

  //verify the provided code with the custom sms gateway server
  void verifyCustomOTP(String smsCode) async {
    //
    setBusy(true);

    // Sign the user in (or link) with the credential
    try {
      final apiResponse = await _authRequest.verifyOTP(
        accountPhoneNumber!,
        smsCode,
      );
      firebaseToken = apiResponse.body["token"];
      showNewPasswordEntry();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusy(false);
  }

  //show a bottomsheet to the user for verification code entry
  showNewPasswordEntry() {
    //
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      builder: (context) {
        return NewPasswordEntry(
          vm: this,
          onSubmit: (password) {
            //
            finishChangeAccountPassword();
            Navigator.pop(viewContext);
          },
        );
      },
    );
  }

  void showEmailVerificationEntry() async {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      builder: (context) {
        return AccountVerificationEntry(
          vm: this,
          email: emailTEC.text,
          onSubmit: (smsCode) {
            //
            verifyEmailOTP(smsCode);
          },
        );
      },
    );
    //
  }

  //verify email otp
  void verifyEmailOTP(String smsCode) async {
    //
    setBusyForObject(firebaseVerificationId, true);

    try {
      final apiResponse = await _authRequest.verifyEmailOTP(
        emailTEC.text!,
        smsCode,
      );
      emailResetToken = apiResponse.body["token"];
      showNewEmailPasswordEntry();
    } catch (error) {
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
    //
    setBusyForObject(firebaseVerificationId, false);
  }

  showNewEmailPasswordEntry() {
    //
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      builder: (context) {
        return NewPasswordEntry(
          vm: this,
          onSubmit: (password) {
            //
            finishChangeEmailAccountPassword();
            Navigator.pop(viewContext);
          },
        );
      },
    );
  }

  //
  finishChangeAccountPassword() async {
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
      title: "Forgot Password".tr(),
      text: apiResponse.message,
      onConfirmBtnTap: () {
        Navigator.of(viewContext).popUntil((route) => route.isFirst);
      },
    );
  }

  finishChangeEmailAccountPassword() async {
    //
    setBusy(true);
    final apiResponse = await _authRequest.resetEmailPasswordRequest(
        email: emailAddress!,
        password: passwordTEC.text,
        token: emailResetToken);
    setBusy(false);

    CoolAlert.show(
      context: viewContext,
      type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
      title: "Forgot Password".tr(),
      text: apiResponse.message,
      onConfirmBtnTap: () {
        Navigator.of(viewContext).popUntil((route) => route.isFirst);
      },
    );
  }
}
