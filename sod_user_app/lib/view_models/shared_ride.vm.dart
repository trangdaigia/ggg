import 'dart:convert';

import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/constants/app_finance_settings.dart';
import 'package:sod_user/constants/app_languages.dart';
import 'package:sod_user/constants/app_map_settings.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_ui_settings.dart';
import 'package:sod_user/global/global_variable.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/models/payment_method.dart';
import 'package:sod_user/models/shared_ride.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/models/vehicle.dart';
import 'package:sod_user/requests/chat.request.dart';
import 'package:sod_user/requests/checkout.request.dart';
import 'package:sod_user/requests/order.request.dart';
import 'package:sod_user/requests/shared_ride.request.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/services/chat.service.dart';
import 'package:sod_user/services/firebase.service.dart';
import 'package:sod_user/services/geocoder.service.dart';
import 'package:sod_user/utils/translate_for_flavor.utils.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/utils/vnd_text_editing_controller.dart';
import 'package:sod_user/view_models/payment.view_model.dart';
import 'package:sod_user/views/pages/chat/chat_detail.page.dart';
import 'package:sod_user/views/pages/shared_ride/book_shared_ride_success.page.dart';
import 'package:sod_user/views/pages/shared_ride/post_ride_info.page.dart';
import 'package:sod_user/views/pages/shared_ride/post_ride_success.page.dart';
import 'package:sod_user/views/pages/shared_ride/search_share_ride.page.dart';
import 'package:sod_user/views/shared/payment_method_selection.page.dart';
import 'package:velocity_x/velocity_x.dart';

class SharedRideViewModel extends PaymentViewModel {
  TextEditingController departure = TextEditingController();
  TextEditingController destination = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController number_of_seat = TextEditingController();
  LatLng? depatureLatLong;
  LatLng? destinationLatLong;
  int? duration, distance;
  final priceController = VNDTextEditingController();
  final packagePriceController = VNDTextEditingController();
  final noteController = TextEditingController();
  List<Vehicle> vehicles = [];
  Vehicle? selectedVehicle;
  int? minPrice, maxPrice;
  String? endTime;

  //PeerUser? otherPeer;
  PeerUser? mainUserPeer;
  List<PeerUser> listOtherPeersUser = [];
  List<Order> listOrderPeerUser = [];
  SharedRideRequest sharedRideRequest = SharedRideRequest();
  OrderRequest orderRequest = OrderRequest();
  CheckoutRequest checkoutRequest = CheckoutRequest();
  SharedRide? detailedRide;
  List<SharedRide> sharedRides = [];
  List<SharedRide> bookableShareRides = [];
  List<SharedRide> nonExpiredsharedRides = [];
  List<SharedRide> expiredsharedRides = [];
  List<SharedRide> bookedSharedRides = [];
  String chooseFilterOption = "earliest";
  RefreshController searchRefreshController =
      RefreshController(initialRefresh: false);
  RefreshController nonExpiredRefreshController =
      RefreshController(initialRefresh: false);
  RefreshController expiredRefreshController =
      RefreshController(initialRefresh: false);
  TextEditingController cancelReason = TextEditingController();
  Map<String, dynamic> searchMap = {};
  String? departureCity, destinationCity;
  TextEditingController widthController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController lengthController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController bookWeightController = TextEditingController();
  String type = "person";
  List<String> searchTypes = ['person', 'package'];
  User? currentUser;
  Order? myOrderedRide;
  List<PaymentMethod>? paymentMethods;
  PaymentMethod? selectedPaymentMethod;

  var timeNow =
      "${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}";

  SharedRideViewModel(BuildContext context) {
    this.viewContext = context;
    number_of_seat.text = "1";
  }

  updateFilterOption(String option) {
    chooseFilterOption = option;
    notifyListeners();
  }

  initialise() async {
    currentUser = await AuthServices.getCurrentUser();
    getSharedRides({"status": "new", "is_search": "0", "history": "0"});
    getBookedSharedRides({"history": "1"});
    getRentalVehicles();
    notifyListeners();
  }

