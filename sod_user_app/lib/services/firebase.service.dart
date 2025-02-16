import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:awesome_notifications/awesome_notifications.dart'
    hide NotificationModel;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:singleton/singleton.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_ui_settings.dart';
import 'package:sod_user/flavors.dart';
import 'package:sod_user/global/global_variable.dart';
import 'package:sod_user/models/notification.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/models/service.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/requests/order.request.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/services/chat.service.dart';
import 'package:sod_user/services/notification.service.dart';
import 'package:sod_user/views/pages/home.page.dart';
import 'package:sod_user/views/pages/order/receive_behalf_order_details.page.dart';
import 'package:sod_user/views/pages/service/service_details.page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'firebase_token.service.dart';
import 'package:sod_user/models/user_firestore.dart';
import 'package:sod_user/models/message_firestore.dart';

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
  Map? notificationPayloadData;

  setUpFirebaseMessaging() async {
    //Request for notification permission
    /*NotificationSettings settings = */
    await firebaseMessaging.requestPermission();
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    //subscribing to all topic
    firebaseMessaging.subscribeToTopic("all");
    FirebaseTokenService().handleDeviceTokenSync();

    //on notification tap to bring app back to life
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      saveNewNotification(message);
      selectNotification("From onMessageOpenedApp");
      //
      refreshOrdersList(message);
    });

    //normal notification listener
    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        saveNewNotification(message);
        showNotification(message);
        //
        refreshOrdersList(message);
      },
    );

    // set user on user ref on firestore
    ensureUserExists();
  }

  String lastNotificationTitle = "";
  String lastNotificationBody = "";

  //write to notification local list
  saveNewNotification(
    RemoteMessage? message, {
    String? title,
    String? body,
  }) {
    //
    notificationPayloadData = message != null ? message.data : null;
    if (message?.notification == null &&
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

    final imageUrl = message?.data["image"] ??
        (Platform.isAndroid
            ? message?.notification?.android?.imageUrl
            : message?.notification?.apple?.imageUrl);
    notificationModel!.image = imageUrl;
    //
    notificationModel!.timeStamp = DateTime.now().millisecondsSinceEpoch;
    print(
        "Save Successfully Notification ==> ${notificationModel!.body} at ${notificationModel!.timeStamp}");
    //add to database/shared pref
    NotificationService.addNotification(notificationModel!);
  }

  //
  showNotification(RemoteMessage message) async {
    if (message.notification == null && message.data["title"] == null) {
      return;
    }
    // Check Duplicate Notification
    String currentTitle = message.data["title"] ?? message.notification?.title;
    String currentBody = message.data["body"] ?? message.notification?.body;

    if (currentTitle == lastNotificationTitle &&
        currentBody == lastNotificationBody &&
        F.appFlavor != Flavor.sob_express) {
      lastNotificationTitle = "";
      lastNotificationBody = "";
      return;
    }
    //
    try {
      //
      String? imageUrl;
      try {
        imageUrl = message.data["image"] ??
            (Platform.isAndroid
                ? message.notification?.android?.imageUrl
                : message.notification?.apple?.imageUrl);
      } catch (error) {
        print("error getting notification image");
      }
      //
      if (imageUrl != null) {
        //
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: Random().nextInt(20),
            channelKey:
                NotificationService.appNotificationChannel().channelKey!,
            title: message.data["title"] ?? message.notification?.title,
            body: message.data["body"] ?? message.notification?.body,
            bigPicture: imageUrl,
            icon: "resource://drawable/notification_icon",
            notificationLayout: NotificationLayout.BigPicture,
            payload: Map<String, String>.from(message.data),
          ),
        );
        // Update LastNotification
        lastNotificationTitle = currentTitle;
        lastNotificationBody = currentBody;
      } else {
        //
        AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: Random().nextInt(20),
            channelKey:
                NotificationService.appNotificationChannel().channelKey!,
            title: message.data["title"] ?? message.notification?.title,
            body: message.data["body"] ?? message.notification?.body,
            icon: "resource://drawable/notification_icon",
            notificationLayout: NotificationLayout.Default,
            payload: Map<String, String>.from(message.data),
          ),
        );
        // Update LastNotifications
        lastNotificationTitle = currentTitle;
        lastNotificationBody = currentBody;
      }

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
      log("NotificationPayload ==> ${jsonEncode(notificationPayloadData)}");
      //
      if (notificationPayloadData != null && notificationPayloadData is Map) {
        //
        final isCarRental =
            (notificationModel!.body!.contains("khách hàng thuê xe")) ||
                (notificationModel!.body!
                    .contains("Có khách hàng thuê xe của bạn"));
        final isCancelSharedRide =
            (notificationModel!.title!.contains("Chuyến xe đã bị huỷ")) ||
                (notificationModel!.title!.contains("Trip Cancelled!"));
        final isChat = notificationPayloadData!.containsKey("is_chat");
        final isOrder = notificationPayloadData!.containsKey("is_order") &&
            (notificationPayloadData?["is_order"].toString() == "1" ||
                (notificationPayloadData?["is_order"] is bool &&
                    notificationPayloadData?["is_order"]));
        final isReceiveBehalf =
            (notificationModel!.body == 'Bạn nhận được đơn hàng nhận hộ') ||
                (notificationModel!.body!
                    .contains('Đơn hàng đã được giao thành công!'));

        ///
        final hasProduct = notificationPayloadData!.containsKey("product");
        final hasVendor = notificationPayloadData!.containsKey("vendor");
        final hasService = notificationPayloadData!.containsKey("service");

        if (isCarRental) {
          (Navigator.of(AppService().navigatorKey.currentContext!)
              .pushNamed(AppRoutes.carManagement));
          GlobalVariable.activeSecondIndex = true;
          return;
        }
        // Shared Ride
        if (isCancelSharedRide) {
          print("Tapped cancel Shared Ride ==> $isCancelSharedRide");
          Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
            AppRoutes.notificationDetailsRoute,
            arguments: notificationModel,
          );
          return;
        }
        // chat
        if (isChat) {
          // TODO: thêm nhận thông báo
          // final otherUserId =
          //     int.tryParse(notificationPayloadData!['sender_id']);

          // if (otherUserId == null) return;

          // final currentUser = await AuthServices.getCurrentUser();
          // final currentUserId = currentUser.id;
          // final otherUser = await FirebaseService().getUserById(otherUserId);
          // final chatId =
          //     await FirebaseService().createChat(currentUserId, otherUserId);

          // Navigator.of(AppService().navigatorKey.currentContext!)
          //     .push(MaterialPageRoute(builder: (context) {
          //   return ChatDetailPage(
          //     chatId: chatId,
          //     currentUserId: currentUserId,
          //     otherUser: otherUser,
          //   );
          // }));

         
          dynamic user = jsonDecode(notificationPayloadData!['user']);
          dynamic peer = jsonDecode(notificationPayloadData!['peer']);
          String chatPath = notificationPayloadData!['path'];
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
            supportMedia: AppUISettings.canCustomerChatSupportMedia,
          );
          //
          Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
            AppRoutes.chatRoute,
            arguments: chatEntity,
          );
        }
        //order
        else if (isOrder || isReceiveBehalf) {
          //
          print('Đúng điều kiện nhảy vào đơn hàng');
          print("Is Order Notification || Is Receive Behalf Notification");
          try {
            //fetch order from api
            int orderId = int.parse("${notificationPayloadData!['order_id']}");
            var order = await OrderRequest().getOrderDetails(id: orderId);
            //
            if (isReceiveBehalf) {
              Navigator.push(
                  AppService().navigatorKey.currentContext!,
                  MaterialPageRoute(
                      builder: ((context) => ReceiveBehalfOrderDetailsPage(
                            order: order,
                          ))));
            } else {
              Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
                AppRoutes.orderDetailsRoute,
                arguments: order,
              );
            }
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
        //vendor type of notification
        else if (hasVendor) {
          //
          final vendor = Vendor.fromJson(
            jsonDecode(notificationPayloadData?['vendor']),
          );
          //
          Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
            AppRoutes.vendorDetails,
            arguments: vendor,
          );
        }
        //product type of notification
        else if (hasProduct) {
          //
          final product = Product.fromJson(
            jsonDecode(notificationPayloadData?['product']),
          );
          //
          Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
            AppRoutes.product,
            arguments: product,
          );
        }
        //service type of notification
        else if (hasService) {
          //
          final service = Service.fromJson(
            jsonDecode(notificationPayloadData!['service']),
          );
          //
          Navigator.of(AppService().navigatorKey.currentContext!).push(
            MaterialPageRoute(
              builder: (_) => ServiceDetailsPage(
                service,
              ),
            ),
          );
        }
        //regular notifications
        else {
          Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
            AppRoutes.notificationDetailsRoute,
            arguments: notificationModel,
          );
        }
      } else {
        Navigator.of(AppService().navigatorKey.currentContext!).pushNamed(
          AppRoutes.notificationDetailsRoute,
          arguments: notificationModel,
        );
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
