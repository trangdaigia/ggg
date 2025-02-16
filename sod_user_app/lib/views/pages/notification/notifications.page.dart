import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sod_user/view_models/notifications.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/widgets/states/empty.state.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/models/notification.dart';
import 'package:sod_user/constants/app_colors.dart';

class NotificationsPage extends StatelessWidget {
  NotificationsPage({Key? key, this.showLeading}) : super(key: key);
  final bool? showLeading;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<NotificationsViewModel>.reactive(
      viewModelBuilder: () => NotificationsViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: showLeading ?? true,
          title: "Notifications".tr(),
          body: model.notifications.isEmpty
              ? EmptyState(
                  title: "No Notifications".tr(),
                  description:
                      "You dont' have notifications yet. When you get notifications, they will appear here"
                          .tr(),
                ).p(16)
              : CustomScrollView(
                  slivers: [
                    ...model.groupedNotifications.entries.map((entry) {
                      String dateKey = entry.key;
                      List<NotificationModel> notifications = entry.value;

                      return SliverStickyHeader(
                        header: Text(
                          DateFormat('dd/MM/yyyy')
                              .format(DateTime.parse(dateKey)),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                            .pOnly(left: 16, right: 16, top: 16, bottom: 8)
                            .backgroundColor(AppColor.onboarding1Color),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final notification = notifications[index];
                              return Dismissible(
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  color: Colors.red,
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ).px(16),
                                ),
                                onDismissed: (direction) {
                                  if (direction == DismissDirection.endToStart)
                                    model.removeNotification(notification);
                                },
                                direction: DismissDirection.endToStart,
                                key: ValueKey(notification),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: (notification.read ?? false)
                                        ? Colors.white
                                        : AppColor.onboarding2Color,
                                    border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[300]!),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      // Logo
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            AssetImage(AppImages.appLogo),
                                      ).pOnly(right: 16),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Title
                                          "${notification.title}"
                                              .text
                                              .size(16)
                                              .bold
                                              .make(),
                                          // Body
                                          notification.body
                                              .toString()
                                              .tr()
                                              .text
                                              .maxLines(1)
                                              .overflow(TextOverflow.ellipsis)
                                              .make(),
                                        ],
                                      ).expand(),
                                    ],
                                  ).p(16),
                                ),
                              ).onTap(() {
                                model.showNotificationDetails(notification);
                              });
                            },
                            childCount: notifications.length,
                          ),
                        ),
                      );
                    }),
                    SliverToBoxAdapter(
                      child: SizedBox(height: 32),
                    )
                  ],
                ),
        );
      },
    );
  }
}
