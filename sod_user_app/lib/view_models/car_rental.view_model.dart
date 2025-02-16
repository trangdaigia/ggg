import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/car_brand.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/models/car_rental_detail.dart';
import 'package:sod_user/models/coordinates.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/models/vehicle_type.dart';
import 'package:sod_user/requests/car_rental.request.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:http/http.dart' as http;
import 'package:sod_user/services/geocoder.service.dart' as geocoderService;
import 'package:sod_user/views/pages/car_rental/car_rental.model.dart';
import 'package:vietmap_flutter_gl/vietmap_flutter_gl.dart' as vietMapGl;
import 'package:vietmap_flutter_plugin/vietmap_flutter_plugin.dart'
    as vietMapFlg;
import 'package:sod_user/services/geocoder.service.dart';
import 'package:vietmap_gl_platform_interface/vietmap_gl_platform_interface.dart'
    as vietMapInterface;

class CarRentalViewModel extends MyBaseViewModel {
  // CarRentalRequest carRentalRequest = CarRentalRequest();
  List<CarRental> carRental = [];
  List<CarBrandModel> carBrand = [];
  List<VehicleType> vehicleType = [];
  CarRentalDetailModel carDetail = CarRentalDetailModel();
  String? carMake = '';
  String? selectedBrandId = '';
  String? selectedBrandText = '';
  String? selectedModelId = '';
  String? selectedYearMake = '';
  final brandController = TextEditingController();
  final yearMakeController = TextEditingController();
  final colorController = TextEditingController();
  final phoneController = TextEditingController();
  var startDate = DateTime.now();
  var endDate = DateTime.now();
  int? totalTimeRent;
  String? startTime;
  String? endTime;
  String? type;
  final addressController = TextEditingController();
  CarRentalRequest request = CarRentalRequest();
  double? longitude = 0;
  double? latitude = 0;
  double? dropOffLongitude = 0;
  double? dropOffLatitude = 0;
  String? pickUpLocation;
  String? dropOffLocation;
  Widget? widgetBottomSheet;
  String tempApi = "https://26e9-27-74-248-77.ngrok-free.app/api";
  RefreshController refreshController = RefreshController();
  RefreshController refreshOwnerVehicleController = RefreshController();
  User? currentUser;
  bool authenticated = false;
  CarRental? car;
  Set<Polyline> gMapPolylines = {};
  PolylinePoints polylinePoints = PolylinePoints();
  List<LatLng> polylineCoordinates = [];
  Coordinates? pickUpLongLat;
  Coordinates? dropOffLongLat;
  CarRentalPeriod? car_Rental_Period;
  vietMapGl.VietmapController? vietMapController;
  List<CarRental> ownerVehicle = [];

  CarRentalPeriod self_driving = CarRentalPeriod(
    start_time: Time(hours: 21, minute: 00),
    end_time: Time(hours: 20, minute: 00),
    start_day: DateTime.now(),
    end_day: DateTime.now().add(Duration(days: 1)),
    total: Time(hours: 24, minute: 00),
    type: 'self_driving',
  );
  //Xe có tài xế
  CarRentalPeriod with_driver = CarRentalPeriod(
    start_time: Time(hours: 8, minute: 00),
    end_time: Time(hours: 10, minute: 00),
    start_day: DateTime.now(),
    end_day: DateTime.now(),
    total: Time(hours: 2, minute: 00),
    type: 'with_driver',
  );
  @override
  void dispose() {
    brandController.dispose();
    yearMakeController.dispose();
    colorController.dispose();
    super.dispose();
  }

