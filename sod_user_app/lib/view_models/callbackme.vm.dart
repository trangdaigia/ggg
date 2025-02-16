import 'package:flutter/material.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/models/address.dart';
import 'package:sod_user/models/delivery_address.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/view_models/taxi.vm.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:sod_user/utils/utils.dart';

class CallBackMeViewModel extends TaxiViewModel {
  TextEditingController nameTEC = TextEditingController();
  TextEditingController addressTEC = TextEditingController();
  TextEditingController descriptionTEC = TextEditingController();
  TextEditingController what3wordsTEC = TextEditingController();
  TextEditingController phoneTEC = TextEditingController();
  String note = "";

  bool isDefault = false;
  DeliveryAddress? deliveryAddress = new DeliveryAddress();
  ValueNotifier<String> totalPriceNotifier = ValueNotifier("Đang tính...");
  ValueNotifier<String> statusShip = ValueNotifier("Tài xế đang tìm");
  String driverName = "";
  String driverAvatar = "";
  String licensePlate = "";
  String vehicleInfo = "";

  CallBackMeViewModel(BuildContext context) : super(context, null) {
    this.viewContext = context;
  }

  @override
  Future<void> initialise() async {
    super.initialise();
  }

  showAddressLocationPicker() async {
    dynamic result = await newPlacePicker();

    if (result is PickResult) {
      PickResult locationResult = result;
      addressTEC.text = locationResult.formattedAddress ?? "";
      deliveryAddress!.address = locationResult.formattedAddress;
      deliveryAddress!.latitude = locationResult.geometry?.location.lat;
      deliveryAddress!.longitude = locationResult.geometry?.location.lng;

      if (locationResult.addressComponents != null &&
          locationResult.addressComponents!.isNotEmpty) {
        //fetch city, state and country from address components
        locationResult.addressComponents!.forEach((addressComponent) {
          if (addressComponent.types.contains("locality")) {
            deliveryAddress!.city = addressComponent.longName;
          }
          if (addressComponent.types.contains("administrative_area_level_1")) {
            deliveryAddress!.state = addressComponent.longName;
          }
          if (addressComponent.types.contains("country")) {
            deliveryAddress!.country = addressComponent.longName;
          }
        });
      } else {
        // From coordinates
        setBusy(true);
        deliveryAddress = await getLocationCityName(deliveryAddress!);
        setBusy(false);
      }
      notifyListeners();
    } else if (result is Address) {
      Address locationResult = result;
      addressTEC.text = locationResult.addressLine ?? " ";
      deliveryAddress!.address = locationResult.addressLine ?? " ";
      deliveryAddress!.latitude = locationResult.coordinates?.latitude ?? 0.0;
      deliveryAddress!.longitude = locationResult.coordinates?.longitude ?? 0.0;
      deliveryAddress!.city = locationResult.locality ?? " ";
      deliveryAddress!.state = locationResult.adminArea ?? " ";
      deliveryAddress!.country = locationResult.countryName ?? " ";
    }
  }

  processNewOrder() async {
    if (nameTEC.text.isEmpty || deliveryAddress == null || phoneTEC.text.isEmpty) {
      AlertService.error(
        title: "Error".tr(),
        text: "Please fill all fields".tr(),
      );
      return;
    }

    final forbiddenWord = Utils.checkForbiddenWordsInMap({
      "name": nameTEC.text,
      "note": note,
    });
    if (forbiddenWord != null) {
      await CoolAlert.show(
        context: viewContext,
        type: CoolAlertType.error,
        title: "Warning forbidden words".tr(),
        text: "Your information contains forbidden word".tr() +
            ": $forbiddenWord",
      );
      setBusy(false);
      return;
    }

    showProgressBar();
    final params = {
      "payment_method_id": 1,
      "vehicle_type_id": 34,
      "pickup": {
        "lat": deliveryAddress!.latitude,
        "lng": deliveryAddress!.longitude,
        "address": deliveryAddress!.address,
      },
      "dropoff": {
        "lat": deliveryAddress!.latitude,
        "lng": deliveryAddress!.longitude,
        "address": deliveryAddress!.address,
      },
      "sub_total": 2000.0,
      "total": 2000.0,
      "discount": 0.0,
      "tip": 0,
      "coupon_code": "",
      "vehicle_type": "",
      "taxi_order_type": "ship",
      "package": {
        "weight": 1,
        "ship_package_type": "callbackme",
        "contact_name": nameTEC.text,
        "contact_number": phoneTEC.text,
        "floor_number_or_building_number": "",
        "note_for_driver": note,
        "return_ship_package_type": "none",
        "return_weight": 0
      },
      "contact_number": phoneTEC.text,
      "contact_name": nameTEC.text,
      "ship_package_type": "callbackme",
    };

    // log params
    print(params);
    setBusy(true);
    final apiResponse = await taxiRequest.placeNeworder(
      params: params,
    );
    setBusy(false);

    //if there was an issue placing the order
    if (!apiResponse.allGood) {
      AlertService.error(
        title: "Order failed".tr(),
        text: apiResponse.message,
      );
    } else {
      //
      onGoingOrderTrip = Order.fromJson(apiResponse.body["order"]);
      //payment
      String paymentLink = apiResponse.body["link"];
      if (paymentLink.isNotBlank) {
        await openWebpageLink(paymentLink);
      }
      //
      if (checkout!.pickupDate == null) {
        startHandlingOnGoingTrip();
      } else {
        closeOrderSummary();
      }
    }
  }

