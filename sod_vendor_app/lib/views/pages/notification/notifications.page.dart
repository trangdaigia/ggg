import 'package:flutter/material.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/view_models/notifications.vm.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:sod_vendor/widgets/custom_list_view.dart';
import 'package:sod_vendor/widgets/states/empty.state.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationsViewModel>.reactive(
      viewModelBuilder: () => NotificationsViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          title: "Notifications".tr(),
          body: SafeArea(
            child: CustomListView(
              dataSet: model.notifications,
              emptyWidget: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height / 4,
                  horizontal: 20,
                ),
                child: EmptyState(
                  title: "No Notifications".tr(),
                  description:
                      "You dont' have notifications yet. When you get notifications, they will appear here"
                          .tr(),
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
}
