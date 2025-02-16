import 'package:flutter/cupertino.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/models/notification.dart';
import 'package:sod_user/services/notification.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:intl/intl.dart';

class NotificationsViewModel extends MyBaseViewModel {
  //
  List<NotificationModel> notifications = [];

  NotificationsViewModel(BuildContext context) {
    this.viewContext = context;
  }

  @override
  void initialise() async {
    super.initialise();
    //getting notifications from local storage
    getNotifications();
  }

  //
  void getNotifications() async {
    notifications = await NotificationService.getNotifications();
    notifyListeners();
  }

  // Group notifications by date
  Map<String, List<NotificationModel>> get groupedNotifications {
    Map<String, List<NotificationModel>> grouped = {};
    for (var notification in notifications) {
      String dateKey = DateFormat('yyyy-MM-dd').format(
          DateTime.fromMillisecondsSinceEpoch(notification.timeStamp ?? 0));
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(notification);
    }
    var sortedKeys = grouped.keys.toList()
      ..sort((a, b) => DateTime.parse(b).compareTo(DateTime.parse(a)));
    Map<String, List<NotificationModel>> sortedGrouped = {};
    for (var key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }
    return sortedGrouped;
  }

  void removeNotification(NotificationModel notificationModel) async {
    await NotificationService.removeNotification(notificationModel);
    getNotifications();
  }

  //
  void showNotificationDetails(NotificationModel notificationModel) async {
    //
    notificationModel.read = true;
    NotificationService.updateNotification(notificationModel);

    //
    await Navigator.of(viewContext).pushNamed(
      AppRoutes.notificationDetailsRoute,
      arguments: notificationModel,
    );

    //
    getNotifications();
  }
}
