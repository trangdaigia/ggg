import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/view_models/payment_account.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../constants/app_text_styles.dart';

class PaymentAccountPage extends StatelessWidget {
  const PaymentAccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //
    return ViewModelBuilder<PaymentAccountViewModel>.reactive(
      viewModelBuilder: () => PaymentAccountViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      builder: (context, vm, child) {
        return BasePage(
          title: "Payment Accounts".tr(),
          showLeadingAction: true,
          showAppBar: true,
          fab: FloatingActionButton.extended(
            onPressed: vm.openNewPaymentAccount,
            label: "New"
                .tr()
                .text
                .white
                .textStyle(AppTextStyle.h4TitleTextStyle())
                .make(),
            icon: Icon(
              FlutterIcons.plus_ant,
              color: Colors.white,
            ),
            backgroundColor: AppColor.primaryColor,
          ),
          body: VStack(
            [
              CustomListView(
                refreshController: vm.refreshController,
                canPullUp: true,
                canRefresh: true,
                isLoading: vm.busy(vm.paymentAccounts),
                onRefresh: vm.getPaymentAccounts,
                onLoading: () => vm.getPaymentAccounts(initialLoading: false),
                dataSet: vm.paymentAccounts,
                itemBuilder: (context, index) {
                  //
                  final paymentAccount = vm.paymentAccounts[index];
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(12), // Bo góc cho nút
                      ),
                      backgroundColor: Colors.white, // Màu nền của nút
                      shadowColor:
                          Colors.grey.withOpacity(0.5), // Màu của shadow
                      elevation: 5, // Độ nổi
                    ),
                    onPressed: () {
                      //navigate to edit payment account
                      vm.openEditPaymentAccount(paymentAccount);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 10),
                      padding:
                          EdgeInsets.all(15), // Padding cho nội dung bên trong
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Tên tài khoản
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Tên tài khoản".tr(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    paymentAccount
                                        .name, // Dữ liệu từ paymentAccount
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              // Số tài khoản
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Số tài khoản".tr(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    paymentAccount
                                        .number, // Dữ liệu từ paymentAccount
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // Tên ngân hàng
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tên ngân hàng".tr(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],

                                ),
                              ),
                              Text(
                                paymentAccount
                                    .bankName, // Dữ liệu từ paymentAccount
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                emptyWidget: const Text("No Payment Accounts").centered(),
              ).expand(),
            ],
          ).p20(),
        );
      },
    );
  }
}
