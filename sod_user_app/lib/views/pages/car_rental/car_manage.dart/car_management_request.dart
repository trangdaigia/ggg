import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/car_rental.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/views/pages/car_rental/widgets/car_management_request_card.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:velocity_x/velocity_x.dart';

class CarManagementRequestPage extends StatefulWidget {
  const CarManagementRequestPage({super.key, required this.viewModel});
  final CarManagementViewModel viewModel;
  @override
  State<CarManagementRequestPage> createState() =>
      _CarManagementRequestPageState();
}

class _CarManagementRequestPageState extends State<CarManagementRequestPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColor.onboarding3Color,
        appBar: AppBar(
          backgroundColor: context.backgroundColor,
          iconTheme: IconThemeData(color: context.textTheme.bodyLarge!.color),
          title: Text("Request a car rental".tr(),
              style: TextStyle(color: context.textTheme.bodyLarge!.color)),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomListView(
              separator: 5,
              canRefresh: true,
              refreshController: widget.viewModel.refreshRequestController,
              dataSet: widget.viewModel.carRentalRequests,
              onRefresh: () => widget.viewModel.getMyCar(),
              isLoading: widget.viewModel.isBusy,
              hasError: widget.viewModel.hasError,
              errorWidget: LoadingError(
                onrefresh: widget.viewModel.getMyCar,
              ),
              emptyWidget: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    heightFactor: 40,
                    child: Text(
                      'no_data'.tr(),
                    ),
                  ),
                ],
              ),
              itemBuilder: (context, index) {
                return tripCard(
                  widget.viewModel.carRentalRequests[index],
                  widget.viewModel,
                );
              }),
        ),
      ),
    );
  }

  Widget tripCard(CarRental car, CarManagementViewModel viewModel) {
    return Column(
        children: car.requests!
            .map(
              (request) => CarManagementRequestCard(
                  car: car, viewModel: viewModel, request: request),
            )
            .toList());
  }
}
