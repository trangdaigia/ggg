import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:sod_user/constants/api.dart';
import 'package:sod_user/constants/app_file_limit.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/car_brand.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/models/vehicle_type.dart';
import 'package:sod_user/services/http.service.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:path/path.dart' as path;

class CarManagementRequest extends HttpService {
  List<CarRental> carRental = [];
  List<CarModel> carModel = [];
  List<CarBrandModel> carBrand = [];
  List<VehicleType> vehicleType = [];
  //String? tempApi = "https://b904-27-74-248-77.ngrok-free.app/api";
  // Map<String, dynamic>? headers = {
  //   "Authorization": "Bearer 262|m936imFbmjx1lIa5LZSYmmlTyTtDtwxJnuVU4EnC",
  // };
  String? tempApi = null;
  Map<String, dynamic>? headers = null;
  Future<List<CarRental>> getCar({
    String? brand_id = "",
    String? carMake = "",
    String? color = "",
  }) async {
    //rental_options : 3 và is_mine: 1 lấy tất cả xe của mình
    final apiResult = await get(
      hostUrl: tempApi,
      headers: headers,
      Api.getCarRental,
      forceRefresh: true,
      queryParameters: {
        "color": color,
        "year_made": carMake,
        "brand_id": brand_id,
        "is_mine": "1",
        "is_driver": '',
        "rental_options": 3
      },
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    print('Full repo: ${apiResponse}');
    if (apiResponse.allGood) {
      print((apiResponse.body as List).map((e) => e['vehicle_type']));
      carRental =
          (apiResponse.body as List).map((e) => CarRental.fromJson(e)).toList();
      return carRental;
    } else {
      throw Exception('Request failed with status: ${apiResult.statusCode}');
    }
    // final response = await http.get(
    //   Uri.parse(
    //     "$tempApi/rental/vehicle?color=$color&year_made=$carMake&brand_id=$brand_id&is_mine=1",
    //   ),
    //   headers: {
    //     "Authorization": "Bearer 88|DSeetHH0eeoASAMZ8xiZTcJ1EsfhPyepYWjYOUek",
    //   },
    // );
    // if (response.statusCode == 200) {
    //   final responseData = json.decode(response.body);
    //   //print('Utilities: ${responseData["utilities"]}');
    //   carRental = (responseData as List<dynamic>)
    //       .map((data) => CarRental.fromJson(data))
    //       .toList();
    // } else {
    //   print('Request failed with status: ${response.statusCode}');
    //   print('Response body: ${response.body}');
    // }
    // return carRental;
  }

  //   final response = await http.get(
  //     Uri.parse(
  //       "$tempApi/rental/vehicle?color=$color&year_made=$carMake&brand_id=$brand_id&is_mine=1&is_driver=0",
  //     ),
  //     headers: {
  //       "Authorization": "Bearer 88|DSeetHH0eeoASAMZ8xiZTcJ1EsfhPyepYWjYOUek",
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     final responseData = json.decode(response.body);
  //     //print('Utilities: ${responseData["utilities"]}');
  //     carRental = (responseData as List<dynamic>)
  //         .map((data) => CarRental.fromJson(data))
  //         .toList();
  //   } else {
  //     print('Request failed with status: ${response.statusCode}');
  //     print('Response body: ${response.body}');
  //   }

  //   return carRental;
  // }

  Future<List<CarModel>> getCarModel({required String carMakeId}) async {
    // final response = await http.get(
    //   Uri.parse(
    //     //"${Api.getCarModel}?car_make_id=$carMakeId",
    //     "${tempApi}/partner/car/models?car_make_id=$carMakeId",
    //   ),
    //   headers: {
    //     "Authorization": "Bearer 88|DSeetHH0eeoASAMZ8xiZTcJ1EsfhPyepYWjYOUek",
    //   },
    // );
    // if (response.statusCode == 200) {
    //   final responseData = json.decode(response.body);
    //   carModel = (responseData as List<dynamic>)
    //       .map((data) => CarModel.fromJson(data))
    //       .toList();
    // } else {
    //   print('Request failed with status: ${response.statusCode}');
    //   print('Response body: ${response.body}');
    // }
    // return carModel;
    final apiResult = await get(
      //
      hostUrl: tempApi,
      headers: headers,
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
    // final response = await http.get(
    //   Uri.parse(
    //     //'${Api.getCarBrand}',
    //     "$tempApi/partner/car/makes",
    //   ),
    //   headers: {
    //     "Authorization": "Bearer 88|DSeetHH0eeoASAMZ8xiZTcJ1EsfhPyepYWjYOUek",
    //   },
    // );
    // if (response.statusCode == 200) {
    //   final responseData = json.decode(response.body);
    //   carBrand = (responseData as List<dynamic>)
    //       .map((data) => CarBrandModel.fromJson(data))
    //       .toList();
    // } else {
    //   print('Request failed with status: ${response.statusCode}');
    //   print('Response body: ${response.body}');
    // }
    // return carBrand;
    final apiResult = await get(
      //
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

  Future<bool> addCarRental(
      {required String carModelId,
      required String vehicleTypeId,
      required regNo,
      required String color,
      required String yearMade,
      required List<String> utilities,
      required List<String> requirementsForRent,
      required String rentPrice1,
      required String rentPrice2,
      required String rentPrice1WithDriver,
      required String rentPrice2WithDriver,
      required String drivingFee,
      required String price1km,
      required String longitude,
      required String latitude,
      required int discountThreeDays,
      required int discountSevenDays,
      required int rental_options,
      required String rangeOfVehicle,
      required List<File> photo}) async {
    Map<String, dynamic> postBody = {
      'car_model_id': carModelId,
      'vehicle_type_id': vehicleTypeId,
      'reg_no': regNo,
      'color': color,
      'year_made': yearMade,
      'utilities': jsonEncode(utilities),
      'requirements_for_rent': jsonEncode(requirementsForRent),
      'price_monday_friday': rentPrice1,
      'price_saturday_sunday': rentPrice2,
      'price_monday_friday_with_driver': rentPrice1WithDriver,
      'price_saturday_sunday_with_driver': rentPrice2WithDriver,
      'driving_fee': drivingFee,
      'price_one_km': price1km,
      'longitude': longitude,
      'latitude': latitude,
      'discount_three_days': discountThreeDays.toString(),
      'discount_seven_days': discountSevenDays.toString(),
      'rental_options': rental_options,
      "range_of_vehicle": rangeOfVehicle,
    };
    FormData formData = FormData.fromMap(postBody);
    if (photo.isNotEmpty) {
      print('Vào for');
      for (File? file in photo) {
        final fileSize = file!.lengthSync() / 1024;
        if (fileSize > AppFileLimit.prescriptionFileSizeLimit) {
          file = await Utils.compressFile(
            file: file,
            quality: 60,
          );
        }
        formData.files.add(
          MapEntry("photos[]", await MultipartFile.fromFile(file!.path)),
        );
      }
    }
    print('from data: ${formData.files.first.key}');
    final apiResult = await postWithFiles(
      hostUrl: tempApi,
      headers: headers,
      Api.addCarRental,
      formData,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      print('Api gút gút');
      return true;
    } else {
      print('Lỗi: ${apiResponse.message}');
      print('Api nô gút gút');
      return false;
    }
  }

  Future<bool> updateCarRental(
      {required int id,
      String? carModelId,
      String? vehicleTypeId,
      String? regNo,
      String? color,
      String? yearMade,
      List<String>? utilities,
      List<String>? requirementsForRent,
      String? rentPrice1,
      String? rentPrice2,
      String? rentPrice1WithDriver,
      String? rentPrice2WithDriver,
      String? drivingFee,
      String? price1km,
      String? longitude,
      String? latitude,
      int? discountThreeDays,
      int? discountSevenDays,
      CarModel? carModel,
      String? describe,
      int? deliveryDistance,
      int? deliveryFee,
      int? deliveryFree,
      List<File>? newCarParrotPhotos,
      List<File>? newRegistrationPhotos,
      List<File>? newCivilLiabilityInsurancePhotos,
      List<File>? newVehicleBodyInsurancePhotos,
      String? rangeOfVehicle,
      List<File>? photo}) async {
    print('Mô tả: ${describe}');
    Map<String, dynamic> postBody = {
      "_method": "PUT",
      if (describe != null) "describe": describe,
      if (deliveryDistance != null) "delivery_distance": deliveryDistance,
      if (deliveryFee != null) "delivery_fee": deliveryFee,
      if (deliveryFree != null) "delivery_free": deliveryFree,
      if (rentPrice1 != null) "price_monday_friday": rentPrice1,
      if (rentPrice2 != null && rentPrice2.isNotEmpty)
        "price_saturday_sunday": rentPrice2,
      if (rentPrice1WithDriver != null)
        "price_monday_friday_with_driver": rentPrice1WithDriver,
      if (rentPrice2WithDriver != null)
        "price_saturday_sunday_with_driver": rentPrice2WithDriver,
      if (drivingFee != null) "driving_fee": drivingFee,
      if (price1km != null) "price_one_km": price1km,
      if (longitude != null && longitude.isNotEmpty) 'longitude': longitude,
      if (latitude != null && latitude.isNotEmpty) 'latitude': latitude,
      if (carModelId != null) 'car_model_id': carModelId,
      if (vehicleTypeId != null) 'vehicleTypeId': vehicleTypeId,
      if (regNo != null) 'reg_no': regNo,
      if (color != null) 'color': color,
      if (yearMade != null) 'year_made': yearMade,
      if (discountThreeDays != null)
        'discount_three_days': discountThreeDays.toString(),
      if (discountSevenDays != null)
        'discount_seven_days': discountSevenDays.toString(),
      if (utilities != null) 'utilities': jsonEncode(utilities),
      if (carModel != null) 'car_model': jsonEncode(carModel.toJson()),
      if (rentPrice1 != null && rentPrice1.isNotEmpty)
        'price_monday_friday': rentPrice1,
      if (rentPrice2 != null && rentPrice2.isNotEmpty)
        'price_saturday_sunday': rentPrice2,
      if (requirementsForRent != null)
        'requirements_for_rent': jsonEncode(requirementsForRent),
      if (rangeOfVehicle != null) 'range_of_vehicle': rangeOfVehicle,
    };
    FormData formData = FormData.fromMap(postBody);
    if (photo != null && photo.isNotEmpty) {
      for (File? file in photo) {
        final fileSize = file!.lengthSync() / 1024;
        if (fileSize > AppFileLimit.prescriptionFileSizeLimit) {
          file = await Utils.compressFile(
            file: file,
            quality: 60,
          );
        }
        formData.files.add(
          MapEntry("photos[]", await MultipartFile.fromFile(file!.path)),
        );
      }
    }
    if (newCarParrotPhotos != null && newCarParrotPhotos.isNotEmpty) {
      for (File? file in newCarParrotPhotos) {
        final fileSize = file!.lengthSync() / 1024;
        if (fileSize > AppFileLimit.prescriptionFileSizeLimit) {
          file = await Utils.compressFile(
            file: file,
            quality: 60,
          );
        }
        formData.files.add(
          MapEntry("new_car_parrot_photos[]",
              await MultipartFile.fromFile(file!.path)),
        );
      }
    }
    if (newRegistrationPhotos != null && newRegistrationPhotos.isNotEmpty) {
      for (File? file in newRegistrationPhotos) {
        final fileSize = file!.lengthSync() / 1024;
        if (fileSize > AppFileLimit.prescriptionFileSizeLimit) {
          file = await Utils.compressFile(
            file: file,
            quality: 60,
          );
        }
        formData.files.add(
          MapEntry("new_registration_photos[]",
              await MultipartFile.fromFile(file!.path)),
        );
      }
    }
    if (newCivilLiabilityInsurancePhotos != null &&
        newCivilLiabilityInsurancePhotos.isNotEmpty) {
      for (File? file in newCivilLiabilityInsurancePhotos) {
        final fileSize = file!.lengthSync() / 1024;
        if (fileSize > AppFileLimit.prescriptionFileSizeLimit) {
          file = await Utils.compressFile(
            file: file,
            quality: 60,
          );
        }
        formData.files.add(
          MapEntry("new_civil_liability_insurance_photos[]",
              await MultipartFile.fromFile(file!.path)),
        );
      }
    }
    if (newVehicleBodyInsurancePhotos != null &&
        newVehicleBodyInsurancePhotos.isNotEmpty) {
      for (File? file in newVehicleBodyInsurancePhotos) {
        final fileSize = file!.lengthSync() / 1024;
        if (fileSize > AppFileLimit.prescriptionFileSizeLimit) {
          file = await Utils.compressFile(
            file: file,
            quality: 60,
          );
        }
        formData.files.add(
          MapEntry("new_vehicle_body_insurance_photos[]",
              await MultipartFile.fromFile(file!.path)),
        );
      }
    }
    formData.files.forEach((element) {
      print('KeyFile: ${element.key}; ValueFile: ${element.value.filename}');
    });
    formData.fields.forEach((element) {
      print('KeyField: ${element.key}; ValueField: ${element.value}');
    });
    print('Id xe la: $id');
    final apiResult = await patchWithFiles(
      hostUrl: tempApi,
      headers: headers,
      "${Api.getCarRental}/$id",
      formData,
    );
    // final response = await http.put(uri,
    //     headers: {
    //       'Authorization': 'Bearer 88|DSeetHH0eeoASAMZ8xiZTcJ1EsfhPyepYWjYOUek',
    //     },
    //     body: requestBody);
    // if (response.statusCode == 200) {
    //   print('Sửa thành công');
    //   print(response.body);
    //   return true;
    // } else {
    //   print('Lỗi cập nhật thông tin cho thuê xe: ${response.statusCode}');
    //   return false;
    // }

    // Dio newdio = Dio();
    // final apiResult = await newdio.patch(
    //   Api.baseUrl + Api.getCarRental + "/$id",
    //   data: formData,
    //   options: Options(
    //     headers: {
    //       'Authorization':
    //           'Bearer 890|JZ2rzh6Nxp3QmYZYRYUMENmFrw4AHqzrVqXoqvCV6a087d61',
    //     },
    //   ),
    // );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      print('Status: ${apiResponse.message}');
      return true;
    } else {
      print('Status: ${apiResponse.message}');
      return false;
    }
  }

  Future<bool> deleteCar({required String id}) async {
    // final response = await http.delete(
    //   Uri.parse(
    //     //"${Api.baseUrl}${Api.deleteCarRental}/${id}",
    //     "${tempApi}/rental/vehicle/$id",
    //   ),
    //   headers: {
    //     "Authorization": "Bearer 88|DSeetHH0eeoASAMZ8xiZTcJ1EsfhPyepYWjYOUek",
    //   },
    // );
    // if (response.statusCode == 200) {
    //   return true;
    // } else {
    //   return false;
    // }
    final apiResult = await delete(
      //

      '${Api.deleteCarRental}/$id',
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return true;
    } else {
      return false;
    }
  }

  Future<ApiResponse> changeStatusCarRental(
      {required String id, required String status}) async {
    //${Api.changeStatusCarRental}/${id}
    // print('Change status: $status');
    // final String urlAPI = '$tempApi';
    // final String endpoint = '/rental/vehicle/$id';
    // final Uri uri = Uri.parse('$urlAPI$endpoint');
    // final response = await http.put(uri, headers: {
    //   'Authorization': 'Bearer 88|DSeetHH0eeoASAMZ8xiZTcJ1EsfhPyepYWjYOUek',
    // }, body: {
    //   "rent_status": status
    // });
    // if (response.statusCode == 200) {
    //   print('Đổi trạng thái thành công');
    //   print(response.body);
    //   return true;
    // } else {
    //   print('Lỗi cập nhật thông tin cho thuê xe: ${response.statusCode}');
    //   return false;
    // }
    final apiResult = await patch(
      hostUrl: tempApi,
      headers: headers,
      Api.changeStatusCarRental + "/$id",
      {
        "rent_status": status,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);

    return apiResponse;
  }

  Future<bool> changeStatusFastBooking(
      {required String id, required String status}) async {
    final apiResult = await patch(
      Api.changeStatusCarRental + "/$id",
      hostUrl: tempApi,
      headers: headers,
      {
        "fast_booking": status,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return true;
    } else {
      throw false;
    }
  }

  Future<bool> changeCarRentalOption(
      {required String id, required int rental_options}) async {
    final apiResult = await patch(
      Api.changeStatusCarRental + "/$id",
      hostUrl: tempApi,
      headers: headers,
      {
        "rental_options": rental_options,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return true;
    } else {
      throw false;
    }
  }

  Future<bool> changeStatusMortgageExemption(
      {required String id, required String status}) async {
    //${Api.changeStatusCarRental}/${id}
    // print('Change status: $status');
    // final String urlAPI = '$tempApi';
    // final String endpoint = '/rental/vehicle/$id';
    // final Uri uri = Uri.parse('$urlAPI$endpoint');
    // final response = await http.put(uri, headers: {
    //   'Authorization': 'Bearer 88|DSeetHH0eeoASAMZ8xiZTcJ1EsfhPyepYWjYOUek',
    // }, body: {
    //   "mortgage_exemption": status
    // });
    // if (response.statusCode == 200) {
    //   print('Đổi trạng thái tài sản thế chấp thành công');
    //   print(response.body);
    //   return true;
    // } else {
    //   print(
    //       'Lỗi đổi trạng thái tài sản thế chấp cho thuê xe: ${response.statusCode}');
    //   return false;
    // }
    final apiResult = await patch(
      hostUrl: tempApi,
      headers: headers,
      Api.changeStatusCarRental + "/$id",
      {
        "mortgage_exemption": status,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return true;
    } else {
      throw false;
    }
  }

  Future<bool> changeStatusDeliveryToHome(
      {required String id, required String status}) async {
    //${Api.changeStatusCarRental}/${id}
    // print('Change status: $status');
    // final String urlAPI = '$tempApi';
    // final String endpoint = '/rental/vehicle/$id';
    // final Uri uri = Uri.parse('$urlAPI$endpoint');
    // final response = await http.put(uri, headers: {
    //   'Authorization': 'Bearer 88|DSeetHH0eeoASAMZ8xiZTcJ1EsfhPyepYWjYOUek',
    // }, body: {
    //   "delivery_to_home": status
    // });
    // if (response.statusCode == 200) {
    //   print('Đổi trạng thái giao xe tận nơi thành công');
    //   print(response.body);
    //   return true;
    // } else {
    //   print('Lỗi giao xe tận nơi cho thuê xe: ${response.statusCode}');
    //   return false;
    // }
    final apiResult = await patch(
      hostUrl: tempApi,
      headers: headers,
      Api.changeStatusCarRental + "/$id",
      {
        "delivery_to_home": status,
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return true;
    } else {
      throw false;
    }
  }

  Future<List<VehicleType>> getVehicleType() async {
    // final response = await http.get(
    //   Uri.parse(
    //       //   Api.getVehicleType
    //       // ),
    //       "$tempApi/vehicle/types"),
    // );
    // if (response.statusCode == 200) {
    //   final responseData = json.decode(response.body);
    //   vehicleType = (responseData as List<dynamic>)
    //       .map((data) => VehicleType.fromJson(data))
    //       .toList();
    // } else {
    //   print('Request failed with status: ${response.statusCode}');
    //   print('Response body: ${response.body}');
    // }
    // return vehicleType;
    final apiResult = await get(
      "${Api.vehicleTypes}",
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
}

class ToImageData {
  static String imagetoData(String? imagepath) {
    final extension = path.extension(
      imagepath!.substring(imagepath.lastIndexOf("/")).replaceAll("/", ""),
    );
    final bytes = File(imagepath).readAsBytesSync();
    String base64 =
        "data:image/${extension.replaceAll(".", "")};base64,${base64Encode(bytes)}";
    return base64;
  }
}
