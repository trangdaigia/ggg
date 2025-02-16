import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:sod_user/services/http.service.dart';
import 'package:sod_user/driver_lib/models/review.dart';

class ReviewRequest extends HttpService {
  //
  static Future<List<Review>> getReviewed({bool forceRefresh = false}) async {
    try {
      final response = await HttpService().get(
        Api.reviewed,
        forceRefresh: forceRefresh,
      );
      final reviews = response.data['reviews'] as List;
      return reviews
          .map((review) => Review.fromJson(review as Map<String, dynamic>))
          .toList();
    } catch (error) {
      print('getReviewed Error ==> $error');
      return [];
    }
  }

  static Future<List<Review>> getMytReview({bool forceRefresh = false}) async {
    try {
      final response = await HttpService().get(
        Api.myReview,
        forceRefresh: forceRefresh,
      );
      final reviews = response.data['reviews'] as List;
      return reviews
          .map((review) => Review.fromJson(review as Map<String, dynamic>))
          .toList();
    } catch (error, stackTrace) {
      print('getMytReview Error ==> $error');
      print('getMytReview StackTrace ==> $stackTrace');
      return [];
    }
  }
}
