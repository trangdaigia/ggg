import 'package:flutter/material.dart';
import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/services/http.service.dart';
import 'package:sod_user/services/location.service.dart';

class VendorTypeRequest extends HttpService {
  //
  Future<List<VendorType>> index() async {
    final apiResult = await get(
      Api.vendorTypes,
      // don't need to pass latitude and longitude to this api
      // because this api use them to get the nearest vendors but we don't need that
      // queryParameters: {
      //   "latitude": LocationService.currenctAddress?.coordinates?.latitude,
      //   "longitude": LocationService.currenctAddress?.coordinates?.longitude,
      // },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      print('(${LocationService.currenctAddress?.coordinates?.latitude})');
      print('(${LocationService.currenctAddress?.coordinates?.longitude})');
      final data =
          apiResponse.hasData() ? apiResponse.data : apiResponse.body as List;
      return data.map((e) => VendorType.fromJson(e)).toList();
    }
    throw apiResponse.message!;
  }
}
