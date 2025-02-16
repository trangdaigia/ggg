import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/real_estate.dart';
import 'package:sod_user/models/real_estate_category.dart';
import 'package:sod_user/services/http.service.dart';
import 'package:sod_user/services/location.service.dart';

class RealEstateRequest extends HttpService {
  int page = 1;
  bool canLoadMore = true;
  //
  Future<List<RealEstate>> index({Map<String, dynamic>? query}) async {
    final apiResult = await get(
      "${Api.realEstate}?${query != null ? "${Uri(queryParameters: query).query}&" : ""}page=$page",
      staleWhileRevalidate: true,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      print('(${LocationService.currenctAddress?.coordinates?.latitude})');
      print('(${LocationService.currenctAddress?.coordinates?.longitude})');
      page = page + 1;
      List<RealEstate> result = [];
      apiResponse.data.forEach((element) {
        try {
          result.add(RealEstate.fromJson(element));
        } catch (error) {
          print("===============================");
          print("Error Fetching Real estate ==> $error");
          print("Real Estate ==> ${element['id']}");
          print("===============================");
        }
      });
      if (result.length == 0) canLoadMore = false;
      return result;
    }
    throw apiResponse.message!;
  }

  Future<RealEstate> realEstateDetails(int id) async {
    //
    final apiResult = await get(
      "${Api.realEstate}/$id",
      staleWhileRevalidate: true,
    );
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      return RealEstate.fromJson(apiResponse.body);
    }
    throw apiResponse.message!;
  }

  Future<List<List<RealEstate>>> realEstateBySellingType() async {
    final apiResultList = await Future.wait([
      get("${Api.realEstate}?selling_type=Sell"),
      get("${Api.realEstate}?selling_type=Rent")
    ]);
    final apiResponseList = apiResultList.map((x) {
      final apiResponse = ApiResponse.fromResponse(x);
      if (!apiResponse.allGood) return [] as List<RealEstate>;
      List<RealEstate> result = [];
      apiResponse.data.forEach((element) {
        try {
          result.add(RealEstate.fromJson(element));
        } catch (error) {
          print("===============================");
          print("Error Fetching Real estate ==> $error");
          print("Real estate ==> ${element['id']}");
          print("===============================");
        }
      });
      return result;
    }).toList();
    return apiResponseList;
  }

  Future<List<RealEstateCategory>> getRealEstateCatagories() async {
    final apiResult = await get("${Api.realEstateCategory}");
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      List<RealEstateCategory> result = [];
      apiResponse.data.forEach((element) {
        try {
          result.add(RealEstateCategory.fromJson(element));
        } catch (error) {
          print("===============================");
          print("Error Fetching Real estate category ==> $error");
          print("Real estate category ==> ${element['id']}");
          print("===============================");
        }
      });
      return result;
    }
    throw Exception("Api error ==> ${apiResponse.message}");
  }
}
