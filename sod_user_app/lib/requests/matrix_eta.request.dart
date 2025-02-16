import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/distance_matrix_googlemap/distance_matrix_googlemap.dart';
import 'package:sod_user/models/distance_matrix_vietmap.dart';
import 'package:sod_user/services/http.service.dart';

class MatrixETARequest extends HttpService {
  Future<DistanceMatrixVietMap> getMatrixETAVietMap({
    required LatLng pickupLatLng,
    required LatLng destinationLatLng,
  }) async {
    final host = "https://maps.vietmap.vn";
    final url =
        "/api/matrix?api-version=1.1&apikey=${AppStrings.vietMapMapApiKey}&point=${pickupLatLng.latitude},${pickupLatLng.longitude}&point=${destinationLatLng.latitude},${destinationLatLng.longitude}&sources=0&destinations=1";
    final apiResult = await get(url, hostUrl: host);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return DistanceMatrixVietMap.fromJson(apiResponse.body);
    } else {
      throw apiResponse.message!;
    }
  }

  Future<DistanceMatrixGoogleMap> getMatrixETAGoogle({
    required LatLng pickupLatLng,
    required LatLng destinationLatLng,
  }) async {
    final host = "https://maps.googleapis.com/maps";
    final url =
        "/api/distancematrix/json?origins=${pickupLatLng.latitude},${pickupLatLng.longitude}&destinations=${destinationLatLng.latitude},${destinationLatLng.longitude}&key=${AppStrings.googleMapApiKey}";
    final apiResult = await get(url, hostUrl: host);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return DistanceMatrixGoogleMap.fromJson(apiResponse.body);
    } else {
      throw apiResponse.message!;
    }
  }
}
