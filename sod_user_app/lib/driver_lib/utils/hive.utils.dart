import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:sod_user/services/http.service.dart';

class HiveUtils {
  static Future<List<String>> listAllBoxesOnDisk() async {
    final appDir = await getApplicationDocumentsDirectory();
    final hiveDir = Directory('${appDir.path}/hive');

    if (await hiveDir.exists()) {
      final boxFiles =
          hiveDir.listSync().where((file) => file.path.endsWith('.hive'));
      final boxNames = boxFiles
          .map((file) => file.uri.pathSegments.last.split(".hive").first)
          .toList();
      return boxNames;
    } else {
      return [];
    }
  }

  static Future<void> updateAllBoxesWithApiResponse() async {
    final boxeNames = await listAllBoxesOnDisk();
    for (var boxName in boxeNames) {
      final path = "/" + boxName.replaceAll(".", "/");
      final httpService = HttpService();
      httpService.host = Api.baseUrl;
      final box = await Hive.openBox<Map<String, dynamic>>(boxName);
      for (var key in box.keys) {
        httpService.get(path + "?" + key, staleWhileRevalidate: true);
      }
      box.close();
    }
  }
}