  initialise() async {
    vietMapFlg.Vietmap.getInstance(AppStrings.vietMapMapApiKey);

    if (type != null && type == 'xe tự lái') {
      getCarRental(rental_options: '0');
    } else {
      getCarRental(rental_options: '1');
    }
    getRangeOfVehicle();
    getCarBrand();
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

  getOwnerVehicle(int rental_options, int id) async {
    setBusy(true);
    ownerVehicle =
        await request.getOwnerVehicle(rental_options, id, longitude, latitude);
    refreshOwnerVehicleController.loadComplete();
    refreshOwnerVehicleController.refreshCompleted();
    ownerVehicle.forEach((car) {
      car.favouriteUsers!.forEach((user) {
        if (user.id == currentUser!.id) {
          car.like = true;
        } else {
          car.like = false;
        }
      });
    });
    notifyListeners();
    setBusy(false);
  }

  getRangeOfVehicle() async {
    setBusy(true);
    vehicleType = await request.getVehicleType();
    //vehicleType = vehicleType.where((type) => type.vendorTypeId == 6).toList();
    // vehicleType.where((type) => type.vendorTypeId == 6).forEach((element) {
    //   print('Name: ${element.name}');
    // });
  }

  getCarRental({
    String? brand_id = '',
    String? year_made = '',
    String? color = '',
    String? rental_options = '',
    String? rating = '',
    String? vehicle_type_id = '',
    String? fast_booking = '',
    String? mortgage_exemption = '',
    String? discount = '',
    String? free_delivery = '',
  }) async {
    try {
      setBusy(true);
      if (pickUpLocation != null) {
        print('Location qua model: $pickUpLocation');
        await getLongLatFromAddress(pickUpLocation!);
        print('Vị trí qua model: ${latitude}, $longitude');
      }
      carRental = await request.getCar(
        latitude: latitude,
        longitude: longitude,
        rental_options: rental_options,
        brand_id: brand_id,
        year_made: year_made,
        vehicle_type_id: vehicle_type_id,
        rating: rating,
        color: color,
        fast_booking: fast_booking,
        mortgage_exemption: mortgage_exemption,
        discount: discount,
        free_delivery: free_delivery,
      );
      carRental.forEach((car) {
        car.favouriteUsers!.forEach((user) {
          if (user.id == currentUser!.id) {
            car.like = true;
          } else {
            car.like = false;
          }
        });
      });
      refreshController.refreshCompleted();
      refreshController.loadComplete();
      setBusy(false);
    } catch (e) {
      // An error occurred during the request
      print('Error: $e');
    }
  }

  Future<void> getCarDetail({required int id}) async {
    try {
      final response = await http.get(
        Uri.parse(
          "$tempApi/rental/vehicle/$id",
        ),
        headers: {
          "Authorization": "Bearer 88|DSeetHH0eeoASAMZ8xiZTcJ1EsfhPyepYWjYOUek",
        },
      );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        carDetail = CarRentalDetailModel.fromJson(responseData);
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  getCarBrand() async {
    try {
      // final response = await http.get(
      //   Uri.parse(
      //     // Api.getCarBrand,
      //     "$tempApi/partner/car/makes",
      //   ),
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
      setBusy(true);
      carBrand = await request.getCarBrand();
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<void> addRentalRequest({
    required String totalPrice,
    required String totalDays,
    required String status,
    required String debutDate,
    required String expireDate,
    required String contactPhone,
    required String vehicleId,
    required int typee,
    required String pickup_latitude,
    required String pickup_longitude,
    required String dropoff_latitude,
    required String dropoff_longitude,
    required int route,
    required int deliveryToHome,
  }) async {
    setBusy(true);
    try {
      bool checkAdd;
      checkAdd = await request.addRentalRequest(
        route: route,
        totalDays: totalDays,
        status: status,
        debutDate: debutDate,
        expireDate: expireDate,
        contactPhone: contactPhone,
        totalPrice: totalPrice,
        vehicleId: vehicleId,
        type: typee,
        pickup_latitude: pickup_latitude,
        pickup_longitude: pickup_longitude,
        dropoff_latitude: dropoff_latitude,
        dropoff_longitude: dropoff_longitude,
        deliveryToHome: deliveryToHome,
      );
      if (type == 'xe tự lái') {
        await getCarRental(rental_options: '0');
      } else {
        await getCarRental(rental_options: '1');
      }
      if (checkAdd) {
        await AlertService.success(
          title: "Gửi yêu cầu thuê xe thành công".tr(),
        );
      } else {
        await AlertService.error(
          title: "Gửi yêu cầu thuê xe không thành công".tr(),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
    setBusy(false);
  }

  Future<void> addRentalRequestTest({
    required String totalPrice,
    required String totalDays,
    required String status,
    required String debutDate,
    required String expireDate,
    required String contactPhone,
    required String vehicleId,
    required int typee,
    required String pickup_latitude,
    required String pickup_longitude,
    required String dropoff_latitude,
    required String dropoff_longitude,
    required int route,
    required int deliveryToHome,
    required int discount,
    required int subTotal,
    required double deliveryFee,
    required int driverID,
  }) async {
    setBusy(true);
    try {
      bool checkAdd;
      checkAdd = await request.addRentalRequestTest(
        subTotal: subTotal,
        deliveryFee: deliveryFee,
        route: route,
        userID: currentUser!.id,
        totalDays: totalDays,
        status: status,
        debutDate: debutDate,
        expireDate: expireDate,
        contactPhone: contactPhone,
        totalPrice: totalPrice,
        vehicleId: vehicleId,
        type: typee,
        pickup_latitude: pickup_latitude,
        pickup_longitude: pickup_longitude,
        dropoff_latitude: dropoff_latitude,
        dropoff_longitude: dropoff_longitude,
        deliveryToHome: deliveryToHome,
        discount: discount,
        driverID: driverID,
      );
      if (type == 'xe tự lái') {
        await getCarRental(rental_options: '0');
      } else {
        await getCarRental(rental_options: '1');
      }
      if (checkAdd) {
        await AlertService.success(
          title: "Gửi yêu cầu thuê xe thành công".tr(),
        );
      } else {
        await AlertService.error(
          title: "Gửi yêu cầu thuê xe không thành công".tr(),
        );
      }
    } catch (e) {
      print("Error: $e");
    }
    setBusy(false);
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

  // Future<void> getLongLatFromAddress(String address) async {
  //   try {
  //     setBusy(true);
  //     //GeocoderService service = GeocoderService();
  //     List<Location> locations = await locationFromAddress(address);
  //     longitude = locations.first.longitude;
  //     latitude = locations.first.latitude;
  //     addressController.text = address;
  //     print('Kinh độ: ${locations.first.longitude}');
  //     print('Vĩ độ: ${locations.first.latitude}');
  //   } catch (e) {
  //     print('Lỗi: $e');
  //   }
  // }

  Future getLongLatFromAddress(String address, [bool? getLongLat]) async {
    if (getLongLat == null) {
      final apiKey = AppStrings.googleMapApiKey;
      final encodedAddress = Uri.encodeQueryComponent(address);
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;
          final location = results[0]['geometry']['location'];

          latitude = location['lat'] as double;
          longitude = location['lng'] as double;
        }
      }
    } else {
      final apiKey = AppStrings.googleMapApiKey;
      final encodedAddress = Uri.encodeQueryComponent(address);
      final url =
          'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedAddress&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final results = data['results'] as List<dynamic>;
          final location = results[0]['geometry']['location'];

          final latitudee = location['lat'] as double;
          final longitudee = location['lng'] as double;

          print('Vị trí khi sử dụng api lấy1111: ${latitudee} ; $longitudee');
          return Coordinates(latitudee, longitudee);
        }
      }
    }
    notifyListeners();
  }

  int countLocation = 0;
  void update_self_driving(CarRentalPeriod _self_driving) {
    self_driving = _self_driving;
    notifyListeners();
  }

  //Xe có tài xế
  void update_with_driver(CarRentalPeriod _with_driver) {
    with_driver = _with_driver;
    notifyListeners();
  }

  void likeCar(CarRental car, bool favourite) {
    carRental.where((element) => element.id == car.id).toList().first.like =
        favourite;
    notifyListeners();
  }

//Lấy vị trí
  Future<geocoderService.Address?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    if (latitude > 90) {
      latitude = 90.0;
    }
    final coordinates = geocoderService.Coordinates(latitude, longitude);
    geocoderService.GeocoderService service = geocoderService.GeocoderService();
    List<geocoderService.Address> lstAddress = [];
    lstAddress = await service.findAddressesFromCoordinates(coordinates);
    return lstAddress.first;
  }

  Future<double> calculateDistance(
      double lat1, double lon1, double lat2, double lon2,
      [bool? setbusy]) async {
    if (setbusy != null) {
      setBusy(true);
    }

    //vietmapcheck

    if (AppMapSettings.isUsingVietmap) {
      final apiKey = AppStrings.vietMapMapApiKey;
      final url =
          'https://maps.vietmap.vn/api/matrix?api-version=1.1&apikey=$apiKey&point=$lat1,$lon1&point=$lat2,$lon2';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final distanceValue = data["distances"][0][1];
        return distanceValue.toDouble();
      } else {
        //throw Exception('Failed to calculate distance');
        print('Lỗi lấy khoảng cách');
        return 0;
      }
    } else {
      final apiKey = AppStrings.googleMapApiKey;
      final url =
          'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$lat1,$lon1&destinations=$lat2,$lon2&key=$apiKey';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final distanceValue =
            data['rows'][0]['elements'][0]['distance']['value'];
        return distanceValue.toDouble();
      } else {
        //throw Exception('Failed to calculate distance');
        print('Lỗi lấy khoảng cách');
        return 0;
      }
    }
  }

  Future<bool> updateFavourite(int id, bool status) async {
    bool checkUpdate;
    checkUpdate = await request.updateFavourite(id, status);
    if (checkUpdate) {
      print('Thay đổi thành công');
    } else {
      print('Thay đổi không thành công');
    }
    notifyListeners();
    return checkUpdate;
  }

  LatLng? pickUpLatLng;
  LatLng? dropOffLatLng;
  getLongLatPickUpDropOffAndGetPolylines(String pickUp, String? dropOff) async {
    setBusy(true);
    var pickUpLongLat = await getLongLatFromAddress(pickUp, true);
    pickUpLatLng = LatLng(pickUpLongLat.latitude, pickUpLongLat.longitude);
    if (dropOff != null && dropOff != '' && dropOff != 'Nhập địa điểm') {
      print('Vào if có dropOff');
      print('drop: ($dropOff)');
      var dropOffLatLng = await getLongLatFromAddress(dropOff, true);
      dropOffLatLng = LatLng(dropOffLatLng.latitude, dropOffLatLng.longitude);
    }
    if (dropOff != null && dropOff != '' && dropOff != 'Nhập địa điểm') {
      await getPolylines(pickUpLatLng!, dropOffLatLng!);
    }

    setBusy(false);
    notifyListeners();
  }

  getPolylines(LatLng vehicleLocation, LatLng myLocation) async {
    if (AppMapSettings.isUsingVietmap) {
      try {
        List<vietMapGl.LatLng> points = [];
        var routingResponse = await vietMapFlg.Vietmap.routing(
            vietMapFlg.VietMapRoutingParams(points: [
          vietMapFlg.LatLng(myLocation.latitude, myLocation.longitude),
          vietMapFlg.LatLng(vehicleLocation.latitude, vehicleLocation.longitude)
        ]));

        /// Xử lý kết quả trả về
        routingResponse.fold((vietMapFlg.Failure failure) {
          // Xử lý lỗi nếu có
        }, (vietMapFlg.VietMapRoutingModel success) {
          if (success.paths?.isNotEmpty == true &&
              success.paths![0].points?.isNotEmpty == true) {
            points = vietMapInterface.VietmapPolylineDecoder.decodePolyline(
                success.paths![0].points!);
          }
        });

        List<vietMapFlg.LatLng> polylinePoints = points.map((e) {
          return vietMapFlg.LatLng(e.latitude * 10, e.longitude * 10);
        }).toList();

        /// Vẽ đường đi lên bản đồ
        vietMapInterface.Line? line = await vietMapController?.addPolyline(
          vietMapInterface.PolylineOptions(
              geometry: polylinePoints,
              polylineColor: AppColor.primaryColor,
              polylineWidth: 10.0,
              polylineOpacity: 0.6),
        );

        notifyListeners();
      } catch (error) {
        print("getPolyline error");
        print(error);
      }
    } else {
      setBusy(true);
      Set<Polyline> polylines = {};
      print(
          'PickUp La: ${vehicleLocation.latitude}; ${vehicleLocation.longitude}');
      print('Dropoff La: ${myLocation.latitude}; ${myLocation.longitude}');
      polylinePoints
          .getRouteBetweenCoordinates(
        AppStrings.googleMapApiKey,
        PointLatLng(vehicleLocation.latitude, vehicleLocation.longitude),
        PointLatLng(myLocation.latitude, myLocation.longitude),
      )
          .then((PolylineResult polylineResult) {
        List<PointLatLng> result = polylineResult.points;

        if (result.isNotEmpty) {
          List<LatLng> polylineCoordinates = [];
          result.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });

          Polyline polyline = Polyline(
            polylineId: PolylineId("poly"),
            color: AppColor.primaryColor,
            points: polylineCoordinates,
            width: 3,
          );
          polylines.add(polyline);
        }
        print('Số lines:${polylines.length}');
        gMapPolylines = polylines;
        setBusy(false);
      });
      notifyListeners();
    }
  }
}