  void startHandlingOnGoingTrip() async {
    if (onGoingOrderTrip == null) {
      return;
    }
    tripUpdateStream = firebaseFirestore
        .collection("orders")
        .doc("${onGoingOrderTrip?.code}")
        .snapshots()
        .listen(
      (event) async {
        //once driver is assigned
        final driverId =
            event.data() != null ? event.data()!["driver_id"] ?? null : null;
        if (driverId != null && onGoingOrderTrip?.driverId == null) {
          onGoingOrderTrip?.driverId = event.data()!["driver_id"];
          onGoingOrderTrip?.driver = event.data()!["driver"] ?? null;
        }

        //
        if (onGoingOrderTrip?.driver == null) {
          await loadDriverDetails();
        }
        startDriverDetailsListener();
        //update the rest onGoingTrip details
        if (event.exists) {
          onGoingOrderTrip?.status = event.data()?["status"] ?? "failed";
        }
        //
        notifyListeners();
        loadTripUIByOrderStatus();
      },
    );
  }

  @override
  loadTripUIByOrderStatus({bool initial = false}) {
    print("loadTripUIByOrderStatus");
    if (onGoingOrderTrip == null) {
      return;
    }
    switch (onGoingOrderTrip!.Taxistatus) {
      case "pending":
        renderSearchDriver();
        break;
      case "preparing":
        loadInfoDriver();
        renderTripDetails();
        break;
      case "completed":
        uiDone();
        break;
      case "ready":
        print("ready");
        calculatePrice();
        break;
      case "enroute":
        print("enroute");
        break;
      default:
        break;
    }
  }

  void loadInfoDriver() {
    statusShip = ValueNotifier("Đang trên đường ship đến bạn");
    driverName = onGoingOrderTrip!.driver!.user.name;
    driverAvatar = onGoingOrderTrip!.driver!.user.photo;
    licensePlate = onGoingOrderTrip!.driver!.vehicle!.regNo ?? "";
    vehicleInfo = onGoingOrderTrip!.driver!.vehicle!.vehicleInfo;
  }

  //tính giá tiền bằng khoảng cách tài xế đến nơi nhận hàng x2000
  void calculatePrice() {
    print("calculatePrice");
    final distance = calculateDistance(
      deliveryAddress!.latitude!,
      deliveryAddress!.longitude!,
      driverPosition!.latitude,
      driverPosition!.longitude,
    );
    final price = distance * 2000;
    // nếu dưới 2000 thì giá tiền là 2000, format giá tiền làm tròn 0 chữ số thập phân
    
    if (price < 2000) {
      totalPriceNotifier.value = "2000 vnd";
      return;
    }


    totalPriceNotifier.value = price.toStringAsFixed(0) + " vnd";
  }

  //alert progressbar
  void showProgressBar() {
    showDialog(
      context: viewContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Please wait..."),
            ],
          ),
        );
      },
    );
  }

