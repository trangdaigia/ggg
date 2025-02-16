import 'package:cool_alert/cool_alert.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:sod_vendor/constants/api.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/models/user.dart';
import 'package:sod_vendor/models/vendor.dart';
import 'package:sod_vendor/requests/vendor.request.dart';
import 'package:sod_vendor/services/auth.service.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:sod_vendor/view_models/base.view_model.dart';
import 'package:sod_vendor/views/pages/shared/custom_webview.page.dart';
import 'package:sod_vendor/widgets/bottomsheets/payout.bottomsheet.dart';
import 'package:sod_vendor/widgets/bottomsheets/vendor_switcher.bottomsheet.dart';

import 'package:jiffy/jiffy.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorDetailsViewModel extends MyBaseViewModel {
  //
  int? touchedIndex;
  double totalEarning = 0.00;
  int totalOrders = 0;
  List<double> weeklySales = [0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00];
  Vendor? vendor;
  User? user;
  VendorRequest vendorRequest = VendorRequest();
  RefreshController refreshController = RefreshController();
  String weekFirstDay = "";
  String weekLastDay = "";

  dynamic toggleVendorAvailability;

  //
  VendorDetailsViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  initialise() async {
    weekFirstDay = await WeekFirstDay();
    weekLastDay = await WeekLastDay();
    user = await AuthServices.getCurrentUser();
    fetchVendorDetails();
  }

  //
  fetchVendorDetails({bool refresh = false}) async {
    //
    !refresh ? setBusy(true) : refreshController.requestRefresh();

    //
    try {
      final response = await vendorRequest.getVendorDetails();

      //
      totalEarning = double.parse(response["total_earnig"].toString());
      totalOrders = response["total_orders"];
      vendor = Vendor.fromJson(response["vendor"]);
      weeklySales = (response["report"] as List)
          .map((e) => double.parse(e["value"].toString()))
          .toList();
      notifyListeners();
      clearErrors();
    } catch (error) {
      print("Error ==> $error");
      setError(error);
    }
    setBusy(false);
    refreshController.refreshCompleted();
  }

  openVendorProfileSwitcher() async {
    await showModalBottomSheet(
      context: viewContext,
      builder: (context) {
        return VendorSwitcherBottomSheetView();
      },
    );
  }

  toggleVendorAvailablity() async {
    setBusyForObject(vendor!.isOpen, true);

    //
    final apiResponse = await vendorRequest.toggleVendorAvailablity(vendor!);
    if (apiResponse.allGood) {
      vendor!.isOpen = !vendor!.isOpen;
      notifyListeners();
    }

    //
    CoolAlert.show(
      context: viewContext,
      type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
      title: "Vendor Details".tr(),
      text: apiResponse.message,
    );
    setBusyForObject(vendor!.isOpen, false);
  }

  openSubscriptionPage() async {
    try {
      final url = await Api.redirectAuth(Api.subscription);
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        await Navigator.push(
          viewContext,
          MaterialPageRoute(
            builder: (context) => CustomWebviewPage(
              selectedUrl: url,
            ),
          ),
        );
      }
      fetchVendorDetails();
    } catch (error) {
      print("Error ==> $error");
    }
  }

  Future<String> WeekFirstDay() async {
    DateTime today = DateTime.now();
    final formattedDate = today.subtract(Duration(days: today.weekday - 1));
    String cLocale = translator.activeLocale.languageCode;
    List<String> supportedLocales = Jiffy.getAllAvailableLocales();
    if (supportedLocales.contains(cLocale)) {
      await Jiffy.locale(translator.activeLocale.languageCode);
    } else {
      await Jiffy.locale("en");
    }
    return Jiffy.unixFromMillisecondsSinceEpoch(
            formattedDate.millisecondsSinceEpoch)
        .yMMMEd;
  }

  Future<String> WeekLastDay() async {
    DateTime today = DateTime.now();
    final formattedDate =
        today.add(Duration(days: DateTime.daysPerWeek - today.weekday));
    String cLocale = translator.activeLocale.languageCode;
    List<String> supportedLocales = Jiffy.getAllAvailableLocales();
    if (supportedLocales.contains(cLocale)) {
      await Jiffy.locale(translator.activeLocale.languageCode);
    } else {
      await Jiffy.locale("en");
    }
    return Jiffy.unixFromMillisecondsSinceEpoch(
            formattedDate.millisecondsSinceEpoch)
        .yMMMEd;
  }

  //
  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay;
            switch (group.x.toInt()) {
              case 0:
                weekDay = 'Monday'.tr();
                break;
              case 1:
                weekDay = 'Tuesday'.tr();
                break;
              case 2:
                weekDay = 'Wednesday'.tr();
                break;
              case 3:
                weekDay = 'Thursday'.tr();
                break;
              case 4:
                weekDay = 'Friday'.tr();
                break;
              case 5:
                weekDay = 'Saturday'.tr();
                break;
              case 6:
                weekDay = 'Sunday'.tr();
                break;
              default:
                weekDay = "";
            }
            return BarTooltipItem(
              "$weekDay\n",
              TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY.toInt() - 1).toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          if (barTouchResponse?.spot != null &&
              event is! PointerUpEvent &&
              event is! PointerExitEvent) {
            touchedIndex = barTouchResponse?.spot?.touchedBarGroupIndex;
          } else {
            touchedIndex = -1;
          }
          notifyListeners();
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 10,
            getTitlesWidget: (double value, TitleMeta meta) {
              final style = TextStyle(
                color: Utils.textColorByTheme(),
                fontWeight: FontWeight.w400,
                fontSize: 12,
              );
              Widget text;
              switch (value.toInt()) {
                case 0:
                  text = 'Mon'.tr().text.textStyle(style).make();
                  break;
                case 1:
                  text = 'Tue'.tr().text.textStyle(style).make();
                  break;
                case 2:
                  text = 'Wed'.tr().text.textStyle(style).make();
                  break;
                case 3:
                  text = 'Thur'.tr().text.textStyle(style).make();
                  break;
                case 4:
                  text = 'Fri'.tr().text.textStyle(style).make();
                  break;
                case 5:
                  text = 'Sat'.tr().text.textStyle(style).make();
                  break;
                case 6:
                  text = 'Sun'.tr().text.textStyle(style).make();
                  break;
                default:
                  text = ''.text.make();
                  break;
              }

              return SideTitleWidget(
                axisSide: meta.axisSide,
                space: 0,
                child: text,
              );
            },
          ),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
        leftTitles: AxisTitles(
          axisNameWidget:
              "Amount".tr().text.color(Utils.textColorByTheme()).make(),
          sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return "${meta.formattedValue}"
                    .text
                    .sm
                    .color(Utils.textColorByTheme())
                    .make();
              }),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color barColor = Colors.white,
    double width = 20,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: barColor,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            color: AppColor.primaryColorDark.withOpacity(0.90).withAlpha(150),
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() => List.generate(7, (i) {
        return makeGroupData(i, weeklySales[i], isTouched: i == touchedIndex);
      });

  //
  requestPayout() async {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return PayoutBottomSheet(
          totalEarningAmount: totalEarning,
        );
      },
    );
  }
}
