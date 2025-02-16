import 'dart:io';

import 'package:dio/dio.dart';

import 'package:sod_vendor/constants/api.dart';
import 'package:sod_vendor/models/api_response.dart';
import 'package:sod_vendor/services/http.service.dart';

class AuthRequest extends HttpService {
  //
  Future<ApiResponse> loginRequest({
    String? email,
    String? phone,
    required String password,
  }) async {
    if (email == null && phone == null)
      throw "Etheir email or phone number must be provided";
    if (email != null && phone != null)
      throw "Only provide email or phone number";
    final apiResult = await post(
      Api.login,
      {
        if (email != null) "email": email,
        if (phone != null) "phone": phone,
        "password": password,
        "role": "manager",
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> registerRequest({
    required Map<String, dynamic> vals,
    List<File>? docs,
  }) async {
    final postBody = {
      ...vals,
    };

    FormData formData = FormData.fromMap(postBody);
    for (File file in docs ?? []) {
      formData.files.addAll([
        MapEntry("documents[]", await MultipartFile.fromFile(file.path)),
      ]);
    }

    final apiResult = await postWithFiles(
      Api.newAccount,
      null,
      formData: formData,
    );
    //
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
        "role": "manager",
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
        "role": "manager"
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
    required String name,
    required String email,
    required String phone,
  }) async {
    final apiResult = await postWithFiles(
      Api.updateProfile,
      {
        "_method": "PUT",
        "name": name,
        "email": email,
        "phone": phone,
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
    required String password,
    required String new_password,
    required String new_password_confirmation,
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
      throw apiResponse.message;
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
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    } else {
      throw apiResponse.message;
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
      throw apiResponse.message;
    }
  }

  Future<ApiResponse> deleteProfile({
    required String password,
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
      throw apiResponse.message;
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
      throw apiResponse.message;
    }
  }
}
