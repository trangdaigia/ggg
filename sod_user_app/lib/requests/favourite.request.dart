import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/services/http.service.dart';

class FavouriteRequest extends HttpService {
  //
  Future<List<Product>> favourites() async {
    final apiResult = await get(Api.favourites);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Product> products = [];
      final data =
          apiResponse.hasData() ? apiResponse.data : apiResponse.body as List;
      data.forEach(
        (jsonObject) {
          try {
            products.add(Product.fromJson(jsonObject["product"]));
          } catch (error) {
            print("error: $error");
          }
        },
      );
      return products;
    }

    throw apiResponse.message!;
  }

  //
  Future<ApiResponse> makeFavourite(int id) async {
    final apiResult = await post(
      Api.favourites,
      {
        "product_id": id,
      },
    );

    return ApiResponse.fromResponse(apiResult);
  }

  //
  Future<ApiResponse> removeFavourite(int productId) async {
    final apiResult = await delete(Api.favourites + "/$productId");
    return ApiResponse.fromResponse(apiResult);
  }
}
