import 'package:flutter/foundation.dart';
import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/order_stop.dart';
import 'package:sod_user/models/review.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/services/http.service.dart';
import 'package:sod_user/services/location.service.dart';

class VendorRequest extends HttpService {
  //
  Future<List<Vendor>> vendorsRequest({
    int page = 1,
    bool byLocation = true,
    Map? params,
  }) async {
    Map<String, dynamic> queryParameters = {
      ...(params != null ? params : {}),
      "page": "$page",
    };
    //
    if (byLocation && LocationService.cLat != null) {
      queryParameters["latitude"] =
          LocationService.currenctAddress?.coordinates?.latitude;
      queryParameters["longitude"] =
          LocationService.currenctAddress?.coordinates?.longitude;
    }
    //
    final apiResult = await get(
      Api.vendors,
      queryParameters: queryParameters,
      staleWhileRevalidate: true,
      forceRefresh: true,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Vendor> vendors = [];
      apiResponse.data.forEach(
        (jsonObject) {
          try {
            vendors.add(Vendor.fromJson(jsonObject));
          } catch (error) {
            print("===============================");
            print("Fetching Vendor error ==> $error");
            print("Vendor Id ==> ${jsonObject}");
            print("===============================");
          }
        },
      );
      return vendors;
    }

    throw apiResponse.message!;
  }

  //
  Future<List<Vendor>> topVendorsRequest({
    int page = 1,
    bool byLocation = false,
    Map? params,
  }) async {
    final apiResult = await get(
      Api.vendors,
      queryParameters: {
        ...(params != null ? params : {}),
        "page": "$page",
        "latitude": byLocation
            ? LocationService.currenctAddress?.coordinates?.latitude
            : null,
        "longitude": byLocation
            ? LocationService.currenctAddress?.coordinates?.longitude
            : null,
      },
      staleWhileRevalidate: true,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Vendor> vendors = [];
      vendors = apiResponse.data
          .map((jsonObject) => Vendor.fromJson(jsonObject))
          .toList();
      return vendors;
    }

    throw apiResponse.message!;
  }

  Future<List<Vendor>> nearbyVendorsRequest({
    int page = 1,
    bool byLocation = false,
    Map? params,
  }) async {
    final apiResult = await get(
      Api.vendors,
      queryParameters: {
        ...(params != null ? params : {}),
        "page": "$page",
        "latitude": byLocation
            ? LocationService.currenctAddress?.coordinates?.latitude
            : null,
        "longitude": byLocation
            ? LocationService.currenctAddress?.coordinates?.longitude
            : null,
      },
      staleWhileRevalidate: true,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Vendor.fromJson(jsonObject))
          .toList();
    }

    throw apiResponse.message!;
  }

  Future<Vendor> vendorDetails(
    int id, {
    Map<String, String>? params,
  }) async {
    //
    final apiResult = await get(
      "${Api.vendors}/$id",
      queryParameters: params,
      staleWhileRevalidate: true,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Vendor.fromJson(apiResponse.body);
    }

    throw apiResponse.message!;
  }

  Future<List<Vendor>> fetchParcelVendors({
    required int packageTypeId,
    int? vendorTypeId,
    required List<OrderStop> stops,
  }) async {
    final apiResult = await post(
      Api.packageVendors,
      {
        "vendor_type_id": vendorTypeId,
        "package_type_id": "$packageTypeId",
        "locations": stops.map(
          (stop) {
            return {
              "lat": stop.deliveryAddress?.latitude,
              "long": stop.deliveryAddress?.longitude,
              "city": stop.deliveryAddress?.city,
              "state": stop.deliveryAddress?.state,
              "country": stop.deliveryAddress?.country,
            };
          },
        ).toList(),
      },
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Vendor> vendors = (apiResponse.body['vendors'] as List)
          .map((jsonObject) => Vendor.fromJson(jsonObject))
          .toList();
      return vendors;
    }

    throw apiResponse.message!;
  }

  //
  Future<ApiResponse> rateVendor({
    required int rating,
    required String review,
    required int orderId,
    required int vendorId,
  }) async {
    //
    final apiResult = await post(
      Api.rating,
      {
        "order_id": orderId,
        "vendor_id": vendorId,
        "rating": rating,
        "review": review,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> rateDriver({
    required int rating,
    required String review,
    required int orderId,
    required int driverId,
  }) async {
    //
    final apiResult = await post(
      Api.rating,
      {
        "order_id": orderId,
        "driver_id": driverId,
        "rating": rating,
        "review": review,
      },
    );
    return ApiResponse.fromResponse(apiResult);
  }

  Future<List<Review>> getReviews({
    int? page,
    int? vendorId,
  }) async {
    final apiResult = await get(
      Api.vendorReviews,
      queryParameters: {
        "vendor_id": vendorId,
        "page": "$page",
      },
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Review> reviews = apiResponse.data.map(
        (jsonObject) {
          return Review.fromJson(jsonObject);
        },
      ).toList();

      return reviews;
    }

    throw apiResponse.message!;
  }
}