  calculatePrice() {
    TextEditingController temp = TextEditingController();
    if (AppFinanceSettings.enableSharedRidePrice) {
      temp.text = Utils.formatCurrencyVND(double.parse(
              (AppFinanceSettings.sharedRideChargePerKM *
                      (distance! / 1000).ceil())
                  .toString()))
          .split(" ")[0];
      priceController.value = temp.value;
    }
    minPrice = 0;
    maxPrice = 0;
  }

  calculateEndTime() {
    List<String> tempTime = time.text.split(':');
    int tempHour = int.parse(tempTime[0]);
    int tempMinute = int.parse(tempTime[1]);
    int hourDuration = ((duration! ~/ 60).ceil() ~/ 60).toInt();
    int minuteDuration = ((duration! ~/ 60).ceil() % 60).toInt();
    int endHour = tempHour + hourDuration;
    int endMinute = tempMinute + minuteDuration;
    while (endHour > 24) {
      endHour = endHour - 24;
    }
    if (endMinute > 60) {
      endHour += 1;
      endMinute = endMinute - 60;
    }
    endHour = endHour == 24 ? 0 : endHour;
    endTime =
        "${endHour < 10 ? "0${endHour.toString()}" : endHour.toString()}:${endMinute < 10 ? "0${endMinute.toString()}" : endMinute.toString()}";
  }

  fetchPaymentOptions() async {
    setBusyForObject(paymentMethods, true);
    print("Fetching Payment Options ...");
    try {
      paymentMethods = await checkoutRequest.getPaymentOptions();
      clearErrors();
    } catch (error) {
      print("Error getting payment methods ==> $error");
    }
    setBusyForObject(paymentMethods, false);
  }

  updateSharedRide({String? type}) async {
    final params = {
      "type": type,
      "start_date": date.text,
      "start_time": time.text,
      "number_of_seat": number_of_seat.text,
      "note": noteController.text,
      "price": priceController.originalText,
      "id": detailedRide!.id,
    };
    setBusy(true);
    final apiResponse =
        await sharedRideRequest.updateSharedRide(params: params);
    GlobalVariable.refreshCache = true;
    setBusy(false);
    if (!apiResponse.allGood) {
      AlertService.error(
        title: "Updated ride failed".tr(),
        text: apiResponse.message!.tr(),
      );
    }
  }

  // Update: Send to all user has been accepted in Shared_ride.
  cancelSharedRide() async {
    mainUserPeer =
        PeerUser(id: currentUser!.id.toString(), name: currentUser!.name);
    final params = {
      "id": detailedRide!.id,
      "cancel_reason": cancelReason.text,
    };
    setBusy(true);
    final apiResponse =
        await sharedRideRequest.cancelSharedRide(params: params);
    setBusy(false);
    if (!apiResponse.allGood) {
      AlertService.error(
        title: "Canceled ride failed".tr(),
        text: apiResponse.message!.tr(),
      );
    } else {
      for (var order in detailedRide!.orders!) {
        if (order.status == "ready") {
          listOrderPeerUser.add(order);
        }
      }
      for (var order in listOrderPeerUser) {
        PeerUser peerUser =
            PeerUser(id: order.user.id.toString(), name: order.user.name);
        listOtherPeersUser.add(peerUser);
      }
      for (var oPeerUser in listOtherPeersUser) {
        await ChatRequest().sendNotification(
          title: AppLanguages.names == "Vietnamese"
              ? "Trip Cancelled!"
              : "Chuyến xe đã bị huỷ",
          body: AppLanguages.names == "Vietnamese"
              ? "#${detailedRide!.id} Trip Cancelled!"
              : "Chuyến xe #${detailedRide!.id} đã bị huỷ",
          topic: oPeerUser.id,
          path: "",
          user: mainUserPeer!,
          otherUser: oPeerUser,
        );
        //print("Completed Send Notification to ${oPeerUser.name} at $timeNow");
      }
      GlobalVariable.refreshCache = true;
      AlertService.success(
        title: "Canceled ride successfully".tr(),
        text: apiResponse.message!.tr(),
      );
      getSharedRides({"status": "new", "is_search": "0"});
    }
  }

