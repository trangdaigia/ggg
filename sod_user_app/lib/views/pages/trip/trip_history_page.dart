import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gif/gif.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/extensions/string.dart';
import 'package:sod_user/models/trip.dart';
import 'package:sod_user/view_models/trip.view_model.dart';
import 'package:sod_user/views/pages/trip/trip_page.dart';
import 'package:sod_user/views/pages/trip/widget/trip_card.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class TripHistoryPage extends StatefulWidget {
  const TripHistoryPage({super.key});

  @override
  State<TripHistoryPage> createState() => _TripHistoryPageState();
}

class _TripHistoryPageState extends State<TripHistoryPage>
    with TickerProviderStateMixin {
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
    return ViewModelBuilder<TripViewModel>.reactive(
        disposeViewModel: false,
        viewModelBuilder: () => model,
        onViewModelReady: (viewModel) =>
            viewModel.getTripCompleted(getTrip: true),
        builder: (context, viewModel, child) {
          return BasePage(
            title: 'Trip history'.tr(),
            showAppBar: true,
            showLeadingAction: true,
            body: CustomListView(
                separator: 10,
                canRefresh: true,
                refreshController: viewModel.completed_RC,
                onRefresh: () => viewModel.getTripCompleted(getTrip: true),
                isLoading: viewModel.isBusy,
                dataSet: viewModel.tripsCompleted,
                hasError: viewModel.hasError,
                errorWidget: LoadingError(
                  onrefresh: () => viewModel.getTripCompleted(getTrip: true),
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
                    ],
                  ),
                ),
                itemBuilder: (context, index) {
                  return TripCard(
                    trip: viewModel.tripsCompleted[index],
                    viewModel: viewModel,
                  );
                }),
          );
        });
  }
}
