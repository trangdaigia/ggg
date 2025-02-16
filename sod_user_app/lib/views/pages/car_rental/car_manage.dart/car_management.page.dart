import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/global/global_variable.dart';
import 'package:sod_user/services/navigation.service.dart';
import 'package:sod_user/view_models/car_management.view_model.dart';
import 'package:sod_user/views/pages/car_rental/car_manage.dart/car_management_request.dart';
import 'package:sod_user/views/pages/car_rental/widgets/car_management_card.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/buttons/global_button.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/states/error.state.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class CarManagementPage extends StatefulWidget {
  const CarManagementPage({super.key});

  @override
  State<CarManagementPage> createState() => _CarManagementPageState();
}

class _CarManagementPageState extends State<CarManagementPage>
    with AutomaticKeepAliveClientMixin {
  late CarManagementViewModel model;
  PageController _pageController = PageController();
  int currentIndex = GlobalVariable.activeSecondIndex == true ? 1 : 0;
  @override
  void initState() {
    super.initState();
    model = CarManagementViewModel();
    _pageController = PageController(
        initialPage: GlobalVariable.activeSecondIndex == true ? 1 : 0);
    GlobalVariable.resetActiveSecondIndex();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ViewModelBuilder<CarManagementViewModel>.reactive(
      viewModelBuilder: () => model,
      onViewModelReady: (viewModel) => viewModel.initialise(),
      builder: (context, viewModel, child) {
        return BasePage(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            children: [
              Scaffold(
                backgroundColor: AppColor.onboarding3Color,
                appBar: AppBar(
                  backgroundColor: context.backgroundColor,
                  iconTheme:
                      IconThemeData(color: context.textTheme.bodyLarge!.color),
                  title: Text("Vehicle Management".tr(),
                      style:
                          TextStyle(color: context.textTheme.bodyLarge!.color)),
                  centerTitle: true,
                ),
                body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Container(
                            child: CustomListView(
                              separator: 5,
                              canRefresh: true,
                              refreshController: viewModel.refreshController,
                              dataSet: viewModel.carRental,
                              onRefresh: () => viewModel.getMyCar(),
                              isLoading: viewModel.isBusy,
                              hasError: viewModel.hasError,
                              errorWidget: LoadingError(
                                onrefresh: viewModel.getMyCar,
                              ),
                              emptyWidget: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                return CarManagementCard(
                                  model: model,
                                  data: model.carRental[index],
                                  index: index,
                                );
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        CustomButton(
                          title: 'Add Car'.tr(),
                          onPressed: () {
                            model.brandController.text = '';
                            model.brandId = '';
                            model.carModelController.text = '';
                            model.carModelId = '';
                            model.colorController.text = '';
                            model.addressController.text = '';
                            model.regNoController.text = '';
                            model.price26Controller.text = '';
                            model.price7cnController.text = '';
                            model.price26WithDriverController.text = '';
                            model.price7cnWithDriverController.text = '';
                            model.price1kmController.text = '';
                            model.drivingFeeController.text = '';
                            model.requirements = [];
                            model.utilities = [];
                            model.yearMadeController.text = '';
                            model.newPhotos = [];
                            model.rangeOfVehicleController.text = '';
                            model.rangeOfVehicleTranslateController.text = '';
                            context.nextPage(NavigationService()
                                .addCarRentalPage(
                                    model: model, type: "address"));
                          },
                        ).pOnly(bottom: 10),
                      ],
                    )),
              ),
              CarManagementRequestPage(viewModel: viewModel),
            ],
          ),
          bottomNavigationBar: AnimatedBottomNavigationBar.builder(
            onTap: (index) {
              currentIndex = index;
              _pageController.animateToPage(
                currentIndex,
                duration: Duration(microseconds: 5),
                curve: Curves.bounceInOut,
              );
            },
            itemCount: 2,
            backgroundColor: Theme.of(context).colorScheme.background,
            blurEffect: true,
            shadow: BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              blurRadius: 10,
            ),
            activeIndex: currentIndex,
            gapLocation: GapLocation.center,
            notchSmoothness: NotchSmoothness.softEdge,
            leftCornerRadius: 14,
            rightCornerRadius: 14,
            tabBuilder: (int index, bool isActive) {
              final color = isActive
                  ? AppColor.primaryColor
                  : Theme.of(context).textTheme.bodyLarge?.color;
              List<String> titles = [
                "Vehicle management".tr(),
                "Request a car rental".tr(),
              ];
              List<IconData> icons = [
                FlutterIcons.car_ant,
                FlutterIcons.comment_alert_mco
              ];
              Widget tab = Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[index],
                    size: 20,
                    color: color,
                  ),
                  Padding(
                      padding: const EdgeInsets.all(3),
                      child: titles[index]
                          .text
                          .fontWeight(
                            isActive ? FontWeight.bold : FontWeight.normal,
                          )
                          .color(color)
                          .scale(1)
                          .make()),
                ],
              );
              return tab;
            },
          ),
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
