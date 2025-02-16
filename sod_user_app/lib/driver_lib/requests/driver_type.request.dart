import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:sod_user/driver_lib/models/api_response.dart';
import 'package:sod_user/services/http.service.dart';

class DriverTypeRequest extends HttpService {
  //
  Future<ApiResponse> switchType(Map payload) async {
    final apiResult = await post(Api.driverTypeSwitch, payload);
    return ApiResponse.fromResponse(apiResult);
  }
}
