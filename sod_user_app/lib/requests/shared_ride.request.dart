import 'package:sod_user/constants/api.dart';
import 'package:sod_user/global/global_variable.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/shared_ride.dart';
import 'package:sod_user/models/vehicle.dart';
import 'package:sod_user/services/http.service.dart';
import 'package:supercharged/supercharged.dart';

class SharedRideRequest extends HttpService {
  Future<ApiResponse> bookSharedRide({Map<String, dynamic>? payload}) async {
    final apiResult = await post(
      Api.orders,
      payload,
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> postSharedRide({Map<String, dynamic>? params}) async {
    final apiResult = await post(Api.sharedRides, params);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updateSharedRide({Map<String, dynamic>? params}) async {
    final apiResult =
        await patch("${Api.sharedRides}/${params!['id']}", params);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> cancelSharedRide({Map<String, dynamic>? params}) async {
    final apiResult = await post("${Api.cancelSharedRide}", params);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<List<SharedRide>> getSharedRides(Map<String, dynamic>? params) async {
    GlobalVariable.refreshCache = true;
    final apiResult = await get(Api.sharedRides, queryParameters: params, staleWhileRevalidate: false);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    return (apiResponse.data)
        .map((e) => SharedRide.fromJson(e))
        .toList();
  }

  Future<List<Vehicle>> getRentalVehicles() async {
    try {
      final apiResult =
          await get(Api.getCarRental, queryParameters: {'is_mine': '1'});
      final apiResponse = ApiResponse.fromResponse(apiResult);
      print(apiResponse.body.toString());
      List<Vehicle> list =
          (apiResponse.body as List).map((e) => Vehicle.fromJson(e)).toList();
      return list.filter((e) => e.carModel?.carMake != "" || e.carModel != "").toList();
    } catch (e) {
      print(e.toString());
    }
    return [];
  }

  Future<ApiResponse> updateOrderSharedRide({int? id, String? status}) async {
    GlobalVariable.bookRideId = id!;
    final apiResult = await post(Api.updateOrderSharedRide, {
      "id": id,
      "status": status,
    });
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    print('Body update: ${apiResponse.body}');
    return apiResponse;
  }
}
