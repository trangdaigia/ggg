import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:sod_user/driver_lib/models/api_response.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/services/http.service.dart';

class VehicleRequest extends HttpService {
  //
  Future<List<Vehicle>> vehicles() async {
    final apiResult = await get(Api.vehicles,
        forceRefresh: true, staleWhileRevalidate: false);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return List.from(apiResponse.body.map((e) => Vehicle.fromJson(e)));
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<ApiResponse> newVehicleRequest({
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
      Api.driverVehicleRegister,
      null,
      formData: formData,
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> makeActive(int id, String type) async {
    final apiResult = await post(
      Api.activateVehicle.replaceAll("{id}", "$id"),
      {"vendorType": type},
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    }
    throw "${apiResponse.message}";
  }

  Future<ApiResponse> makeDeactive(int id, String type) async {
    final apiResult = await post(
      Api.deactivateVehicle.replaceAll("{id}", "$id"),
      {"vendorType": type},
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    }
    throw "${apiResponse.message}";
  }
}
