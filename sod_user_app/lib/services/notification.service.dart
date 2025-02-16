import 'dart:convert';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart'
    hide NotificationModel;
import 'package:flutter/services.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/driver_lib/models/new_taxi_order.dart';
import 'package:sod_user/driver_lib/services/taxi_background_order.service.dart';
import 'package:sod_user/models/notification.dart';
import 'package:sod_user/services/firebase.service.dart';

import 'local_storage.service.dart';

class NotificationService {
  //
  static const platform = MethodChannel('notifications.manage');

  //
  static initializeAwesomeNotification() async {
    await AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/notification_icon',
      [
        appNotificationChannel(),
        newOrderNotificationChannel(),
      ],
    );
    //request notification permission if not allowed
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // Insert here your friendly dialog box before call the request method
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> clearIrrelevantNotificationChannels() async {
    if (!Platform.isAndroid) {
      return;
    }
    try {
      // get channels
      final List<dynamic> notificationChannels =
          await platform.invokeMethod('getChannels');

      //confirm is more than the required channels is found
      final notificationChannelNames = notificationChannels
          .map(
            (e) => e.toString().split(" -- ")[1],
          )
          .toList();

      //
      final totalFound = notificationChannelNames
          .where(
            (e) =>
                e.toLowerCase() ==
                appNotificationChannel().channelName?.toLowerCase(),
          )
          .toList();

      if (totalFound.length > 1) {
        //delete all app created notifications
        for (final notificationChannel in notificationChannels) {
          //
          final notificationChannelData = "$notificationChannel".split(" -- ");
          final notificationChannelId = notificationChannelData[0];
          final notificationChannelName = notificationChannelData[1];
          final isSystemOwned =
              notificationChannelName.toLowerCase() == "miscellaneous";
          //
          if (!isSystemOwned) {
            //
            await platform.invokeMethod(
              'deleteChannel',
              {"id": notificationChannelId},
            );
          }
        }

        //
        await initializeAwesomeNotification();
      }
    } on PlatformException catch (e) {
      print("Failed to get notification channels: '${e.message}'.");
    }
  }

  static NotificationChannel appNotificationChannel() {
    //firebase fall back channel key
    //fcm_fallback_notification_channel
    return NotificationChannel(
      channelKey: 'basic_channel',
      channelName: 'Basic notifications',
      channelDescription: 'Notification channel for app',
      importance: NotificationImportance.High,
      soundSource: "resource://raw/alert",
      playSound: true,
    );
  }

  static NotificationChannel newOrderNotificationChannel() {
    return NotificationChannel(
      channelKey: 'new_order_channel',
      channelName: 'New Order notifications',
      channelDescription: 'New Order notification channel for app',
      importance: NotificationImportance.High,
      soundSource: "resource://raw/appvietalert",
      playSound: true,
    );
  }

  // Fix Duplicate notification in Notification-PAGE
  static Future<List<NotificationModel>> getNotifications() async {
    //
    final notificationsStringList =
        (await LocalStorageService.getPrefs()).getString(
      AppStrings.notificationsKey,
    );

    if (notificationsStringList == null) {
      return [];
    }

    final Set<String> uniqueNotifications = {};
    final List<NotificationModel> notifications = [];

    (jsonDecode(notificationsStringList) as List)
        .asMap()
        .entries
        .forEach((notificationObject) {
      // Get notification to set Key
      final String title = notificationObject.value["title"];
      final String body = notificationObject.value["body"];

      final String notificationKey = "$title|$body";
      if (!uniqueNotifications.contains(notificationKey)) {
        uniqueNotifications.add(notificationKey);
        notifications.add(
          NotificationModel(
            index: notificationObject.key,
            title: title,
            body: body,
            image: notificationObject.value["image"],
            read: notificationObject.value["read"] is bool
                ? notificationObject.value["read"]
                : false,
            timeStamp: notificationObject.value["timeStamp"],
          ),
        );
      }
    });
    return notifications;
  }

  static void addNotification(NotificationModel notification) async {
    //
    final notifications = await getNotifications();
    notifications.insert(0, notification);

    //
    await LocalStorageService.prefs?.setString(
      AppStrings.notificationsKey,
      jsonEncode(notifications),
    );
  }

  static Future<bool?> removeNotification(
      NotificationModel notificationModel) async {
    //
    final notifications = await getNotifications();
    notifications.removeAt(notificationModel.index!);
    return LocalStorageService.prefs?.setString(
      AppStrings.notificationsKey,
      jsonEncode(notifications),
    );
  }

  static void updateNotification(NotificationModel notificationModel) async {
    //
    final notifications = await getNotifications();
    notifications.removeAt(notificationModel.index!);
    notifications.insert(notificationModel.index!, notificationModel);
    await LocalStorageService.prefs?.setString(
      AppStrings.notificationsKey,
      jsonEncode(notifications),
    );
  }

  static listenToActions() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    print('Action received: ${receivedAction.payload}');
    if (receivedAction.payload != null &&
        receivedAction.payload!.containsKey("newOrder")) {
      final newOrderRawData = jsonDecode(
        receivedAction.payload?["newOrder"] ?? "{}",
      );
      final newOrder = NewTaxiOrder.fromJson(newOrderRawData);
      bool? accpectOrder;
      print("New order: ${newOrder}");

      if (receivedAction.buttonKeyPressed == "accept") {
        // Thực hiện hành động khi người dùng nhấn "Accept"
        accpectOrder = true;
      } else if (receivedAction.buttonKeyPressed == "reject") {
        // Thực hiện hành động khi người dùng nhấn "Reject"
        accpectOrder = false;
      } else if (receivedAction.buttonKeyPressed == "") {
        // Thực hiện hành động khi người dùng không nhấn vào nút nào
        accpectOrder = null;
      }

      final taxiService = TaxiBackgroundOrderService();
      if (!taxiService.checkHasShownNewOrder()) {
        taxiService.setHasShownNewOrder(true);
        taxiService.processOrderNotification(newOrder,
            accpectOrder: accpectOrder);
      }

    } else {
      FirebaseService().saveNewNotification(
        null,
        title: receivedAction.title,
        body: receivedAction.body,
      );
      FirebaseService().notificationPayloadData = receivedAction.payload;
      FirebaseService().selectNotification("");
    }
  }
}
