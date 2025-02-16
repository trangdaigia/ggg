import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:sod_user/driver_lib/models/api_response.dart';
import 'package:sod_user/driver_lib/models/currency.dart';
import 'package:sod_user/driver_lib/models/earning.dart';
import 'package:sod_user/services/http.service.dart';

class EarningRequest extends HttpService {
  //
  Future<List<dynamic>> getEarning() async {
    final apiResult = await get(Api.earning);

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return [
        Currency.fromJSON(apiResponse.body["currency"]),
        Earning.fromJson(apiResponse.body["earning"]),
      ];
    } else {
      throw "${apiResponse.message}";
    }
  }
}
