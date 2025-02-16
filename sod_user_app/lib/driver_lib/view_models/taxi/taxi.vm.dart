import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/driver_lib/constants/app_routes.dart';
import 'package:sod_user/driver_lib/constants/app_strings.dart';
import 'package:sod_user/driver_lib/constants/app_ui_settings.dart';
import 'package:sod_user/driver_lib/models/new_taxi_order.dart';
import 'package:sod_user/driver_lib/models/order.dart';
import 'package:sod_user/driver_lib/models/user.dart';
import 'package:sod_user/driver_lib/models/vehicle.dart';
import 'package:sod_user/driver_lib/requests/auth.request.dart';
import 'package:sod_user/driver_lib/requests/order.request.dart';
import 'package:sod_user/driver_lib/requests/taxi.request.dart';
import 'package:sod_user/requests/vehicle.request.dart';
import 'package:sod_user/driver_lib/services/app.service.dart';
import 'package:sod_user/driver_lib/services/appbackground.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/driver_lib/services/chat.service.dart';
import 'package:sod_user/driver_lib/services/firebase.service.dart';
import 'package:sod_user/driver_lib/services/local_storage.service.dart';
import 'package:sod_user/driver_lib/services/order_manager.service.dart';
import 'package:sod_user/driver_lib/services/taxi/new_taxi_booking.service.dart';
import 'package:sod_user/driver_lib/services/taxi/ongoing_taxi_booking.service.dart';
import 'package:sod_user/driver_lib/services/taxi/taxi_google_map_manager.service.dart';
import 'package:sod_user/driver_lib/services/taxi/taxi_location.service.dart';
import 'package:sod_user/driver_lib/services/taxi_background_order.service.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';
import 'package:sod_user/driver_lib/widgets/bottomsheets/user_rating.bottomsheet.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sod_user/driver_lib/views/pages/chat/chat_detail.page.dart';

class TaxiViewModel extends MyBaseViewModel {
  TaxiViewModel(BuildContext context) {
    this.viewContext = context;
  }

  OrderRequest orderRequest = OrderRequest();
  TaxiRequest taxiRequest = TaxiRequest();
  List<Vehicle> vehicles = [];
  VehicleRequest vehicleRequest = VehicleRequest();
  //services
  late TaxiLocationService taxiLocationService;
  late NewTaxiBookingService newTaxiBookingService;
  late OnGoingTaxiBookingService onGoingTaxiBookingService;
  late TaxiMapManagerService taxiMapManagerService;
  AppService appService = AppService();
  AuthRequest authService = AuthRequest();
  BehaviorSubject<Widget?> uiStream = BehaviorSubject<Widget?>();
  //
  Order? onGoingOrderTrip;
  Order? finishedOrderTrip;
  NewTaxiOrder? newOrder;

  @override
  void initialise() async {
    super.initialise();
    //
    taxiMapManagerService = TaxiMapManagerService(this);
    newTaxiBookingService = NewTaxiBookingService(this);
    onGoingTaxiBookingService = OnGoingTaxiBookingService(this);
    taxiLocationService = TaxiLocationService(this);
    await Future.wait([
      taxiMapManagerService.setSourceAndDestinationIcons(),
      vehicleRequest.vehicles().then((e) => vehicles = e)
    ]);

    //
    AppService().driverIsOnline =
        LocalStorageService.prefs!.getBool(AppStrings.onlineOnApp) ?? false;

    // Load the status of driver free/online from firebase
    await OrderManagerService().monitorOnlineStatusListener(
      appService: appService,
    );
    // //update the new taxi booking service listener
    // await newTaxiBookingService.toggleVisibility(appService.driverIsOnline);

    //now check for any on going trip
    await checkForOnGoingTrip();
  }

