import 'package:sod_user/constants/api.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/job.dart';
import 'package:sod_user/models/job_category.dart';
import 'package:sod_user/services/http.service.dart';

class JobRequest extends HttpService {
  //Job
  Future<List<JobCategory>> jobsCategory() async {
    final apiResult = await get(
      Api.jobsCategory,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => JobCategory.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  //Job
  Future<List<Job>> jobsList() async {
    final apiResult = await get(
      Api.jobsList,
    );

    final apiResponse = ApiResponse.fromResponse(apiResult);

    if (apiResponse.allGood) {
      return apiResponse.data
          .map((jsonObject) => Job.fromJson(jsonObject))
          .toList();
    } else {
      throw apiResponse.message!;
    }
  }

  // Future<ApiResponse> createJob(Map<String, dynamic> data) async {
  //   final apiResult = await post(Api.job, data);
  //   return ApiResponse.fromResponse(apiResult);
  // }

  // Future<ApiResponse> applyJob(Map<String, dynamic> data) async {
  //   final apiResult = await post(Api.jobApply, data);
  //   return ApiResponse.fromResponse(apiResult);
  // }
}
