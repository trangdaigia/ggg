import 'package:firestore_chat/firestore_chat.dart';
import 'package:sod_user/driver_lib/constants/api.dart';
import 'package:sod_user/driver_lib/models/api_response.dart';
import 'package:sod_user/services/http.service.dart';

class ChatRequest extends HttpService {
  //
  Future<ApiResponse> sendNotification({
    required String title,
    required String body,
    required String topic,
    required String path,
    required PeerUser user,
    required PeerUser otherUser,
  }) async {
    //
    dynamic userObject = {
      "id": user.id,
      "name": user.name,
      "photo": user.image,
    };

    //
    dynamic otherUserObject = {
      "id": otherUser.id,
      "name": otherUser.name,
      "photo": otherUser.image,
    };

    final apiResult = await post(Api.chat, {
      "title": title,
      "body": body,
      "topic": topic,
      "path": path,
      "user": userObject,
      "peer": otherUserObject,
    });
    return ApiResponse.fromResponse(apiResult);
  }
}
