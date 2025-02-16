import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';

class BookingResult extends StatelessWidget {
  const BookingResult({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FlutterIcons.warning_ant,
                    color: AppColor.primaryColor,
                  ),
                  Text(
                    ' Đang chờ phản hồi'.tr(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColor.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Kết quả đặt xe sẽ được chủ xe phản hồi đồng ý hoặc hủy chuyến'
                    .tr(),
                style: TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              child: Text(
                'Xem lại đơn hàng'.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
