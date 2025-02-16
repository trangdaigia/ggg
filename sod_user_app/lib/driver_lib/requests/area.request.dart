import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:sod_user/driver_lib/models/api_response.dart';
import 'package:sod_user/services/http.service.dart';

class AreaRequest extends HttpService {
  Future<List<Map<String, String>>> getCountries() async {
    final apiResult = await get(
      Api.countries,
    );

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      final countries = [
        for (final item in apiResponse.body['countries'])
          if (item['status'] == 'active')
            {
              'id': item['id'].toString(),
              'name': item['name'].toString(),
            }
      ];

      return countries;
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<List<Map<String, String>>> getStates(String countryId) async {
    final apiResult = await get(
      Api.stateByCountry(countryId),
    );

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      final states = [
        for (final item in apiResponse.body['states'])
          if (item['status'] == 'active')
            {
              'id': item['id'].toString(),
              'name': item['name'].toString(),
            }
      ];

      return states;
    } else {
      throw "${apiResponse.message}";
    }
  }

  Future<List<Map<String, String>>> getCities(String stateId) async {
    final apiResult = await get(
      Api.cityByState(stateId),
    );

    //
    final apiResponse = ApiResponse.fromResponse(apiResult);
    if (apiResponse.allGood) {
      final cities = [
        for (final item in apiResponse.body['cities'])
          if (item['status'] == 'active')
            {
              'id': item['id'].toString(),
              'name': item['name'].toString(),
            }
      ];

      return cities;
    } else {
      throw "${apiResponse.message}";
    }
  }
}
