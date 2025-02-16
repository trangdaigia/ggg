import 'package:sod_vendor/constants/api.dart';
import 'package:sod_vendor/models/api_response.dart';
import 'package:sod_vendor/models/payment_account.dart';
import 'package:sod_vendor/services/http.service.dart';

class PaymentAccountRequest extends HttpService {
  //
  Future<PaymentAccount> newPaymentAccount(Map<String, dynamic> payload) async {
    final apiResult = await post(Api.paymentAccount, payload);
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return PaymentAccount.fromJson(apiResponse.body["data"]);
    }

    throw apiResponse.message;
  }

  Future<ApiResponse> updatePaymentAccount(
      int id, Map<String, dynamic> payload) async {
    final apiResult = await patch(Api.paymentAccount + "/$id", payload);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<List<PaymentAccount>> paymentAccounts({int page = 1}) async {
    final apiResult = await get(
      Api.paymentAccount,
      queryParameters: {"page": page},
      forceRefresh: true,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.data)
          .map((e) => PaymentAccount.fromJson(e))
          .toList();
    }

    throw apiResponse.message;
  }

  //
  Future<ApiResponse> requestPayout(Map<String, dynamic> payload) async {
    final apiResult = await post(Api.payoutRequest, payload);
    return ApiResponse.fromResponse(apiResult);
  }
}
