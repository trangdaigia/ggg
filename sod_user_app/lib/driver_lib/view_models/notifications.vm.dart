import 'package:flutter/cupertino.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:sod_user/driver_lib/constants/app_routes.dart';
import 'package:sod_user/driver_lib/models/notification.dart';
import 'package:sod_user/driver_lib/services/notification.service.dart';
import 'package:sod_user/driver_lib/view_models/base.view_model.dart';

class NotificationsViewModel extends MyBaseViewModel {
  //
  RefreshController refreshController = RefreshController();
  List<NotificationModel> notifications = [];

  NotificationsViewModel(BuildContext context) {
    this.viewContext = context;
  }

  @override
  void initialise() async {
    super.initialise();

    //getting notifications
    getNotifications();
  }

  //
  void getNotifications() async {
    setBusy(true);
    notifications = await NotificationService.getNotifications();
    print("Số lượng: ${notifications.length}");
    refreshController.refreshCompleted();
    notifyListeners();
    setBusy(false);
  }

  //
  void showNotificationDetails(NotificationModel notificationModel) async {
    //
    notificationModel.read = true;
    NotificationService.updateNotification(notificationModel);

    //
    await Navigator.pushNamed(
      viewContext,
      AppRoutes.notificationDetailsRoute,
      arguments: notificationModel,
    );

    //
    getNotifications();
  }
}
