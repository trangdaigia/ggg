import 'package:sod_vendor/constants/api.dart';
import 'package:sod_vendor/models/api_response.dart';
import 'package:sod_vendor/models/vendor_type.dart';
import 'package:sod_vendor/services/http.service.dart';

class VendorTypeRequest extends HttpService {
  //
  Future<List<VendorType>> index() async {
    final apiResult = await get(Api.vendorTypes);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.body as List) .map((e) => VendorType.fromJson(e)).toList();
    }

    throw apiResponse.message;
  }
}
