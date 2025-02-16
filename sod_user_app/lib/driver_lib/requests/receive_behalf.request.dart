import 'dart:io';

import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';
import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/api_response.dart';
import 'package:sod_user/driver_lib/models/box.dart';
import 'package:sod_user/driver_lib/models/user.dart';
import 'package:sod_user/services/http.service.dart';

class ReceiveBehalfRequest extends HttpService {
  Future<List<User>> phoneSearch(String search) async {
    final phoneCountryCode = Country.parse(AppStrings.countryCode
            .toUpperCase()
            .replaceAll("AUTO,", "")
            .split(",")[0])
        .phoneCode;
    if (search.startsWith('0')) {
      search = search.substring(1);
    }

    String phoneSearch = '+${phoneCountryCode}${search}';
    print(phoneSearch);
    final apiResult = await get(Api.users, queryParameters: {
      'phone': phoneSearch,
      'role': 'driver',
      'searchPhone': 1
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    print(apiResponse.body);
    if (apiResponse.body == null) {
      return [];
    }
    return (apiResponse.body["data"] as List)
        .map((e) => User.fromJson(e))
        .toList();
  }

  Future<ApiResponse> newReceiveBehalfOrder(
      {required Map<String, dynamic> params,
      required List<File> photos}) async {
    Map<String, dynamic> postBody = {
      "type": "receive_behalf",
      "user_id": params["user_id"],
      "sub_total": params["sub_total"],
      "total": params["total"],
      "service_fee_percent": params["service_fee_percent"],
      "order_value": params["order_value"],
      "service_fee": params["service_fee"],
      "token": params["token"],
      "paid_order": params["paid_order"],
      "box_id": params["box_id"],
    };
    FormData formData = FormData.fromMap(postBody);
    if (photos.isNotEmpty) {
      for (File? file in photos) {
        formData.files.add(
          MapEntry("photos[]", await MultipartFile.fromFile(file!.path)),
        );
      }
    }
    //make api request
    final apiResult = await postWithFiles(Api.orders, formData);
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<List<Box>> getBoxes() async {
    final apiResult = await get(
      Api.box,
      forceRefresh: true,
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data.map((jsonObject) {
        return Box.fromJson(jsonObject);
      }).toList();
    } else {
      throw apiResponse.message!;
    }
  }
}
