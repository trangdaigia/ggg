import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/trip.dart';
import 'package:sod_user/services/http.service.dart';

class TripRequest extends HttpService {
  List<Trip> tripsCompleted = [];
  List<Trip> tripsPendingAndInProgress = [];
  String? tempApi = null;
  Map<String, dynamic>? headers = null;
  Future<List<Trip>> getTripCompleted({
    String? brand_id = "",
    String? carMake = "",
    String? color = "",
  }) async {
    final apiResult = await get(
      hostUrl: tempApi,
      headers: headers,
      Api.getRentalRequest,
      queryParameters: {
        "is_mine": 1,
        "status": "canceled,completed",
      },
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      tripsCompleted = apiResponse.data.map((e) => Trip.fromJson(e)).toList();
    }
    return tripsCompleted;
  }

  Future<List<Trip>> getTripPendingAndInProgress({
    String? brand_id = "",
    String? carMake = "",
    String? color = "",
  }) async {
    final apiResult = await get(
      hostUrl: tempApi,
      headers: headers,
      Api.getRentalRequest,
      forceRefresh: true,
      queryParameters: {
        "is_mine": 1,
        "status": "In progress,pending",
      },
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      print('Lấy chuyến đi thành công');
      //print('Giá của chuyến đầu tiên: ${apiResponse.data[2]["total_price"]}');
      print('Độ dài của data: ${apiResponse.data.length}');
      tripsPendingAndInProgress = apiResponse.data.map((e) {
        if (e == null) {
          print('Có null');
        }
        if (e["vehicle"] == null) {
          print('Có xe null');
        }
        return Trip.fromJson(e);
      }).toList();
    }
    return tripsPendingAndInProgress;
  }

  Future<bool> cancelTrip(int id) async {
    final Map<String, dynamic> requestBody = {};
    requestBody['status'] = 'canceled';
    final apiResult = await patch(
      hostUrl: tempApi,
      headers: headers,
      Api.getRentalRequest + "/$id",
      requestBody,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return true;
    } else {
      throw false;
    }
  }

  Future<bool> depositedTrip(int id) async {
    final Map<String, dynamic> requestBody = {};
    requestBody['deposit'] = 1;
    final apiResult = await patch(
      hostUrl: tempApi,
      headers: headers,
      Api.getRentalRequest + "/$id",
      requestBody,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return true;
    } else {
      throw false;
    }
  }

  Future<bool> acceptTrip(int id) async {
    final Map<String, dynamic> requestBody = {};
    requestBody['status'] = 'in progress';
    final apiResult = await patch(
      hostUrl: tempApi,
      headers: headers,
      Api.getRentalRequest + "/$id",
      requestBody,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return true;
    } else {
      throw false;
    }
  }

  Future<bool> completedTrip(int id) async {
    final Map<String, dynamic> requestBody = {};
    requestBody['status'] = 'completed';
    final apiResult = await patch(
      hostUrl: tempApi,
      headers: headers,
      Api.getRentalRequest + "/$id",
      requestBody,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return true;
    } else {
      throw false;
    }
  }
}
