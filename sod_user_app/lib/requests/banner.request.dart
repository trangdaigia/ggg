import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/banner.dart';
import 'package:sod_user/services/http.service.dart';

class BannerRequest extends HttpService {
  //
  Future<List<Banner>> banners({
    int? vendorTypeId,
    Map? params,
  }) async {
    final apiResult = await get(
      Api.banners,
      queryParameters: {
        "vendor_type_id": vendorTypeId,
        ...(params != null ? params : {}),
      },
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    List<Banner> banners = [];
    if (apiResponse.allGood) {
      banners = apiResponse.data
          .map((jsonObject) => Banner.fromJSON(jsonObject))
          .toList();
      return banners;
    } else {
      throw apiResponse.message!;
    }
  }
}
