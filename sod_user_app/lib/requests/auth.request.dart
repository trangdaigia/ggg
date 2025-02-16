import 'dart:io';

import 'package:dio/dio.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/services/firebase_token.service.dart';
import 'package:sod_user/services/http.service.dart';

class AuthRequest extends HttpService {
  //
  Future<ApiResponse> loginRequest({
    String? email,
    String? phone,
    required String password,
  }) async {
    if (email == null && phone == null) {
      throw "Either email or phone number must be provided.".tr();
    }
    if (email != null && phone != null)
      throw "Only provide email or phone number".tr();
    final Map<String, dynamic> data = {
      if (email != null) "email": email,
      if (phone != null) "phone": phone,
      "password": password,
      "tokens": await FirebaseTokenService().getDeviceToken(),
    };
    final apiResult = await post(Api.login, data);
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> qrLoginRequest({
    required String code,
  }) async {
    final apiResult = await post(
      Api.qrlogin,
      {
        "code": code,
        "tokens": await FirebaseTokenService().getDeviceToken(),
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> resetPasswordRequest({
    required String phone,
    required String password,
    String? firebaseToken,
    String? customToken,
  }) async {
    final apiResult = await post(
      Api.forgotPassword,
      {
        "phone": phone,
        "password": password,
        "firebase_id_token": firebaseToken,
        "verification_token": customToken,
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> resetEmailPasswordRequest({
    required String email,
    required String password,
    required String? token,
  }) async {
    final apiResult = await post(
      Api.forgotEmailPassword,
      {
        "email": email,
        "password": password,
        "verification_token": token,
        "role": "client"
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> registerRequest({
    required String name,
    String? email,
    required String phone,
    required String countryCode,
    required String password,
    required String taxCode,
    String code = "",
  }) async {
    final apiResult = await post(
      Api.register,
      {
        "name": name,
        if (email != null) "email": email,
        "phone": phone,
        "country_code": countryCode,
        "password": password,
        "code": code,
        "role": "client",
        "tokens": await FirebaseTokenService().getDeviceToken(),
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> logoutRequest() async {
    final apiResult = await get(Api.logout);
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> updateProfile({
    File? photo,
    String? name,
    String? email,
    String? phone,
    String? countryCode,
  }) async {
    final apiResult = await postWithFiles(
      Api.updateProfile,
      {
        "_method": "PUT",
        "name": name,
        "email": email,
        "phone": phone,
        "country_code": countryCode,
        "photo": photo != null
            ? await MultipartFile.fromFile(
                photo.path,
              )
            : null,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updatePassword({
    String? password,
    String? new_password,
    String? new_password_confirmation,
  }) async {
    final apiResult = await post(
      Api.updatePassword,
      {
        "_method": "PUT",
        "password": password,
        "new_password": new_password,
        "new_password_confirmation": new_password_confirmation,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> verifyPhoneAccount(String phone) async {
    final apiResult = await get(
      Api.verifyPhoneAccount,
      queryParameters: {
        "phone": phone,
      },
      staleWhileRevalidate: true,
    );

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> verifyEmailAccount(String email) async {
    final apiResult = await post(
      Api.verifyEmailAccount,
      {
        "email": email,
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> sendOTP(String phoneNumber,
      {bool isLogin = false}) async {
    final apiResult = await post(
      Api.sendOtp,
      {
        "phone": phoneNumber,
        "is_login": isLogin,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message ?? apiResponse;
    }
  }

  Future<ApiResponse> verifyOTP(String phoneNumber, String code,
      {bool isLogin = false}) async {
    final apiResult = await post(
      Api.verifyOtp,
      {
        "phone": phoneNumber,
        "code": code,
        "is_login": isLogin,
        "tokens": await FirebaseTokenService().getDeviceToken(),
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message ?? apiResponse;
    }
  }

//
  Future<ApiResponse> verifyFirebaseToken(
    String phoneNumber,
    String firebaseVerificationId,
  ) async {
    //
    final apiResult = await post(
      Api.verifyFirebaseOtp,
      {
        "phone": phoneNumber,
        "firebase_id_token": firebaseVerificationId,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message ?? apiResponse;
    }
  }

  Future<Driver> getMyDetails() async {
    //
    final apiResult = await get(Api.myProfile, forceRefresh: true);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Driver.fromJson(apiResponse.body);
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> switchOnOff({
    bool? isOnline,
  }) async {
    final apiResult = await post(
      Api.switchOnOff,
      {
        "is_online": isOnline == null
            ? null
            : isOnline
                ? 1
                : 0,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse?> socialLogin(
    String email,
    String? firebaseVerificationId,
    String provider, {
    String? nonce,
    String? uid,
  }) async {
    //
    final apiResult = await post(
      Api.socialLogin,
      {
        "provider": provider,
        "email": email,
        "firebase_id_token": firebaseVerificationId,
        "nonce": nonce,
        "uid": uid,
        "tokens": await FirebaseTokenService().getDeviceToken(),
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else if (apiResponse.code == 401) {
      return null;
    } else {
      throw apiResponse.message!;
    }
  }

  Future<ApiResponse> deleteProfile({
    String? password,
    String? reason,
  }) async {
    final apiResult = await post(
      Api.accountDelete,
      {
        "_method": "DELETE",
        "password": password,
        "reason": reason,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updateDeviceToken(String token) async {
    final apiResult = await post(
      Api.tokenSync,
      {
        "tokens": token,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> sendEmailOTP(String email) async {
    final apiResult = await post(
      Api.sendEmailOtp,
      {
        "email_receiver": email,
        "title": "Forgot password",
        "is_login": false,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message ?? apiResponse;
    }
  }

  Future<ApiResponse> verifyEmailOTP(String email, String code,
      {bool isLogin = false}) async {
    final apiResult = await post(
      Api.verifyEmailOtp,
      {
        "email_receiver": email,
        "code": code,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message ?? apiResponse;
    }
  }

  Future<ApiResponse> registerDriverRequest({
    required Map<String, dynamic> vals,
    List<File>? docs,
  }) async {
    final postBody = {
      ...vals,
    };

    FormData formData = FormData.fromMap(postBody);
    if ((docs ?? []).isNotEmpty) {
      for (File file in docs!) {
        formData.files.addAll([
          MapEntry("documents[]", await MultipartFile.fromFile(file.path)),
        ]);
      }
    }

    final apiResult = await postCustomFiles(
      //Api.newAccount,
      '/TODO: Add API URL',
      null,
      formData: formData,
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> loginDriver({
    required String email,
    required String password,
  }) async {
    final apiResult = await post(
      Api.login,
      {
        "email": email,
        "password": password,
        "role": "driver",
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> submitDocumentsRequest({required List<File> docs}) async {
    FormData formData = FormData.fromMap({});
    for (File file in docs) {
      formData.files.addAll([
        MapEntry("documents[]", await MultipartFile.fromFile(file.path)),
      ]);
    }

    final apiResult = await postCustomFiles(
      Api.documentSubmission,
      null,
      formData: formData,
    );
    return ApiResponse.fromResponse(apiResult);
  }
}
