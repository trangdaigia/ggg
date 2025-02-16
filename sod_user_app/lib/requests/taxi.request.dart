import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/models/driver.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/models/tax_order_location.history.dart';
import 'package:sod_user/models/taxi_ship_package_type.dart';
import 'package:sod_user/models/vehicle.dart';
import 'package:sod_user/models/vehicle_type.dart';

import 'package:sod_user/services/http.service.dart';

class TaxiRequest extends HttpService {
  //
  Future<List<VehicleType>> getVehicleTypes() async {
    final apiResult = await get("${Api.vehicleTypes}");
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body as List)
          .map((object) => VehicleType.fromJson(object))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  //
  Future<List<VehicleType>> getVehicleTypePricing(
      DeliveryAddress pickup, DeliveryAddress dropoff,
      {String? countryCode, int? vendorTypeId}) async {
    //
    final apiResult = await get(
      "${Api.vehicleTypePricing}",
      queryParameters: {
        "pickup": "${pickup.latitude},${pickup.longitude}",
        "dropoff": "${dropoff.latitude},${dropoff.longitude}",
        "country_code": "$countryCode",
        "vendor_type_id": vendorTypeId
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<VehicleType> vehicleTypes = [];
      (apiResponse.body as List).forEach(
        (object) {
          //
          try {
            final vehicleType = VehicleType.fromJson(object);
            vehicleTypes.add(vehicleType);
          } catch (e) {
            print('Lỗi: $e');
          }
        },
      );
      return vehicleTypes;
    } else {
      throw apiResponse.message!;
    }
  }

  Future<ApiResponse> locationAvailable(
    double latitude,
    double longitude,
  ) async {
    final apiResult = await get(
      Api.taxiLocationAvailable,
      queryParameters: {
        "latitude": latitude,
        "longitude": longitude,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> placeNeworder({
    Map<String, dynamic>? params,
  }) async {
    final apiResult = await postWithFiles(
      "${Api.newTaxiBooking}",
      params,
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<Order?> getOnGoingTrip({bool forceRefresh = true}) async {
    final apiResult = await get(
      "${Api.currentTaxiBooking}?role=client",
      forceRefresh: forceRefresh,
      staleWhileRevalidate: false,
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    //
    if (apiResponse.allGood) {
      //if there is order
      if (apiResponse.body["order"] != null) {
        return Order.fromJson(apiResponse.body["order"]);
      } else {
        return null;
      }
    }

    //
    throw apiResponse.body;
  }

  //
  Future<ApiResponse> cancelTrip(int id) async {
    final apiResult = await get(
      "${Api.cancelTaxiBooking}/$id",
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<Driver?> getDriverInfo(int id) async {
    final apiResult = await get(
      "${Api.taxiDriverInfo}/$id",
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if(apiResponse.body["driver"] == null)
      return null;
    final driver = Driver.fromJson(apiResponse.body["driver"]);
    driver.vehicle = Vehicle.fromJson(apiResponse.body['vehicle']);
    return driver;
  }

  Future<ApiResponse> rateDriver(
    int orderId,
    int driverId,
    double newTripRating,
    String review,
  ) async {
    //
    final apiResult = await post(
      "${Api.rating}",
      {
        //
        "driver_id": driverId,
        "order_id": orderId,
        "rating": newTripRating,
        "review": review,
      },
    );
    //
    return ApiResponse.fromResponse(apiResult);
  }

  Future<List<TaxiOrderLocationHistory>> locationHistory() async {
    final apiResult = await get(Api.taxiTripLocationHistory);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    return (apiResponse.body as List)
        .map((e) => TaxiOrderLocationHistory.fromJson(e))
        .toList();
  }

  Future<List<TaxiShipPackageType>> getTaxiShipPackageType() async {
    final apiResult = await get("${Api.taxiShipPackageTypes}");
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      print(apiResponse.toString());
      return (apiResponse.body as List)
          .map((object) => TaxiShipPackageType.fromJson(object))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }
}
