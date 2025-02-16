import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/trip.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/view_models/trip.view_model.dart';
import 'package:sod_user/views/pages/trip/trip_history_page.dart';
import 'package:sod_user/views/pages/trip/widget/trip_card.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:stacked/stacked.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/extensions/string.dart';

class TripPage extends StatefulWidget {
  const TripPage({super.key});

  @override
  State<TripPage> createState() => _TripPageState();
}

class _TripPageState extends State<TripPage> with TickerProviderStateMixin {
  late GifController controller;
  late TripViewModel model;
  @override
  void initState() {
    controller = GifController(vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.repeat(
        min: 0,
        max: 53,
        period: const Duration(milliseconds: 700),
      );
    });
    model = TripViewModel();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('Build lại trip page');
    return ViewModelBuilder<TripViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => model,
        onViewModelReady: (viewModel) =>
            viewModel.getTripPendingAndInProgress(getTrip: true),
        builder: (context, viewModel, child) {
          return BasePage(
            title: 'My trip'.tr(),
            showAppBar: true,
            showLeadingAction: true,
            actions: [
              InkWell(
                onTap: () {
                  context.nextPage(TripHistoryPage());
                },
                child: Container(
                    margin: EdgeInsets.only(right: 10),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColor.primaryColor,
                    ),
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                    )),
              ),
            ],
            body: CustomListView(
                separator: 10,
                canRefresh: true,
                refreshController: viewModel.refreshController,
                onRefresh: () =>
                    viewModel.getTripPendingAndInProgress(getTrip: true),
                isLoading: viewModel.isBusy,
                dataSet: viewModel.tripsPending,
                hasError: viewModel.hasError,
                errorWidget: LoadingError(
                  onrefresh: () =>
                      viewModel.getTripPendingAndInProgress(getTrip: true),
                ),
                emptyWidget: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                            child: Gif(
                          controller: controller,
                          image: AssetImage("assets/images/icons/iconapp.gif"),
                        )),
                      ),
                      'Bạn không có chuyến hiện tại'
                          .text
                          .xl2
                          .color(AppColor.cancelledColor)
                          .make(),
                      TextButton(
                        onPressed: () {
                          context.nextPage(TripHistoryPage());
                        },
                        child: Text('Xem lịch sử chuyến',
                            style: TextStyle(
                              color: AppColor.primaryColor,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context, index) {
                  return TripCard(
                    trip: viewModel.tripsPending[index],
                    viewModel: viewModel,
                  );
                }),
          );
        });
  }
}
