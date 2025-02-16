import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/coupon.dart';
import 'package:sod_user/services/http.service.dart';

class CartRequest extends HttpService {
  //
  Future<Coupon> fetchCoupon(String code, {int? vendorTypeId}) async {
    Map<String, dynamic> params = {};
    if (vendorTypeId != null) {
      params = {
        "vendor_type_id": vendorTypeId,
      };
    }

    final apiResult = await get(
      "${Api.coupons}/$code",
      queryParameters: params,
      staleWhileRevalidate: true,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Coupon.fromJson(apiResponse.body);
    } else {
      throw apiResponse.message!;
    }
  }
}
