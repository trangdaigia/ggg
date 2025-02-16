import 'package:dio/dio.dart';
import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:sod_user/driver_lib/models/api_response.dart';
import 'package:sod_user/services/http.service.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class SettingsRequest extends HttpService {
  //
  Future<ApiResponse> appSettings() async {
    final apiResult = await get(Api.appSettings,
        forceRefresh: true, staleWhileRevalidate: false);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> appOnboardings() async {
    try {
      final apiResult =
          await get(Api.appOnboardings, staleWhileRevalidate: false);
      return ApiResponse.fromResponse(apiResult);
    } on DioException catch (error) {
      if (error.type == DioExceptionType.unknown) {
        throw "Connection failed. Please check that your have internet connection on this device."
                .tr() +
            "\n" +
            "Try again later".tr();
      }
      throw error;
    } catch (error) {
      throw error;
    }
  }
}
