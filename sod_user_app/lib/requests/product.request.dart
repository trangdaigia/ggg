import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/category.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/models/product_review.dart';
import 'package:sod_user/services/http.service.dart';

class ProductRequest extends HttpService {
  //
  Future<List<Product>> getProdcuts({
    Map<String, dynamic>? queryParams,
    int page = 1,
  }) async {
    Map<String, dynamic> params = {
      ...(queryParams != null ? queryParams : {}),
      "page": "$page",
    };

    //if params contains latitute and longitude, and if they are null, remove them
    if (params.containsKey("latitude") &&
        params.containsKey("longitude") &&
        (params["latitude"] == null || params["longitude"] == null)) {
      params.remove("latitude");
      params.remove("longitude");
    }

    final apiResult = await get(
      Api.products,
      queryParameters: params,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<Product> products = [];
      apiResponse.data.forEach((element) {
        try {
          products.add(Product.fromJson(element));
        } catch (error) {
          print("===============================");
          print("Error Fetching Product ==> $error");
          print("Product ==> ${element['id']}");
          print("===============================");
        }
      });
      return products;
      // return apiResponse.data
      //     .map((jsonObject) => Product.fromJson(jsonObject))
      //     .toList();
    }

    throw apiResponse.message!;
  }

  //
  Future<List<Product>> bestProductsRequest(
      {Map<String, dynamic>? queryParams, int page = 1}) async {
    final apiResult = await get(
      Api.bestProducts,
      queryParameters: {
        ...(queryParams != null ? queryParams : {}),
        "page": "$page",
      },
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Product.fromJson(jsonObject))
          .toList();
    }

    throw apiResponse.message!;
  }

  Future<List<Product>> forYouProductsRequest(
      {Map<String, dynamic>? queryParams, int page = 1}) async {
    final apiResult = await get(
      Api.forYouProducts,
      queryParameters: {
        ...(queryParams != null ? queryParams : {}),
        "page": "$page",
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Product.fromJson(jsonObject))
          .toList();
    }

    throw apiResponse.message!;
  }

  Future<List<Product>> searchProduct({
    int page = 1,
    String? keyword,
    String? type,
    Category? category,
  }) async {
    final apiResult = await get(
      Api.forYouProducts,
      queryParameters: {"page": "$page"},
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Product.fromJson(jsonObject))
          .toList();
    }

    throw apiResponse.message!;
  }

  //
  Future<Product> productDetails(int id) async {
    //
    final apiResult = await get("${Api.products}/$id");
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Product.fromJson(apiResponse.body);
    }

    throw apiResponse.message!;
  }

  ///
  Future<List<ProductReview>> productReviews({
    Map<String, dynamic>? queryParams,
    int page = 1,
  }) async {
    Map<String, dynamic> params = {
      ...(queryParams != null ? queryParams : {}),
      "page": "$page",
    };

    final apiResult = await get(
      Api.productReviews,
      queryParameters: params,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => ProductReview.fromJson(jsonObject))
          .toList();
    }

    throw apiResponse.message!;
  }

  //
  Future<ApiResponse> productReviewSummary(
      {Map<String, dynamic>? queryParams}) async {
    Map<String, dynamic> params = {
      ...(queryParams != null ? queryParams : {}),
    };

    final apiResult = await get(
      Api.productReviewSummary,
      queryParameters: params,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse;
    }

    throw apiResponse.message!;
  }

  Future<List<Product>> productsBoughtTogether({
    Map<String, int>? queryParams,
  }) async {
    final apiResult = await get(
      Api.productBoughtFrequent,
      queryParameters: queryParams,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return ((apiResponse.body as Map)["products"] as List)
          .map((jsonObject) => Product.fromJson(jsonObject))
          .toList();
    }

    throw apiResponse.message!;
  }

  Future<ApiResponse> submitReview({
    Map<String, dynamic>? params,
  }) async {
    final apiResult = await post(
      Api.productReviews,
      params,
    );

    return ApiResponse.fromResponse(apiResult);
  }
}
