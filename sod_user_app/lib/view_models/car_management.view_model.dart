import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/models/car_brand.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/models/vehicle_type.dart';
import 'package:sod_user/requests/car_management.request.dart';
import 'package:sod_user/requests/trip.request.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/services/geocoder.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'dart:math' as math;
import 'package:path_provider/path_provider.dart';

class CarManagementViewModel extends MyBaseViewModel {
  List<CarRental> carRental = [];
  List<CarModel> carModel = [];
  List<CarBrandModel> carBrand = [];
  List<VehicleType> vehicleType = [];
  final carModelController = TextEditingController();
  final vehicleTypeController = TextEditingController();
  final regNoController = TextEditingController();
  final colorController = TextEditingController();
  final yearMadeController = TextEditingController();
  final brandController = TextEditingController();
  final addressController = TextEditingController();
  final rangeOfVehicleController = TextEditingController();
  final rangeOfVehicleTranslateController = TextEditingController();
  double? latitude;
  double? longitude;
  String? carModelId;
  String? vehicleTypeId;
  String? color;
  String? yearMade;
  String? brandId;
  String? describe;
  final describeController = TextEditingController();
  List<File>? newPhotos;
  List<File>? newCarParrotPhotos;
  List<File>? newRegistrationPhotos;
  List<File>? newCivilLiabilityInsurancePhotos;
  List<File>? newVehicleBodyInsurancePhotos;
  List<File>? tempNewUpdatePhotos;
  List<File>? tempNewCarParrotPhotos;
  List<File>? tempNewRegistrationPhotos;
  List<File>? tempNewCivilLiabilityInsurancePhotos;
  List<File>? tempNewVehicleBodyInsurancePhotos;
  File? avatar;
  final picker = ImagePicker();
  List<String>? utilities = [];
  List<String>? requirements = [];
  final price26Controller = TextEditingController();
  final price7cnController = TextEditingController();
  final price26WithDriverController = TextEditingController();
  final price7cnWithDriverController = TextEditingController();
  final drivingFeeController = TextEditingController();
  final price1kmController = TextEditingController();
  String? price26;
  String? price7cn;
  String? price26WithDriver;
  String? price7cnWithDriver;
  String? drivingFee;
  String? price1km;
  int? discountThreeDays;
  int? discountSevenDays;
  RefreshController refreshController = RefreshController();
  RefreshController refreshRequestController = RefreshController();
  CarManagementRequest request = CarManagementRequest();
  TripRequest tripRequest = TripRequest();
  List<CarRental> carRentalRequests = [];
  User? currentUser;
  bool authenticated = false;
  int? rental_options;
  String tempApi = "https://1d5a-27-74-248-77.ngrok-free.app/api";
  initialise() async {
    getMyCar();
    getCarBrand();
    getVehicleType();
    authenticated = await AuthServices.authenticated();
    if (authenticated) {
      currentUser = await AuthServices.getCurrentUser(force: true);
    } else {
      listenToAuthChange();
    }
    notifyListeners();
  }

  StreamSubscription? authStateListenerStream;
  listenToAuthChange() {
    authStateListenerStream?.cancel();
    authStateListenerStream =
        AuthServices.listenToAuthState().listen((event) async {
      if (event != null && event) {
        authenticated = event;
        currentUser = await AuthServices.getCurrentUser(force: true);
        notifyListeners();
        authStateListenerStream?.cancel();
      }
    });
  }

  @override
  void dispose() {
    carModelController.dispose();
    vehicleTypeController.dispose();
    regNoController.dispose();
    colorController.dispose();
    yearMadeController.dispose();
    brandController.dispose();
    addressController.dispose();
    rangeOfVehicleController.dispose();
    rangeOfVehicleTranslateController.dispose();
    super.dispose();
  }

  getMyCar({bool showBusy = true}) async {
    try {
      if (showBusy) {
        setBusy(true);
        carRental = await request.getCar();
        //carRental = await request.getCarByBrand();
        getRequestMyCar();
        refreshController.refreshCompleted();
        refreshRequestController.refreshCompleted();
        setBusy(false);
      } else {
        carRental = await request.getCar();
        //carRental = await request.getCarByBrand();
        getRequestMyCar();
        refreshController.refreshCompleted();
        refreshRequestController.refreshCompleted();
      }
    } catch (e) {
      // An error occurred during the request
      print('Error 22: ${(e as Error).stackTrace}');
    }
  }