  getSharedRides(Map<String, dynamic>? params) async {
    setBusyForObject(sharedRides, true);
    setBusyForObject(bookableShareRides, true);
    expiredsharedRides.clear();
    nonExpiredsharedRides.clear();
    try {
      sharedRides = await sharedRideRequest.getSharedRides(params);
      sharedRides.forEach((e) {
        if (e.expired) {
          expiredsharedRides.add(e);
        } else {
          nonExpiredsharedRides.add(e);
          if (!e.isMine) bookableShareRides.add(e);
        }
        GlobalVariable.refreshCache = true;
      });
    } catch (error) {
      print("Error ==> $error");
    }
    setBusyForObject(sharedRides, false);
    setBusyForObject(bookableShareRides, false);
  }

  getBookedSharedRides(Map<String, dynamic>? payload) async {
    setBusyForObject(bookedSharedRides, true);
    try {
      GlobalVariable.refreshCache = true;
      bookedSharedRides = await sharedRideRequest.getSharedRides(payload);
    } catch (error) {
      print("Error ==> $error");
    }
    GlobalVariable.refreshCache = true;
    setBusyForObject(bookedSharedRides, false);
  }

  getRentalVehicles() async {
    setBusyForObject(vehicles, true);
    try {
      vehicles = await sharedRideRequest.getRentalVehicles();
      selectedVehicle = vehicles[0];
    } catch (error) {
      print("Error ==> $error");
    }
    setBusyForObject(vehicles, false);
    notifyListeners();
  }

  postSharedRide(SharedRideViewModel model) async {
    setBusy(true);
    final packageDetails = {
      'width': widthController.text,
      'height': heightController.text,
      'length': lengthController.text,
      'weight': weightController.text,
      'price': packagePriceController.originalText,
    };
    final params = {
      "price": int.parse(priceController.originalText),
      "departure_name": departure.text,
      "destination_name": destination.text,
      "start_date": date.text,
      "start_time": time.text,
      "number_of_seat": type == "package" ? null : number_of_seat.text,
      "end_time": endTime,
      "distance": distance.toString(),
      "duration": duration.toString(),
      "vehicle_id": selectedVehicle!.id,
      "note": noteController.text,
      "status": "new",
      "min_price": minPrice.toString(),
      "max_price": maxPrice.toString(),
      "type": type,
      "departure_city": departureCity,
      "destination_city": destinationCity,
      "package_details": type == "person" ? null : jsonEncode(packageDetails),
    };
    SharedRide? ride;
    final apiResponse = await sharedRideRequest.postSharedRide(params: params);
    if (!apiResponse.allGood) {
      AlertService.error(
        title: "Post ride failed".tr(),
        text: apiResponse.message!.tr(),
      );
      setBusy(false);
    } else {
      GlobalVariable.refreshCache = true;
      await getSharedRides({"status": "new", "is_search": "0", "history": "0"});
      for (var r in sharedRides) {
        print(
            "Share-ride has been posted is : ${r.departureName} : ${r.destinationName} : ${r.startTime} : ${r.vehicle}");
        if (r.departureName == departure.text &&
            r.destinationName == destination.text &&
            r.startDate == date.text &&
            r.startTime == time.text) {
          ride = r;
        }
      }
      ride != null
          ? {
              viewContext.nextPage(PostRideSuccessPage(
                model: model,
                sharedRide: ride,
              )),
              setBusy(false)
            }
          : {viewContext.nextPage(SearchRidePage()), setBusy(false)};
    }
  }

  checkCanProceedToInfoScreen() async {
    if (formKey.currentState!.validate()) {
      if (departureCity == destinationCity) {
        AlertService.error(
          title: "Unable to proceed".tr(),
          text: "Only support intercity".tr(),
        );
        return;
      }
      await GeocoderService.getDurationDistance(
              depatureLatLong!, destinationLatLong!)
          .then((durationValue) async {
        //vietmapcheck
        if (durationValue != null) {
          if (AppMapSettings.isUsingVietmap) {
            duration =
                double.tryParse(durationValue["durations"][0][1].toString())
                    ?.toInt();
            distance =
                double.tryParse(durationValue["distances"][0][1].toString())
                    ?.toInt();
          } else {
            distance = (durationValue['rows']
                .first['elements']
                .first['distance']['value']);
            duration = (durationValue['rows']
                .first['elements']
                .first['duration']['value']);
          }
        }
      });
      if (time.value.text.isEmpty)
        time.text = DateFormat("HH:mm").format(DateTime.now());
      if (date.value.text.isEmpty)
        date.text = DateFormat("dd-MM-yyyy").format(DateTime.now());
      viewContext.nextPage(PostRideInfoPage(model: this));
    }
  }

