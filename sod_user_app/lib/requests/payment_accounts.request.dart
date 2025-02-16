import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/payment_account.dart';
import 'package:sod_user/services/http.service.dart';

class PaymentAccountRequest extends HttpService {
  //
  Future<ApiResponse> newPaymentAccount(Map<String, dynamic> payload) async {
    final apiResult = await post(Api.paymentAccount, payload);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<List<PaymentAccount>> paymentAccounts({int page = 1}) async {
    final apiResult = await get(
      Api.paymentAccount,
      forceRefresh: true,
      queryParameters: {"page": page},
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return (apiResponse.data)
          .map((e) => PaymentAccount.fromJson(e))
          .toList();
    }

    throw "${apiResponse.message}";
  }

  //
  Future<ApiResponse> requestPayout(Map<String, dynamic> payload) async {
    final apiResult = await post(Api.payoutRequest, payload);
    return ApiResponse.fromResponse(apiResult);
  }

  Future<ApiResponse> updatePaymentAccount(
      int id, Map<String, dynamic> payload) async {
    final apiResult = await patch(Api.paymentAccount + "/$id", payload);
    return ApiResponse.fromResponse(apiResult);
  }

  //getEarning
  Future<ApiResponse> getEarning() async {
    final apiResult = await get(Api.getEarning);
    return ApiResponse.fromResponse(apiResult);
  }

  //getEarningTransactions
  Future<ApiResponse> getEarningTransactions({int page = 1}) async {
    final apiResult = await get(
      Api.getEarningTransactions,
      queryParameters: {"page": page},
    );
    return ApiResponse.fromResponse(apiResult);
  }

  //changeBalanceToServiceWallet
  Future<ApiResponse> changeBalanceToServiceWallet(
      Map<String, dynamic> payload) async {
    final apiResult = await post(Api.changeBalanceToServiceWallet, payload);
    return ApiResponse.fromResponse(apiResult);
  }
}
