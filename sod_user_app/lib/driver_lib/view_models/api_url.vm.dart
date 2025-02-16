import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:restart_app/restart_app.dart';
import 'package:http/http.dart' as http;
import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';

class ChangeApiUrlViewModel extends BaseViewModel {
  late BuildContext context;
  bool isTesting = false;
  final TextEditingController urlController = TextEditingController(
    text: Api.baseUrl.substring(8, Api.baseUrl.length - 4),
  );

  ChangeApiUrlViewModel(this.context);

  void initialise() {
    notifyListeners();
  }

  Future<void> saveAndRestart(String newUrl) async {
    Api.baseUrl = newUrl;
    await Restart.restartApp(
      notificationTitle: 'Restarting App',
      notificationBody: 'Please tap here to open the app again.',
    );
  }

  Future<bool> testApi(String url) async {
    try {
      final response = await http.head(Uri.parse(url + Api.appSettings));
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi khi ping đến $url: $e');
      return false;
    }
  }

  void showConfirmDialog(String url) {
    final fullUrl = 'https://$url/api';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm'),
        content: Text(
            'Are you sure to change the API URL to $fullUrl and restart app?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: Text('Confirm'),
            onPressed: () async {
              Navigator.of(context).pop();
              await saveAndRestart(fullUrl);
            },
          ),
        ],
      ),
    );
  }

  void showAlertDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> onConfirmClick() async {
    isTesting = true;
    notifyListeners();
    final isConnected = await testApi('https://' + urlController.text + '/api');
    isTesting = false;
    notifyListeners();

    if (isConnected) {
      showConfirmDialog(urlController.text);
    } else {
      showAlertDialog('Cannot connect to https://${urlController.text}/api');
    }
  }

  void onDefaultUrlClick() {
    showConfirmDialog('sod.di4l.vn');
  }
}
