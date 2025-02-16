import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:sod_user/driver_lib/models/api_response.dart';
import 'package:sod_user/driver_lib/models/user.dart';
import 'package:sod_user/services/http.service.dart';

class AuthRequest extends HttpService {
  //
  Future<ApiResponse> loginRequest({
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

  Future<ApiResponse> registerRequest({
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
      Api.newAccount,
      null,
      formData: formData,
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

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
      throw "${apiResponse.message}";
    }
  }

  //
  Future<ApiResponse> qrLoginRequest({
    required String code,
  }) async {
    final apiResult = await post(
      Api.qrlogin,
      {
        "code": code,
        "role": "driver",
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
        "role": "driver"
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> logoutRequest() async {
    final apiResult = await get(Api.logout);
    return ApiResponse.fromResponse(apiResult);
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
  Future<ApiResponse> updateProfile({
    File? photo,
    String? name,
    String? email,
    String? phone,
    bool? isOnline,
    String? gender,
    String? countryId,
    String? stateId,
    String? cityId,
  }) async {
    final apiResult = await postWithFiles(
      Api.updateProfile,
      {
        "_method": "PUT",
        "name": name,
        "gender": gender,
        "email": email,
        "phone": phone,
        "country_id": countryId,
        "state_id": stateId,
        "city_id": cityId,
        "is_online": isOnline == null
            ? null
            : isOnline
                ? 1
                : 0,
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
      throw "${apiResponse.message}";
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
      throw "${apiResponse.message}";
    }
  }

  Future<User> getMyDetails() async {
    //
    final apiResult = await get(Api.myProfile, forceRefresh: true);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return User.fromJson(apiResponse.body);
    } else {
      throw "${apiResponse.message}";
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
}
