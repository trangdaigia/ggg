import 'package:sod_vendor/constants/api.dart';
import 'package:sod_vendor/models/api_response.dart';
import 'package:sod_vendor/models/order.dart';
import 'package:sod_vendor/services/auth.service.dart';
import 'package:sod_vendor/services/http.service.dart';

class OrderRequest extends HttpService {
  //
  Future<List<Order>> getOrders({
    int page = 1,
    String? status,
    String? type,
    bool forceRefresh = false, 
  }) async {
    final vendorId = (await AuthServices.getCurrentUser()).vendor_id;

    final apiResult = await get(
      Api.orders,
      queryParameters: {
        "vendor_id": vendorId,
        "page": page,
        "status": status,
      },
      forceRefresh: forceRefresh,
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return apiResponse.data.map((jsonObject) {
        return Order.fromJson(jsonObject);
      }).toList();
    } else {
      throw apiResponse.message;
    }
  }

  //
  Future<Order> getOrderDetails({required int id, bool forceRefresh = false}) async {
    final apiResult = await get(Api.orders + "/$id", forceRefresh: forceRefresh);
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Order.fromJson(apiResponse.body);
    } else {
      throw apiResponse.message;
    }
  }

  //
  Future<Order> updateOrder({
    required int id,
    String status = "delivered",
  }) async {
    final apiResult = await patch(
      Api.orders + "/$id",
      {
        "status": status,
      },
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    print("response ==> ${apiResponse.body}");
    if (apiResponse.allGood) {
      return Order.fromJson(apiResponse.body["order"]);
    } else {
      throw apiResponse.message;
    }
  }

  //
  Future<Order> assignOrderToDriver({
    required int id,
    required int driverId,
    required String status,
  }) async {
    final apiResult = await patch(
      Api.orders + "/$id",
      {
        "status": status,
        "driver_id": driverId,
      },
    );
    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return Order.fromJson(apiResponse.body["order"]);
    } else {
      throw apiResponse.message;
    }
  }
}
