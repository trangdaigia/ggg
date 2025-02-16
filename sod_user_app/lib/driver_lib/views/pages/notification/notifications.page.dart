import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/constants/app_images.dart';
import 'package:sod_user/driver_lib/utils/ui_spacer.dart';
import 'package:sod_user/driver_lib/view_models/notifications.vm.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/custom_list_view.dart';
import 'package:sod_user/driver_lib/widgets/states/empty.state.dart';
import 'package:sod_user/driver_lib/widgets/states/error.state.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationsViewModel>.reactive(
      viewModelBuilder: () => NotificationsViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        print(
            "+++++++++++ SỐ LƯỢNG THÔNG BÁO ==> : ${model.notifications.length}");
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "Notifications".tr(),
          body: SafeArea(
            child: CustomListView(
              canRefresh: true,
              refreshController: model.refreshController,
              onRefresh: model.getNotifications,
              isLoading: model.isBusy,
              hasError: model.hasError,
              dataSet: model.notifications,
              errorWidget: LoadingError(
                onrefresh: model.getNotifications,
              ),
              emptyWidget: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 4,
                  horizontal: 20,
                ),
                child: Center(
                  child: EmptyState(
                    imageUrl: AppImages.noNotification,
                    title: "No Notifications".tr(),
                    description:
                        "You dont' have notifications yet. When you get notifications, they will appear here"
                            .tr(),
                  ),
                ),
              ),
              itemBuilder: (context, index) {
                //
                final notification = model.notifications[index];
                return VStack(
                  [
                    //title
                    "${notification.title}".text.bold.make(),
                    //time
                    notification.formattedTimeStamp.text.medium
                        .color(Colors.grey)
                        .make()
                        .pOnly(bottom: 5),
                    //body
                    "${notification.body}"
                        .text
                        .maxLines(1)
                        .overflow(TextOverflow.ellipsis)
                        .make(),
                  ],
                )
                    .px20()
                    .py12()
                    .box
                    .color(notification.read
                        ? context.cardColor
                        : context.backgroundColor)
                    .make()
                    .onInkTap(() {
                  model.showNotificationDetails(notification);
                });
              },
              separatorBuilder: (context, index) => UiSpacer.divider(),
            ),
          ),
        );
      },
    );
  }

/*  String changeNotificationBody(var name, var notification) {
    const String pattern =
        r"Người dùng (\d+)"; // Matches "Người dùng" followed by one or more digits
    RegExp regex = RegExp(pattern);
    // Check if the input matches the pattern
    if (regex.hasMatch(notification)) {
      // Extract the matched number (xx)
      Match match = regex.firstMatch(notification)!;
      String number = match.group(1)!; // Assuming group(1) captures the number
      // Replace the matched phrase with "Name"
      String replacedNotification =
          notification.replaceAll(RegExp(pattern), name);
      // Print the replaced string
      return replacedNotification; // Output: Name Đơn hàng đã được thanh toán thành công!
    }
    return "";
  }*/
}