  checkForOnGoingTrip() async {
    // Make sure driver maker wasn't null
    if (taxiLocationService.driverMarker == null) {
      await taxiLocationService.startListeningToDriverLocation();
    }
    onGoingOrderTrip = await onGoingTaxiBookingService.getOnGoingTrip();
    onGoingTaxiBookingService.loadTripUIByOrderStatus();
  }

//fetch driver online offline
  getOnlineDriverState() async {
    setBusyForObject(appService.driverIsOnline, true);
    try {
      User driverData = await AuthRequest().getMyDetails();
      appService.driverIsOnline = driverData.isOnline;
      //if is online start listening to new trip
      if (appService.driverIsOnline) {
        newTaxiBookingService.startNewOrderListener();
      }
    } catch (error) {
      print("error getting driver data ==> $error");
    }
    setBusyForObject(appService.driverIsOnline, false);
  }

  //update driver state
  Future<bool> syncDriverNewState() async {
    bool updated = false;
    setBusyForObject(appService.driverIsOnline, true);
    try {
      await AuthRequest().switchOnOff(
        isOnline: appService.driverIsOnline,
      );
      updated = true;
    } catch (error) {
      print("error getting driver data ==> $error");
      appService.driverIsOnline = !appService.driverIsOnline;
    }
    setBusyForObject(appService.driverIsOnline, false);
    return updated;
  }

  //
  chatCustomer() {
    openChat(onGoingOrderTrip!.user.id);
    return;

    // Old chat
    // Map<String, PeerUser> peers = {
    //   '${onGoingOrderTrip!.driver!.id}': PeerUser(
    //     id: '${onGoingOrderTrip!.driver!.id}',
    //     name: onGoingOrderTrip!.driver!.name,
    //     image: onGoingOrderTrip!.driver!.photo,
    //   ),
    //   '${onGoingOrderTrip!.user.id}': PeerUser(
    //       id: "${onGoingOrderTrip!.user.id}",
    //       name: onGoingOrderTrip!.user.name,
    //       image: onGoingOrderTrip!.user.photo),
    // };
    // //
    // final chatEntity = ChatEntity(
    //   onMessageSent: ChatService.sendChatMessage,
    //   mainUser: peers['${onGoingOrderTrip?.driver?.id}']!,
    //   peers: peers,
    //   //don't translate this
    //   path: 'orders/' + onGoingOrderTrip!.code + "/customerDriver/chats",
    //   title: "Chat with customer".tr(),
    //   supportMedia: AppUISettings.canDriverChatSupportMedia,
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

  //rate trip
  void showUserRating(Order finishedTrip) async {
    //
    finishedTrip =
        finishedOrderTrip != null ? finishedOrderTrip! : finishedTrip;
    //

    await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => UserRatingBottomSheet(
          order: finishedTrip,
          onSubmitted: () {
            // Navigator.pop(viewContext);
            resetOrderListener();
          },
        ),
      ),
    );

    //
    resetOrderListener();
  }

  resetOrderListener() {
    //
    onGoingOrderTrip = null;
    notifyListeners();
    newTaxiBookingService.startNewOrderListener();
    taxiLocationService.zoomToLocation();
    taxiMapManagerService.updateGoogleMapPadding(20);
  }

  bool isShipOrder() {
    return onGoingOrderTrip!.taxiOrder!.type == 'ship';
  }

  toggleOnlineStatus() async {
    setBusy(true);
    await authService.switchOnOff(
      isOnline: !AppService().driverIsOnline,
    );
    AppService().driverIsOnline = !AppService().driverIsOnline;
    print("Driver status: ${AppService().driverIsOnline}");
    if (AppService().driverIsOnline) {
      if (AppService().driverIsOnline && onGoingOrderTrip == null) {
        NewTaxiBookingService(this).startNewOrderListener();
        AppbackgroundService().startBg();
      } else {
        NewTaxiBookingService(this).startNewOrderListener();
        AppbackgroundService().stopBg();
      }
    }
    await LocalStorageService.prefs!.setBool(
      AppStrings.onlineOnApp,
      AppService().driverIsOnline,
    );
    notifyListeners();
    setBusy(false);
  }
}