  bookSharedRide(int? id, LatLng latLng, SharedRideViewModel model) async {
    try {
      setBusy(true);
      print('Số chổ ngồi của xe: ${detailedRide!.numberOfSeat}');
      print('Số chổ đặt: ${number_of_seat.text}');
      final apiResponse = await sharedRideRequest.bookSharedRide(payload: {
        'weight': bookWeightController.text,
        'shared_ride_id': id,
        'latitude': latLng.latitude,
        'longitude': latLng.longitude,
        'type': 'shared_ride',
        'payment_method_id': selectedPaymentMethod!.id,
        'shared_ride_tickets': number_of_seat.text,
      });
      if (apiResponse.body['error'] != null) {
        viewContext.showToast(
          msg: apiResponse.body['message'],
          bgColor: Colors.red,
          textColor: Colors.white,
        );
        setBusy(false);
        return;
      }
      setBusy(false);
      if (!["wallet", "cash"].contains(selectedPaymentMethod?.slug)) {
        if (selectedPaymentMethod?.slug == "offline") {
          await openExternalWebpageLink(apiResponse.body['link']);
        } else {
          await openWebpageLink(apiResponse.body['link']);
        }
      } else {
        toastSuccessful("${apiResponse.body['message']}");
      }
      //notify wallet view to update, just incase wallet was use for payment
      AppService().refreshWalletBalance.add(true);
      detailedRide!.price = (apiResponse.body['total']);
      GlobalVariable.refreshCache = true;
      viewContext.nextAndRemoveUntilPage(BookSharedRideSuccessPage(
          sharedRideModel: model,
          ride: detailedRide!,
          weight: bookWeightController.text,
          number_of_seat: number_of_seat.text,
          bookedRide: detailedRide!));
    } catch (error) {
      print("Error ==> $error");
    }
  }

