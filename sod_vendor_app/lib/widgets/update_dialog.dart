import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:restart_app/restart_app.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class UpdateDialog extends StatefulWidget {
  const UpdateDialog({
    super.key,
    required this.logoPath,
  });

  final String logoPath;

  @override
  _UpdateDialogState createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool isDownloading = true;

  @override
  void initState() {
    super.initState();
    _updateApp();
  }

  _updateApp() async {
    final shorebirdCodePush = ShorebirdCodePush();
    print('[shorebirdCodePush] Has new patch!');

    shorebirdCodePush.downloadUpdateIfAvailable().then(
      (value) {
        setState(() => isDownloading = false);
        print('[shorebirdCodePush] Downloaded the new patch');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 3 / 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.min,
        children: [
          "Có bản cập nhật mới".tr().text.xl2.bold.make(),
          Center(
            child: Image.asset(
              widget.logoPath,
              width: 200,
              height: 200,
            ),
          ),
          if (isDownloading)
            Text(
              "Đang tải bản cập nhật mới, vui lòng chờ...".tr(),
              textAlign: TextAlign.center,
            )
          else
            Text(
              "Bản cập nhật mới đã được cài đặt, vui lòng thoát ứng dụng và mở lại để áp dụng bản cập nhật mới."
                  .tr(),
              textAlign: TextAlign.center,
            ),
          SizedBox(
              height: 50,
              child: isDownloading
                  ? LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        context.theme.primaryColor,
                      ),
                    ).wOneThird(context).centered()
                  : CustomButton(
                      onPressed: () {
                        print('[shorebirdCodePush] Restarting App');

                        exit(0);

                        // exit app safely
                        // SystemNavigator.pop();

                        // Restart app but not working
                        // Restart.restartApp(
                        //   notificationTitle: 'Restarting App',
                        //   notificationBody:
                        //       'Please tap here to open the app again.',
                        // );
                      },
                      title: "Thoát ứng dụng".tr(),
                    )),
        ],
      ).p(16),
    );
  }
}