//hiển thị bottommodal để hiện thông tin chi tiết của tài xế
  void renderTripDetails() {
    print("renderTripDetails");
    Navigator.of(viewContext).pop(); // Đóng modal
    showModalBottomSheet(
      isScrollControlled: true,
      context: viewContext,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return ValueListenableBuilder<String>(
            valueListenable: this.totalPriceNotifier,
            builder: (context, totalPriceNotifier, _) {
              return Container(
                height: MediaQuery.of(context).size.height *
                    0.75, // Tăng chiều cao để có không gian cho yêu cầu món hàng
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Ảnh và tên tài xế với đổ bóng
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                  driverAvatar,
                                ) // Thay bằng ảnh tài xế nếu có
                                ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  driverName,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Row(
                                  children: List.generate(
                                    5,
                                    (index) => Icon(Icons.star,
                                        color: Colors.amber, size: 18),
                                  ),
                                ),
                              ],
                            ),
                            Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  licensePlate,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  vehicleInfo,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Tin nhắn với tài xế với viền bo tròn và đổ bóng nhẹ
                      Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: "Tin nhắn tài xế",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: Colors.grey[400]!),
                            ),
                            prefixIcon:
                                Icon(Icons.message, color: Colors.blueAccent),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Thời gian dự kiến đến với biểu tượng đổ bóng
                      Row(
                        children: [
                          Icon(Icons.access_time, color: Colors.blueAccent),
                          SizedBox(width: 10),
                          Text(
                            'Thời gian dự kiến đến: 8 phút',
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Địa điểm đón
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, color: Colors.blueAccent),
                          SizedBox(width: 10),
                          ValueListenableBuilder<String>(
                              valueListenable: statusShip,
                              builder: (context, statusShip, _) {
                                return Expanded(
                                  child: Text(
                                    "Trạng thái: " + statusShip,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                  ),
                                );
                              }),
                        ],
                      ),
                      SizedBox(height: 12),

                      // Vị trí điểm trả hàng
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.flag, color: Colors.blueAccent),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Vị trí điểm trả hàng: ' +
                                  (deliveryAddress!.address ?? ''),
                              style: TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Yêu cầu món hàng với tên và giá tiền
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: Offset(0, 2),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yêu cầu món hàng',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Icon(Icons.fastfood, color: Colors.blueAccent),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    note,
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black87),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.attach_money,
                                    color: Colors.blueAccent),
                                SizedBox(width: 10),
                                ValueListenableBuilder<String>(
                                  valueListenable: this.totalPriceNotifier,
                                  builder: (context, totalPriceNotifier, _) {
                                    return Expanded(
                                      child: Text(
                                        totalPriceNotifier,
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.black87),
                                      ),
                                    );
                                  }
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),

                      // Mã xác thực với hiệu ứng đổ bóng và gradient
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blueAccent, Colors.lightBlue],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.4),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Mã xác thực/Đặt chỗ",
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "34891",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Nút An toàn và Huỷ bỏ
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Nút "An toàn" với chỉ icon
                            FloatingActionButton(
                              onPressed: () {
                                // Xử lý sự kiện nút An toàn
                              },
                              backgroundColor: Colors.red,
                              child: Icon(Icons.warning, color: Colors.white),
                              tooltip: "An toàn",
                              mini: true,
                              elevation: 5,
                            ),
                            SizedBox(height: 30),
                            // Nút "Huỷ bỏ đặt chỗ"
                            TextButton(
                              onPressed: () {
                                cancelTrip();
                                Navigator.of(context).pop(); // Đóng BottomSheet
                              },
                              child: Text(
                                "Huỷ bỏ đặt chỗ",
                                style:
                                    TextStyle(color: Colors.red, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  renderSearchDriver() {
    // processNewOrder();
    Navigator.of(viewContext).pop(); // Đóng modal

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showModalBottomSheet(
        context: viewContext,
        isDismissible: false, // Không cho phép đóng bằng cách chạm ra ngoài
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        builder: (BuildContext context) {
          return Container(
            padding: EdgeInsets.all(16),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.25,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min, // Để modal vừa với nội dung
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(
                  'Searching for a driver. Please wait...',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    cancelTrip();
                    Navigator.of(context).pop(); // Đóng modal
                  },
                  child: Text('Cancel Booking'),
                ),
              ],
            ),
          );
        },
      );
    });
  }

  void cancelTrip() async {
    //vehicleTypes
    setBusyForObject(onGoingOrderTrip, true);
    try {
      final apiResponse = await taxiRequest.cancelTrip(onGoingOrderTrip!.id);
      //
      if (apiResponse.allGood) {
        toastSuccessful(
            apiResponse.message ?? "Trip cancelled successfully".tr());
        setCurrentStep(1);
        clearMapData();
      } else {
        toastError(apiResponse.message ?? "Failed to cancel trip".tr());
      }
    } catch (error) {
      print("trip ongoing error ==> $error");
    }
    setBusyForObject(onGoingOrderTrip, false);
  }

  //render giao dien khi hoan tat don hang
  void uiDone() {
    Navigator.of(viewContext).pop(); // Đóng modal
    showModalBottomSheet(
      context: viewContext,
      isDismissible: false, // Không cho phép đóng bằng cách chạm ra ngoài
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.25,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Để modal vừa với nội dung
            children: <Widget>[
              Icon(Icons.check_circle, color: Colors.green, size: 50),
              SizedBox(height: 20),
              Text(
                'Your order has been placed successfully',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng modal
                },
                child: Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }
}
