import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/car_brand.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/models/vehicle_type.dart';
import 'package:sod_user/services/http.service.dart';

class CarRentalRequest extends HttpService {
  List<CarRental> carRental = [];
  List<CarRental> ownerVehicle = [];
  List<CarModel> carModel = [];
  List<CarBrandModel> carBrand = [];
  List<VehicleType> vehicleType = [];
  // String? tempApi = "https://114e-27-74-248-77.ngrok-free.app/api";
  // Map<String, dynamic>? headers = {
  //   "Authorization": "Bearer 275|xEpqBA78NITLwA5Msh4G345fXELJEhxoo4XykKBd",
  // };
  String? tempApi = null;
  Map<String, dynamic>? headers = null;
  Future<List<CarRental>> getCar({
    String? brand_id = "",
    String? year_made = "",
    String? color = "",
    String? rental_options = '',
    double? longitude = 0,
    double? latitude = 0,
    String? rating = '',
    String? vehicle_type_id = '',
    String? fast_booking = '',
    String? mortgage_exemption = '',
    String? discount = '',
    String? free_delivery = '',
  }) async {
    final apiResult = await get(
      Api.getCarRental,
      hostUrl: tempApi,
      headers: headers,
      forceRefresh: true,
      queryParameters: {
        "color": color,
        "year_made": year_made,
        "brand_id": brand_id,
        "is_mine": "0",
        "longitude": longitude,
        "latitude": latitude,
        "rental_options": rental_options,
        "rating": rating,
        "vehicle_type_id": vehicle_type_id,
        "fast_booking": fast_booking,
        "mortgage_exemption": mortgage_exemption,
        "discount": discount,
        "free_delivery": free_delivery,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      carRental =
          (apiResponse.body as List).map((e) => CarRental.fromJson(e)).toList();
      return carRental;
    } else {
      throw Exception('Request failed with status: ${apiResult.statusCode}');
    }
  }

  getOwnerVehicle(
    int rental_options,
    int id,
    double? longitude,
    double? latitude,
  ) async {
    final apiResult = await get(Api.getOwnerVehicle + '/$id', queryParameters: {
      "rental_options": rental_options,
      "longitude": longitude,
      "latitude": latitude,
    });
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      ownerVehicle =
          (apiResponse.data).map((e) => CarRental.fromJson(e)).toList();
      return ownerVehicle;
    } else {
      throw Exception('Request failed with status: ${apiResult.statusCode}');
    }
  }

  Future<List<CarModel>> getCarModel({required String carMakeId}) async {
    final apiResult = await get(
      Api.getCarModel,
      queryParameters: {
        "car_make_id": carMakeId,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      carModel = (apiResponse.body as List<dynamic>)
          .map((jsonObject) => CarModel.fromJson(jsonObject))
          .toList();
      return carModel;
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<CarBrandModel>> getCarBrand() async {
    final apiResult = await get(
      //
      hostUrl: tempApi,
      headers: headers,
      Api.getCarBrand,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      carBrand = (apiResponse.body as List<dynamic>)
          .map((jsonObject) => CarBrandModel.fromJson(jsonObject))
          .toList();
      return carBrand;
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<VehicleType>> getVehicleType() async {
    final apiResult = await get(
      "${Api.vehicleTypes}",
      hostUrl: tempApi,
      headers: headers,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      vehicleType = (apiResponse.body as List<dynamic>)
          .map((data) => VehicleType.fromJson(data))
          .toList();
    } else {
      print('Request failed with status: ${apiResult.statusCode}');
      print('Response body: ${apiResult.data}');
    }
    return vehicleType;
  }

  Future<bool> addRentalRequest({
    required String totalPrice,
    required String totalDays,
    required String status,
    required String debutDate,
    required String expireDate,
    required String contactPhone,
    required String vehicleId,
    required int type,
    required String pickup_latitude,
    required String pickup_longitude,
    required String dropoff_latitude,
    required String dropoff_longitude,
    required int route,
    required int deliveryToHome,
  }) async {
    final apiResult = await post(
      //
      hostUrl: tempApi,
      headers: headers,
      Api.addRentalRequest,
      {
        'total_price': totalPrice,
        'status': status,
        'total_days': totalDays,
        'debut_date': debutDate,
        'expire_date': expireDate,
        'contact_phone': contactPhone,
        'vehicle_id': vehicleId,
        'is_self_driving': type,
        'pickup_latitude': pickup_latitude,
        'pickup_longitude': pickup_longitude,
        'dropoff_latitude': dropoff_latitude,
        'dropoff_longitude': dropoff_longitude,
        'route': route,
        'delivery_to_home': deliveryToHome,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return true;
    } else {
      print('Lỗi thuê xe: ${apiResponse.message}');
      return false;
    }
  }

  Future<bool> addRentalRequestTest({
    required String totalPrice,
    required String totalDays,
    required String status,
    required String debutDate,
    required String expireDate,
    required String contactPhone,
    required String vehicleId,
    required int type,
    required String pickup_latitude,
    required String pickup_longitude,
    required String dropoff_latitude,
    required String dropoff_longitude,
    required int route,
    required int deliveryToHome,
    required int userID,
    required int discount,
    required int subTotal,
    required double deliveryFee,
    required int driverID,
  }) async {
    final apiResult = await post(
      Api.orders,
      {
        "type": "rental_vehicle",
        "user_id": userID,
        "sub_total": subTotal,
        "total": totalPrice,
        "discount": discount,
        "delivery_fee": deliveryFee,
        'total_price': totalPrice,
        'status': status,
        'total_days': totalDays,
        'debut_date': debutDate,
        'expire_date': expireDate,
        'contact_phone': contactPhone,
        'vehicle_id': vehicleId,
        'is_self_driving': type,
        'pickup_latitude': pickup_latitude,
        'pickup_longitude': pickup_longitude,
        'dropoff_latitude': dropoff_latitude,
        'dropoff_longitude': dropoff_longitude,
        'route': route,
        'delivery_to_home': deliveryToHome,
        'driver_id': driverID,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    print('body thuê xe: ${apiResponse.body}');
    if (apiResponse.allGood) {
      return true;
    } else {
      print('Lỗi thuê xe: ${apiResponse.message}');
      return false;
    }
  }

  Future<bool> updateFavourite(int id, bool status) async {
    if (!status) {
      final apiResult = await post(
        //
        Api.changeFavourite,
        {"vehicle_id": id.toString()},
      );
      final apiResponse = ApiResponse.fromResponse(apiResult);
      if (apiResponse.allGood) {
        print('Yêu thích thành công');
        return true;
      } else {
        print('Yêu thích không thành công');
        return false;
      }
    } else {
      final apiResult = await delete(
        //
        hostUrl: tempApi,
        headers: headers,
        '${Api.changeFavourite}/$id',
      );
      final apiResponse = ApiResponse.fromResponse(apiResult);
      if (apiResponse.allGood) {
        print('Xóa yêu thích không thành công');
        return true;
      } else {
        return false;
      }
    }
  }
}