  getRequestMyCar() {
    try {
      carRentalRequests = [];
      carRental.forEach((car) {
        if (car.requests!.length != 0) {
          carRentalRequests.add(car);
        }
      });
    } catch (e) {
      // An error occurred during the request
      print('Error: $e');
    }
  }

  getCarModel({required String carMakeId}) async {
    try {
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
      carModel = await request.getCarModel(carMakeId: carMakeId);
    } catch (e) {
      print('Error: $e');
    }
  }

  getCarBrand() async {
    try {
      // print('Lấy brand');
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
      //   print('Brand: ${response.body}');
      //   final responseData = json.decode(response.body);
      //   carBrand = (responseData as List<dynamic>)
      //       .map((data) => CarBrandModel.fromJson(data))
      //       .toList();
      // } else {
      //   print('Request failed with status: ${response.statusCode}');
      //   print('Response body: ${response.body}');
      // }
      carBrand = await request.getCarBrand();
    } catch (e) {
      print("Error: $e");
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
    try {
      bool checkAdd;
      setBusy(true);
      checkAdd = await request.addCarRental(
        carModelId: carModelId,
        vehicleTypeId: vehicleTypeId,
        regNo: regNo,
        color: color,
        yearMade: yearMade,
        utilities: utilities,
        requirementsForRent: requirementsForRent,
        rentPrice1: rentPrice1,
        rentPrice2: rentPrice2,
        rentPrice1WithDriver: rentPrice1WithDriver,
        rentPrice2WithDriver: rentPrice2WithDriver,
        drivingFee: drivingFee,
        price1km: price1km,
        longitude: longitude,
        latitude: latitude,
        discountThreeDays: discountThreeDays,
        discountSevenDays: discountSevenDays,
        photo: photo,
        rental_options: rental_options,
        rangeOfVehicle: rangeOfVehicle,
      );
      await getMyCar();
      setBusy(false);
      return checkAdd;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> updateCar(
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
    bool checkUpdate;
    setBusy(true);
    checkUpdate = await request.updateCarRental(
        id: id,
        carModelId: carModelId,
        vehicleTypeId: vehicleTypeId,
        regNo: regNo,
        color: color,
        yearMade: yearMade,
        utilities: utilities,
        requirementsForRent: requirementsForRent,
        rentPrice1: rentPrice1,
        rentPrice2: rentPrice2,
        rentPrice1WithDriver: rentPrice1WithDriver,
        rentPrice2WithDriver: rentPrice2WithDriver,
        drivingFee: drivingFee,
        price1km: price1km,
        longitude: longitude,
        latitude: latitude,
        discountThreeDays: discountThreeDays,
        discountSevenDays: discountSevenDays,
        carModel: carModel,
        describe: describe,
        deliveryDistance: deliveryDistance,
        deliveryFee: deliveryFee,
        deliveryFree: deliveryFree,
        newCarParrotPhotos: newCarParrotPhotos,
        newRegistrationPhotos: newRegistrationPhotos,
        newCivilLiabilityInsurancePhotos: newCivilLiabilityInsurancePhotos,
        newVehicleBodyInsurancePhotos: newVehicleBodyInsurancePhotos,
        rangeOfVehicle: rangeOfVehicle,
        photo: photo);
    setBusy(false);
    getMyCar();
    notifyListeners();
    return checkUpdate;
  }

  deleteCar({required String id}) async {
    try {
      bool checkDelete;
      setBusy(true);
      checkDelete = await request.deleteCar(id: id);
      setBusy(false);
      if (checkDelete) {
        await AlertService.success(
          title: "Car deleted successfully".tr(),

          //text: ((json.decode(response.body))["message"]).toString().tr(),
        );
      } else {
        await AlertService.error(
          title: "Car deleted unsuccessfully".tr(),
          //text: (json.decode(response.body)["message"]).toString().tr(),
        );
      }
      getMyCar();
      // final response = await http.delete(
      //   Uri.parse(
      //     //"${Api.baseUrl}${Api.deleteCarRental}/${id}",
      //     "${tempApi}/rental/vehicle/$id",
      //   ),
      //   headers: {
      //     "Authorization": "Bearer 88|DSeetHH0eeoASAMZ8xiZTcJ1EsfhPyepYWjYOUek",
      //   },
      // );
      // setBusy(false);
      // if (response.statusCode == 200) {
      //   AlertService.success(
      //     title: "Car deleted successfully".tr(),
      //     text: ((json.decode(response.body))["message"]).toString().tr(),
      //   );
      //   getCar();
      // } else {
      //   AlertService.error(
      //     title: "Car deleted unsuccessfully".tr(),
      //     text: (json.decode(response.body)["message"]).toString().tr(),
      //   );
      //   print('Request failed with status: ${response.statusCode}');
      //   print('Response body: ${response.body}');
      // }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<bool> changeStatusCarRental(
      {required String id, required String status}) async {
    try {
      final apiResponse =
          await request.changeStatusCarRental(id: id, status: status);
      bool checkChange;

      if (apiResponse.allGood) {
        await AlertService.success(
          title: 'Success'.tr(),
          text: "Status changed successfully".tr(),
        );
        checkChange = true;
      } else {
        await AlertService.error(
          title: 'Unsuccessful'.tr(),
          text: apiResponse.message?.tr(),
        );
        checkChange = false;
      }
      getMyCar();
      return checkChange;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> changeStatusFastBooking(
      {required String id, required String status}) async {
    try {
      bool checkChange;
      checkChange =
          await request.changeStatusFastBooking(id: id, status: status);
      if (checkChange) {
        await AlertService.success(
          title: 'Success'.tr(),
          text: "Change quick booking status successfully".tr(),
        );
      } else {
        await AlertService.error(
          title: 'Unsuccessful'.tr(),
          text: "Change quick booking status failed".tr(),
          //text: (json.decode(response.body)["message"]).toString().tr(),
        );
      }
      getMyCar();
      return checkChange;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> changeCarRentalOption(
      {required String id, required int rental_options}) async {
    try {
      bool checkChange;
      checkChange = await request.changeCarRentalOption(
          id: id, rental_options: rental_options);
      if (checkChange) {
        await AlertService.success(
          title: 'Success'.tr(),
          text: "Change option status successfully".tr(),
        );
      } else {
        await AlertService.error(
          title: 'Unsuccessful'.tr(),
          text: "Change option failed".tr(),
          //text: (json.decode(response.body)["message"]).toString().tr(),
        );
      }
      getMyCar();
      return checkChange;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> changeStatusMortgageExemption(
      {required String id, required String status}) async {
    try {
      bool checkChange;
      checkChange =
          await request.changeStatusMortgageExemption(id: id, status: status);
      if (checkChange) {
        await AlertService.success(
          title: 'Success'.tr(),
          text: "Đổi trạng thái tài sản thế chấp thành công".tr(),
        );
      } else {
        await AlertService.error(
          title: 'Unsuccessful'.tr(),
          text: "Đổi trạng thái tài sản thế chấp không thành công".tr(),
          //text: (json.decode(response.body)["message"]).toString().tr(),
        );
      }
      getMyCar();
      return checkChange;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  Future<bool> changeStatusDeliveryToHome(
      {required String id, required String status}) async {
    try {
      bool checkChange;
      checkChange =
          await request.changeStatusDeliveryToHome(id: id, status: status);
      if (checkChange) {
        await AlertService.success(
          title: 'Success'.tr(),
          text: "Cập nhật giao xe tận nơi thành công".tr(),
        );
      } else {
        await AlertService.error(
          title: 'Unsuccessful'.tr(),
          text: "Cập nhật giao xe tận nơi không thành công".tr(),
          //text: (json.decode(response.body)["message"]).toString().tr(),
        );
      }
      getMyCar();
      return checkChange;
    } catch (e) {
      print("Error: $e");
      return false;
    }
  }

  getVehicleType() async {
    try {
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
      vehicleType = await request.getVehicleType();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> getCurrentLocation() async {
    Position position = await GeocoderService().determinePosition();
    longitude = position.longitude;
    latitude = position.latitude;
    print("Longitude: ${position.longitude} - Latitude: ${position.latitude}");
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    addressController.text =
        '${place.name}, ${place.thoroughfare}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.country}';
  }

  Future<void> getLongLatFromAddress(String address) async {
    try {
      setBusy(true);
      List<Location> locations = await locationFromAddress(address);
      longitude = locations.first.longitude;
      latitude = locations.first.latitude;
      addressController.text = address;
      print('Kinh độ: ${locations.first.longitude}');
      print('Vĩ độ: ${locations.first.latitude}');
      setBusy(false);
    } catch (e) {
      print('Lỗi: $e');
    }
  }

  Future<void> choosePhotos() async {
    List<XFile>? pickedFile = await picker.pickMultiImage();
    if (pickedFile.isNotEmpty) {
      newPhotos ??= [];
      newPhotos!.addAll(pickedFile.map((xfile) => File(xfile.path)).toList());
    }
    notifyListeners();
  }

  Future<void> chooseAvatar() async {
    List<XFile>? pickedFile = await picker.pickMultiImage();
    if (pickedFile.isNotEmpty) {
      avatar = File(pickedFile[0].path);
    }
    notifyListeners();
  }

  Future<void> chooseCarParrotPhotos() async {
    final pickedFile = await picker.pickMultiImage();
    if (pickedFile.isNotEmpty) {
      newCarParrotPhotos ??= [];
      newCarParrotPhotos!
          .addAll(pickedFile.map((xfile) => File(xfile.path)).toList());
    }
    notifyListeners();
  }

  Future<void> chooseRegistrationPhotos() async {
    final pickedFile = await picker.pickMultiImage();
    if (pickedFile.isNotEmpty) {
      newRegistrationPhotos ??= [];
      newRegistrationPhotos!
          .addAll(pickedFile.map((xfile) => File(xfile.path)).toList());
    }
    notifyListeners();
  }

  Future<void> chooseCivilLiabilityInsurancePhotos() async {
    final pickedFile = await picker.pickMultiImage();
    if (pickedFile.isNotEmpty) {
      newCivilLiabilityInsurancePhotos ??= [];
      newCivilLiabilityInsurancePhotos!
          .addAll(pickedFile.map((xfile) => File(xfile.path)).toList());
    }
    notifyListeners();
  }

  Future<void> chooseVehicleBodyInsurancePhotos() async {
    final pickedFile = await picker.pickMultiImage();
    if (pickedFile.isNotEmpty) {
      newVehicleBodyInsurancePhotos ??= [];
      newVehicleBodyInsurancePhotos!
          .addAll(pickedFile.map((xfile) => File(xfile.path)).toList());
    }
    notifyListeners();
  }

  Future<bool> cancelTrip(int id) async {
    try {
      bool checkCancel;
      // setBusy(true);
      checkCancel = await tripRequest.cancelTrip(id);
      await getMyCar(showBusy: false);
      //setBusy(false);
      notifyListeners();
      return checkCancel;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> acceptTrip(int id) async {
    try {
      bool check;
      // setBusy(true);
      check = await tripRequest.acceptTrip(id);
      await getMyCar(showBusy: false);
      // setBusy(false);
      notifyListeners();
      return check;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> completedTrip(int id) async {
    try {
      bool check;
      // setBusy(true);
      check = await tripRequest.completedTrip(id);
      await getMyCar(showBusy: false);
      // setBusy(false);
      notifyListeners();
      return check;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }

  Future<bool> fetchData(CarRental data) async {
    if (data.newCarParrotPhotos!.length != 0) {
      List<Future<File>> futureFiles =
          data.newCarParrotPhotos!.map((e) => urlToFile(e)).toList();
      List<File> files = await Future.wait(futureFiles);
      newCarParrotPhotos = files;
    }
    if (data.newCivilLiabilityInsurancePhotos!.length != 0) {
      List<Future<File>> futureFiles = data.newCivilLiabilityInsurancePhotos!
          .map((e) => urlToFile(e))
          .toList();
      List<File> files = await Future.wait(futureFiles);
      newCivilLiabilityInsurancePhotos = files;
    }
    if (data.newRegistrationPhotos!.length != 0) {
      List<Future<File>> futureFiles =
          data.newRegistrationPhotos!.map((e) => urlToFile(e)).toList();
      List<File> files = await Future.wait(futureFiles);
      newRegistrationPhotos = files;
    }
    if (data.newVehicleBodyInsurancePhotos!.length != 0) {
      List<Future<File>> futureFiles =
          data.newVehicleBodyInsurancePhotos!.map((e) => urlToFile(e)).toList();
      List<File> files = await Future.wait(futureFiles);
      newVehicleBodyInsurancePhotos = files;
    }
    return true;
    // Cập nhật trạng thái của widget
  }

  Future<File> urlToFile(String imageUrl) async {
    // generate random number.
    var rng = new math.Random();
    // get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
    // get temporary path from temporary directory.
    String tempPath = tempDir.path;
    // create a new file in temporary path with random file name.
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.jpg');
    // call http.get method and pass imageurl into it to get response.
    http.Response response = await http.get(Uri.parse(imageUrl));
    // write bodybytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
    // now return the file which is created with random name in
    // temporary directory and image bytes from response is written to // that file.
    return file;
  }
}
