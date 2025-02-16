import 'package:cool_alert/cool_alert.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/driver_lib/requests/auth.request.dart';
import 'package:sod_user/driver_lib/utils/utils.dart';
import 'package:sod_user/driver_lib/widgets/bottomsheets/account_verification_entry.dart';
import 'package:sod_user/driver_lib/widgets/bottomsheets/new_password_entry.dart';
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
  String? emailResetToken;

  //
  String? firebaseToken;
  String? firebaseVerificationId;
  bool? otpLogin;

  ForgotPasswordViewModel(BuildContext context) {
    this.viewContext = context;
    this.selectedCountry = Country.parse(AppStrings.defaultCountryCode);
  }

  void initialise() async {
    this.selectedCountry = Country.parse(
      await Utils.getCurrentCountryCode(),
    );
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
        final apiResponse =
            await _authRequest.verifyPhoneAccount(accountPhoneNumber!);
        if (apiResponse.allGood) {
          //
          final phoneNumber = apiResponse.body["phone"];
          //accountPhoneNumber = phoneNumber;
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
          viewContext.showToast(msg: e.message ?? "Error".tr());
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

  processEmailForgotPassword(String email) async {
    setBusy(true);
    try {
      await _authRequest.sendEmailOTP(email);
      setBusy(false);
      showEmailVerificationEntry();
    } catch (error) {
      setBusy(false);
      viewContext.showToast(msg: "$error", bgColor: Colors.red);
    }
  }

  //show a bottomsheet to the user for verification code entry
  void showVerificationEntry() async {
    //
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      builder: (context) {
        return AccountVerificationEntry(
          vm: this,
          phone: accountPhoneNumber!,
          onSubmit: (smsCode) {
            //
            if (!AppStrings.isCustomOtp) {
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
                        await _authRequest.sendOTP(accountPhoneNumber!);
                    toastSuccessful(response.message ?? "Success".tr());
                  } catch (error) {
                    viewContext.showToast(msg: "$error", bgColor: Colors.red);
                  }
                }
              : () {},
        );
      },
    );
    //
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

  void showEmailVerificationEntry() async {
    //
    await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) {
          return AccountVerificationEntry(
            vm: this,
            email: emailAddress!,
            onSubmit: (emailCode) {
              //
              verifyEmailOTP(emailCode);

              Navigator.pop(viewContext);
            },
            onResendCode: () async {
              try {
                final response =
                    await _authRequest.sendEmailOTP(emailTEC.text.trim());
                toastSuccessful(response.message ?? "Success".tr());
              } catch (error) {
                viewContext.showToast(msg: "$error", bgColor: Colors.red);
              }
            },
          );
        },
      ),
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

  //verify the provided code with the custom sms gateway server
  void verifyCustomOTP(String smsCode) async {
    //
    setBusyForObject(firebaseVerificationId, true);

    // Sign the user in (or link) with the credential
    try {
      accountPhoneNumber = accountPhoneNumber!.replaceFirst('0', '+84');
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
    setBusyForObject(firebaseVerificationId, false);
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
      //
      firebaseToken: !AppStrings.isCustomOtp ? firebaseToken! : null,
      customToken: AppStrings.isCustomOtp ? firebaseToken! : null,
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