  cancelBookedRide() async {
    setBusy(true);
    try {
      final responseMessage = await orderRequest.updateOrder(
        id: myOrderedRide!.id,
        status: "cancelled",
        reason: "",
      );
      //message
      GlobalVariable.refreshCache = true;
      viewContext.showToast(
        msg: responseMessage,
        bgColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pop(viewContext);
      clearErrors();
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      viewContext.showToast(
        msg: "$error",
        bgColor: Colors.red,
        textColor: Colors.white,
      );
    }
    setBusy(false);
  }

  Future<bool> acceptOrderBookedRide(int? id, User? customer) async {
    setBusy(true);
    try {
      final apiResponse = await sharedRideRequest.updateOrderSharedRide(
        id: id,
        status: "ready",
      );
      //message
      if (!apiResponse.allGood) {
        await initialise;
        AlertService.error(
          title: "Shared Ride Failed".tr(),
          text: "You have canceled a shared ride with ${apiResponse.message}"
              .tr(),
        );
        setBusy(false);
        return false;
      } else {
        await initialise;
        AlertService.success(
          title: "Shared Ride Accepted".tr(),
          text: "You have accepted a shared ride with ${apiResponse.message}"
              .tr(),
        );
        setBusy(false);
      }
      clearErrors();
      return true;
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      viewContext.showToast(
        msg: "$error",
        bgColor: Colors.red,
        textColor: Colors.white,
      );
      setBusy(false);
    }
    setBusy(false);
    return false;
  }

  Future<bool> cancelOrderBookedRide(int? id) async {
    setBusy(true);
    try {
      final apiResponse = await sharedRideRequest.updateOrderSharedRide(
        id: id,
        status: "cancelled",
      );
      //message
      if (!apiResponse.allGood) {
        await initialise;
        AlertService.error(
          title: "Cancelled order shared ride failed".tr(),
          text: apiResponse.message!.tr(),
        );
        setBusy(false);
        return false;
      } else {
        GlobalVariable.refreshCache = true;
        await initialise;
        AlertService.success(
          title: "Cancelled order shared ride successfully".tr(),
          text: apiResponse.message!.tr(),
        );
        setBusy(false);
      }
      clearErrors();
      return true;
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      viewContext.showToast(
        msg: "$error",
        bgColor: Colors.red,
        textColor: Colors.white,
      );
      setBusy(false);
    }
    setBusy(false);
    return false;
  }

  openPaymentMethodSelection(int? id, LatLng latLng) async {
    //
    if (paymentMethods == null) {
      await fetchPaymentOptions();
    }

    final mPaymentMethod = await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => PaymentMethodSelectionPage(
          list: paymentMethods!,
        ),
      ),
    );
    if (mPaymentMethod != null) {
      selectedPaymentMethod = mPaymentMethod;
      bookSharedRide(id, latLng, this);
    }
    notifyListeners();
  }

  chatDriver() {
    openChat(myOrderedRide!.driver?.id);
    return;

    // Old chat
    // Map<String, PeerUser> peers = {
    //   '${myOrderedRide!.userId}': PeerUser(
    //     id: '${myOrderedRide!.userId}',
    //     name: myOrderedRide!.user.name,
    //     image: myOrderedRide!.user.photo,
    //   ),
    //   '${myOrderedRide!.driver?.id}': PeerUser(
    //       id: "${myOrderedRide!.driver?.id}",
    //       name: myOrderedRide!.driver?.name ?? "Driver".tr(),
    //       image: myOrderedRide!.driver?.photo),
    // };
    // //
    // final chatEntity = ChatEntity(
    //   mainUser: peers['${myOrderedRide!.userId}']!,
    //   peers: peers,
    //   //don't translate this
    //   path: 'orders/' + myOrderedRide!.code + "/customerDriver/chats",
    //   title: TranslateUtils.getTranslateForFlavor("Chat with driver").tr(),
    //   onMessageSent: ChatService.sendChatMessage,
    //   supportMedia: AppUISettings.canCustomerChatSupportMedia,
    // );
    // //
    // Navigator.of(viewContext).pushNamed(
    //   AppRoutes.chatRoute,
    //   arguments: chatEntity,
    // );
  }

  chatCustomer(User? customer, Order? order) {
    openChat(customer!.id);
    return;

    // Old chat
    // Map<String, PeerUser> peers = {
    //   '${currentUser!.id}': PeerUser(
    //     id: '${currentUser!.id}',
    //     name: currentUser!.name,
    //     image: currentUser!.photo,
    //   ),
    //   '${customer!.id}': PeerUser(
    //       id: "${customer.id}", name: customer.name, image: customer.photo),
    // };
    // //
    // final chatEntity = ChatEntity(
    //   onMessageSent: ChatService.sendChatMessage,
    //   mainUser: peers['${currentUser!.id}']!,
    //   peers: peers,
    //   //don't translate this
    //   path: 'orders/' + order!.code + "/customerDriver/chats",
    //   title: "Chat with customer".tr(),
    //   supportMedia: AppUISettings.canCustomerChatSupportMedia,
    // );
    // //
    // Navigator.of(viewContext).pushNamed(
    //   AppRoutes.chatRoute,
    //   arguments: chatEntity,
    // );
  }

  void openChat(int? otherUserId) async {
    if (otherUserId == null) return;

    final currentUser = await AuthServices.getCurrentUser();
    final currentUserId = currentUser.id;
    final otherUser = await FirebaseService().getUserById(otherUserId);
    final chatId =
        await FirebaseService().createChat(currentUserId, otherUserId);

    Navigator.of(viewContext).push(MaterialPageRoute(builder: (context) {
      return ChatDetailPage(
        chatId: chatId,
        currentUserId: currentUserId,
        otherUser: otherUser,
      );
    }));
  }
}
