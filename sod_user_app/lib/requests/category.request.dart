import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/category.dart';
import 'package:sod_user/services/http.service.dart';

class CategoryRequest extends HttpService {
  //
  Future<List<Category>> categories({
    int? vendorTypeId,
    int page = 0,
    int full = 0,
  }) async {
    final apiResult = await get(
      //
      Api.categories,
      queryParameters: {
        "vendor_type_id": vendorTypeId,
        "page": page,
        "full": full,
      },
      staleWhileRevalidate: true,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Category.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  Future<List<Category>> subcategories({int? categoryId, int? page}) async {
    final apiResult = await get(
      //
      Api.categories,
      queryParameters: {
        "category_id": categoryId,
        "page": page,
        "type": "sub",
      },
      staleWhileRevalidate: true,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Category.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }
}
