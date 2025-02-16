import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart'
    hide NotificationModel;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:sod_vendor/constants/app_routes.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/constants/app_ui_settings.dart';
import 'package:sod_vendor/models/notification.dart';
import 'package:sod_vendor/models/order.dart';
import 'package:sod_vendor/requests/order.request.dart';
import 'package:sod_vendor/services/app.service.dart';
import 'package:sod_vendor/services/auth.service.dart';
import 'package:sod_vendor/services/chat.service.dart';
import 'package:sod_vendor/services/notification.service.dart';
import 'package:sod_vendor/views/pages/home.page.dart';
import 'package:singleton/singleton.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_vendor/models/user_firestore.dart';
import 'package:sod_vendor/models/message_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  //
  /// Factory method that reuse same instance automatically
  factory FirebaseService() => Singleton.lazy(() => FirebaseService._());

  /// Private constructor
  FirebaseService._() {}

  //
  NotificationModel? notificationModel;
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  dynamic notificationPayloadData;

  setUpFirebaseMessaging() async {
    //Request for notification permission
    /*NotificationSettings settings = */
    await firebaseMessaging.requestPermission();
    //subscribing to all topic
    firebaseMessaging.subscribeToTopic("all");

    //on notification tap tp bring app back to life
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("FCM Open app");
      saveNewNotification(message);
      selectNotification("From onMessageOpenedApp");
      //
      refreshOrdersList(message);
    });

    //normal notification listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("FCM Received");
      saveNewNotification(message);
      showNotification(message);
      //
      refreshOrdersList(message);
    });

    // set user on user ref on firestore
    ensureUserExists();
  }

  //write to notification list
  saveNewNotification(
    RemoteMessage? message, {
    String? title,
    String? body,
  }) {
    //
    notificationPayloadData = message != null ? message.data : null;
    if (message?.notification == null &&
        message?.data != null &&
        message?.data["title"] == null &&
        title == null) {
      return;
    }
    //Saving the notification
    notificationModel = NotificationModel();
    notificationModel!.title =
        message?.notification?.title ?? title ?? message?.data["title"] ?? "";
    notificationModel!.body =
        message?.notification?.body ?? body ?? message?.data["body"] ?? "";
    //
    try {
      final imageUrl = message?.data["image"] ??
          (Platform.isAndroid
              ? message?.notification?.android?.imageUrl
              : message?.notification?.apple?.imageUrl);
      notificationModel!.image = imageUrl;
    } catch (error) {
      print("Error ==> $error");
    }
    notificationModel!.timeStamp = DateTime.now().millisecondsSinceEpoch;

    //add to database/shared pref
    NotificationService.addNotification(notificationModel!);
  }

  //
  showNotification(RemoteMessage message) async {
    if (message.notification == null && message.data["title"] == null) {
      return;
    }

    //
    notificationPayloadData = message.data;

    //
    try {
      //
      final imageUrl = message.data["image"] ??
          (Platform.isAndroid
              ? message.notification?.android?.imageUrl
              : message.notification?.apple?.imageUrl);

      //crete notification content
      NotificationContent notificationContent = NotificationContent(
        id: Random().nextInt(20),
        channelKey: getNotificationChannelKey(message),
        title: message.data["title"] ?? message.notification?.title,
        body: message.data["body"] ?? message.notification?.body,
        bigPicture: imageUrl,
        icon: "resource://drawable/notification_icon",
        notificationLayout: imageUrl != null
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        payload: Map<String, String>.from(message.data),
      );
      //for new order
      final isOrder = notificationPayloadData != null &&
          notificationPayloadData["is_order"] != null;
      if (isOrder) {
        //new status
        final statues = ["pending", "new"];
        bool isPending = statues.contains(notificationPayloadData["status"]);
        Map<String, String> payload = Map<String, String>.from(message.data);
        if (isPending) {
          notificationContent = NotificationContent(
            id: AppService().neworderNotificationId,
            channelKey: getNotificationChannelKey(message),
            title: message.data["title"] ?? message.notification?.title,
            body: message.data["body"] ?? message.notification?.body,
            bigPicture: imageUrl,
            icon: "resource://drawable/notification_icon",
            notificationLayout: imageUrl != null
                ? NotificationLayout.BigPicture
                : NotificationLayout.Default,
            payload: payload,
            //
            wakeUpScreen: true,
            fullScreenIntent: true,
            locked: true,
            autoDismissible: false,
            criticalAlert: true,
          );
        }
      }

      //
      AwesomeNotifications().createNotification(content: notificationContent);

      ///
    } catch (error) {
      print("Notification Show error ===> ${error}");
    }
  }

  //handle on notification selected
  Future selectNotification(String? payload) async {
    if (payload == null) {
      return;
    }
    try {
      //
      final isChat = notificationPayloadData != null &&
          notificationPayloadData["is_chat"] != null;
      final isOrder = notificationPayloadData != null &&
          notificationPayloadData["is_order"] != null;
      //
      if (isChat) {
        //
        dynamic user = jsonDecode(notificationPayloadData['user']);
        dynamic peer = jsonDecode(notificationPayloadData['peer']);
        String chatPath = notificationPayloadData['path'];
        //
        Map<String, PeerUser> peers = {
          '${user['id']}': PeerUser(
            id: '${user['id']}',
            name: "${user['name']}",
            image: "${user['photo']}",
          ),
          '${peer['id']}': PeerUser(
            id: '${peer['id']}',
            name: "${peer['name']}",
            image: "${peer['photo']}",
          ),
        };
        //
        final peerRole = peer["role"];
        //
        final chatEntity = ChatEntity(
          onMessageSent: ChatService.sendChatMessage,
          mainUser: peers['${user['id']}']!,
          peers: peers,
          //don't translate this
          path: chatPath,
          title: peer["role"] == null
              ? "Chat with".tr() + " ${peer['name']}"
              : peerRole == 'vendor'
                  ? "Chat with vendor".tr()
                  : "Chat with driver".tr(),
          supportMedia: AppUISettings.canVendorChatSupportMedia,
        );
        Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
          AppRoutes.chatRoute,
          arguments: chatEntity,
        );
      }
      //order
      else if (isOrder) {
        //
        try {
          //fetch order from api
          int orderId = int.parse("${notificationPayloadData!['order_id']}");
          var order = await OrderRequest().getOrderDetails(id: orderId);
          //
          Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
            AppRoutes.orderDetailsRoute,
            arguments: order,
          );
        } catch (error) {
          //navigate to orders page
          await Navigator.of(AppService().navigatorKey.currentContext!).push(
            MaterialPageRoute(
              builder: (_) => HomePage(),
            ),
          );
          //then switch to orders tab
          AppService().changeHomePageIndex();
        }
      }
      //regular notifications
      else {
        Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
            AppRoutes.notificationDetailsRoute,
            arguments: notificationModel);
      }
    } catch (error) {
      print("Error opening Notification ==> $error");
    }
  }

  //refresh orders list if the notification is about assigned order
  void refreshOrdersList(RemoteMessage message) async {
    if (message.data["is_order"] != null) {
      await Future.delayed(Duration(seconds: 3));
      AppService().refreshAssignedOrders.add(true);
    }
  }

  //get notification sound
  String getNotificationChannelKey(RemoteMessage message) {
    //check if message is from order
    if (message.data["is_order"] != null) {
      final orderStatus = message.data["status"] ?? "new";
      if (orderStatus == "pending") {
        return NotificationService.appNotificationChannel(
          mChannelKey: AppStrings.newOrderNotificationChannelKey,
          mSoundSource: AppStrings.appvietNotificationSoundSource,
        ).channelKey!;
      }
    }
    return NotificationService.appNotificationChannel().channelKey!;
  }


  ////////////////////////////////////////////////////////////
  /// Chat on Firestore:

  //
  Future<UserFirestore> getUserById(int userId) async {
    final doc =
        await firestore.collection('users').doc(userId.toString()).get();

    if (!doc.exists) {
      return UserFirestore(id: userId, name: 'User $userId');
    }
    return UserFirestore.fromJson(doc.data()!);
  }

  //
  Future<String> createChat(int userId1, int userId2) async {
    final chatId =
        '${userId1 < userId2 ? userId1 : userId2}_${userId1 > userId2 ? userId1 : userId2}';

    // Tạo cuộc trò chuyện nếu chưa tồn tại
    final chatRef = firestore.collection('chats').doc(chatId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'id': chatId,
        'userIds': [userId1, userId2],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageType': ''
      });
    }

    return chatId;
  }

  // chưa dùng
  Future<void> deleteChat(String chatId, int userIdToDelete) async {
    // Lấy tất cả tin nhắn của cuộc trò chuyện
    final messagesQuery =
        await firestore.collection('chats/$chatId/messages').get();

    // Lọc các tin nhắn của người xóa (userIdToDelete)
    final messagesToDelete = messagesQuery.docs.where((doc) {
      final message = MessageFirestore.fromJson(doc.data());
      return message.fromId ==
          userIdToDelete; // Xóa tất cả tin nhắn của người xóa
    }).toList();

    // Xóa các tin nhắn của người xóa
    for (var messageDoc in messagesToDelete) {
      await firestore
          .collection('chats/$chatId/messages')
          .doc(messageDoc.id)
          .delete();
    }

    // Cập nhật trạng thái cuộc trò chuyện (vẫn giữ cuộc trò chuyện nhưng chỉ người xóa không thấy tin nhắn)
    await firestore.collection('chats').doc(chatId).set({
      'lastMessage':
          'Conversation deleted', // Cập nhật trạng thái cuộc trò chuyện
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastMessageType': 'text',
    }, SetOptions(merge: true));
  }

  //
  Future<void> sendMessage({
    required String chatId,
    required int currentUserId,
    required int otherUserId,
    String? messageText,
    MessageTypes type = MessageTypes.text,
    File? imageFile,
  }) async {
    final sentAt = DateTime.now();

    // Nếu type là 'image' thì gửi ảnh
    if (type == MessageTypes.image && imageFile != null) {
      // Lưu ảnh vào Firebase Storage
      final ext = imageFile.path.split('.').last;
      final ref = storage.ref().child(
          'images/${chatId}/${DateTime.now().millisecondsSinceEpoch}.$ext');

      await ref.putFile(imageFile, SettableMetadata(contentType: 'image/$ext'));
      final imageUrl = await ref.getDownloadURL();

      // Tạo message với URL ảnh
      final message = MessageFirestore(
        chatId: chatId,
        fromId: currentUserId,
        toId: otherUserId,
        message: imageUrl, // Gửi URL ảnh thay vì text
        type: type,
        sentAt: sentAt,
        read: false,
      );

      // Thêm message vào sub-collection
      await firestore
          .collection('chats/$chatId/messages')
          .add(message.toJson());

      // Cập nhật thông tin tổng quan của cuộc trò chuyện
      await firestore.collection('chats').doc(chatId).set({
        'lastMessage': 'Image', // Thông báo tin nhắn là ảnh
        'lastMessageTime': sentAt,
        'lastMessageType': type.name,
      }, SetOptions(merge: true));
    } else {
      // Nếu không phải ảnh, gửi tin nhắn văn bản như bình thường
      final message = MessageFirestore(
        chatId: chatId,
        fromId: currentUserId,
        toId: otherUserId,
        message: messageText!,
        type: type,
        sentAt: sentAt,
        read: false,
      );

      // Thêm message vào sub-collection
      await firestore
          .collection('chats/$chatId/messages')
          .add(message.toJson());

      // Cập nhật thông tin tổng quan của cuộc trò chuyện
      await firestore.collection('chats').doc(chatId).set({
        'lastMessage': type == MessageTypes.location ? 'Location' : messageText,
        'lastMessageTime': sentAt,
        'lastMessageType': type.name,
      }, SetOptions(merge: true));

      // TODO: Gửi thông báo cho người nhận
      // final apiResponse = await ChatRequest().sendNotification(
      //   title: "New Message from".tr() + " ${currentUserId}",
      //   body: messageText,
      //   topic: otherPeer!.id,
      //   path: chatEntity.path,
      //   user: chatEntity.mainUser,
      //   otherUser: otherPeer,
      // );
    }
  }

  //
  Future<void> markLatestMessageAsRead(String chatId) async {
    final latestMessageQuery = await firestore
        .collection('chats/$chatId/messages')
        .orderBy('sentAt', descending: true)
        .limit(1)
        .get();

    if (latestMessageQuery.docs.isNotEmpty) {
      final latestMessageDoc = latestMessageQuery.docs.first;

      await firestore
          .collection('chats/$chatId/messages')
          .doc(latestMessageDoc.id)
          .update({'read': true});
    }
  }

  // Hàm kiểm tra và tạo user nếu chưa tồn tại
  Future<void> ensureUserExists() async {
    final currentUser = await AuthServices.getCurrentUser();
    //final fcmToken = await firebaseMessaging.getToken();

    final userRef =
        firestore.collection('users').doc(currentUser.id.toString());

    await userRef.set({
      'id': currentUser.id,
      'name': currentUser.name,
      'profileImage': currentUser.photo,
      'lastActive': FieldValue.serverTimestamp(),
      'isOnline': false,
      //'pushToken': fcmToken,
    });
  }
}
