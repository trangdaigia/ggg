import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sod_vendor/models/message_firestore.dart';
import 'package:sod_vendor/models/user_firestore.dart';
import 'package:stacked/stacked.dart';
import 'package:sod_vendor/services/firebase.service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sod_vendor/models/delivery_address.dart';
import 'package:sod_vendor/constants/app_map_settings.dart';
import 'package:sod_vendor/constants/app_strings.dart';
import 'package:sod_vendor/services/geocoder.service.dart';
import 'package:sod_vendor/services/location.service.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:sod_vendor/views/pages/shared/ops_map.page.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ChatDetailViewModel extends BaseViewModel {
  final String chatId;
  final int currentUserId;
  final UserFirestore otherUser;
  final BuildContext context;

  ChatDetailViewModel({
    required this.chatId,
    required this.currentUserId,
    required this.otherUser,
    required this.context,
  }) : super();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  late Stream<QuerySnapshot<Map<String, dynamic>>> _messageStream;
  final messageController = TextEditingController();
  final scrollController = ScrollController();

  List<MessageFirestore> messages = [];
  DocumentSnapshot<Map<String, dynamic>>? lastDocument;
  bool isLoadingMore = false;
  bool hasMoreMessages = true;
  bool isSending = false;
  void setSending(bool value) {
    isSending = value;
    notifyListeners();
  }

  bool isTyping = false;
  void setTyping(bool value) {
    // for typing indicator later...
    isTyping = value;
  }

  void initialise() async {
    // Thêm listener cho cuộn để tải thêm tin nhắn
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          hasMoreMessages) {
        loadMoreMessages();
      }
    });
    // Tạo stream cho tin nhắn mới
    _messageStream = firestore
        .collection('chats/$chatId/messages')
        .orderBy('sentAt', descending: true)
        .snapshots();

    // Lắng nghe sự kiện và cập nhật danh sách tin nhắn
    _messageStream.listen((snapshot) {
      final newMessages = snapshot.docs
          .map((doc) => MessageFirestore.fromJson(doc.data()))
          .toList();

      // Cập nhật tin nhắn mới
      messages = newMessages;
      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      // Cập nhật trạng thái phân trang
      hasMoreMessages = snapshot.docs.length >= 20;

      // Cuộn xuống khi có tin nhắn mới
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      notifyListeners();
    });
  }

  // Hàm tải thêm tin nhắn khi cuộn
  Future<void> loadMoreMessages({int limit = 20}) async {
    if (!hasMoreMessages || isLoadingMore) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      final query = firestore
          .collection('chats/$chatId/messages')
          .orderBy('sentAt', descending: true)
          .startAfterDocument(lastDocument!)
          .limit(limit);

      final snapshot = await query.get();

      final newMessages = snapshot.docs
          .map((doc) => MessageFirestore.fromJson(doc.data()))
          .toList();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
      }

      messages.addAll(newMessages);
      hasMoreMessages = snapshot.docs.length == limit;
    } catch (e) {
      print("Error loading more messages: $e");
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> onSendClick() async {
    final message = messageController.text.trim();
    if (message.isEmpty) return;
    messageController.clear();

    //setSending(true);
    await FirebaseService().sendMessage(
      chatId: chatId,
      currentUserId: currentUserId,
      otherUserId: otherUser.id,
      messageText: message,
    );
    //setSending(false);
  }

  Future<void> onSendImageClick() async {
    final image = await handleGetImage();
    if (image == null) return;

    setSending(true);
    await FirebaseService().sendMessage(
      chatId: chatId,
      currentUserId: currentUserId,
      otherUserId: otherUser.id,
      type: MessageTypes.image,
      imageFile: File(image.path),
    );
    setSending(false);
  }

  Future<void> onSendLocationClick() async {
    final googleMapUrl = await handleGetLocation();
    if (googleMapUrl == null) return;

    //setSending(true);
    await FirebaseService().sendMessage(
      chatId: chatId,
      currentUserId: currentUserId,
      otherUserId: otherUser.id,
      type: MessageTypes.location,
      messageText: googleMapUrl,
    );
    //setSending(false);
  }

  // Hàm xử lý chọn hình ảnh
  Future<File?> handleGetImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, size: 30),
                title: Text('Camera'.tr()),
                onTap: () async {
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.camera);
                  Navigator.of(context).pop(image);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library, size: 30),
                title: Text('Gallery'.tr()),
                onTap: () async {
                  final XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
                  Navigator.of(context).pop(image);
                },
              ),
            ],
          ),
        );
      },
    );

    return image != null ? File(image.path) : null;
  }

  // Hàm xử lý chọn vị trí
  Future<String?> handleGetLocation() async {
    Future<dynamic> pickLocation() async {
      LatLng initialPosition = LatLng(0.00, 0.00);
      double initialZoom = 0;

      // Lấy vị trí hiện tại nếu có
      if (LocationService.currenctAddress != null) {
        initialPosition = LatLng(
          LocationService.currenctAddress?.coordinates?.latitude ?? 0.00,
          LocationService.currenctAddress?.coordinates?.longitude ?? 0.00,
        );
        initialZoom = 15;
      }

      String? mapRegion;
      try {
        mapRegion = await Utils.getCurrentCountryCode();
      } catch (error) {
        print("Error getting sim country code => $error");
      }
      mapRegion ??= AppStrings.countryCode.trim().split(",").firstWhere(
            (e) => !e.toLowerCase().contains("auto"),
            orElse: () => "",
          );

      // Chọn bản đồ dựa trên cài đặt
      if (!AppMapSettings.useGoogleOnApp) {
        return await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OPSMapPage(
              region: mapRegion,
              initialPosition: initialPosition,
              useCurrentLocation: true,
              initialZoom: initialZoom,
            ),
          ),
        );
      }

      // Sử dụng Google Maps
      return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlacePicker(
            apiKey: AppStrings.googleMapApiKey,
            autocompleteLanguage: translator.activeLocale.languageCode,
            region: mapRegion,
            onPlacePicked: (result) {
              Navigator.of(context).pop(result);
            },
            initialPosition: initialPosition,
          ),
        ),
      );
    }

    // Hàm lấy tên thành phố từ tọa độ
    Future<DeliveryAddress> fetchCityFromCoordinates(
        DeliveryAddress deliveryAddress) async {
      final coordinates = Coordinates(
        deliveryAddress.latitude ?? 0.00,
        deliveryAddress.longitude ?? 0.00,
      );

      final addresses =
          await GeocoderService().findAddressesFromCoordinates(coordinates);

      for (var address in addresses) {
        deliveryAddress.address = address.addressLine ?? '';
        deliveryAddress.name = address.featureName ?? address.addressLine ?? '';
        deliveryAddress.city = address.locality ?? address.subLocality ?? '';
        deliveryAddress.state = address.adminArea ?? address.subAdminArea ?? '';
        deliveryAddress.country = address.countryName ?? '';

        // Dừng khi đủ thông tin
        if (deliveryAddress.address != null &&
            deliveryAddress.city != null &&
            deliveryAddress.state != null &&
            deliveryAddress.country != null) {
          break;
        }
      }

      return deliveryAddress;
    }

    // Bắt đầu logic chính
    dynamic result = await pickLocation();
    DeliveryAddress deliveryAddress = DeliveryAddress(
      latitude: 0.00,
      longitude: 0.00,
      city: "",
      state: "",
      country: "",
      createdAt: DateTime.now(),
      id: 0,
      name: "",
      photo: '',
      userId: 0,
      distance: 0,
      address: "",
      isDefault: 1,
      updatedAt: DateTime.now(),
      formattedDate: '',
    );

    if (result is PickResult) {
      // Gán dữ liệu từ PickResult
      deliveryAddress.address = result.formattedAddress ?? '';
      deliveryAddress.latitude = result.geometry?.location.lat ?? 0.0;
      deliveryAddress.longitude = result.geometry?.location.lng ?? 0.0;

      if (result.addressComponents != null &&
          result.addressComponents!.isNotEmpty) {
        for (var addressComponent in result.addressComponents!) {
          if (addressComponent.types.contains("locality")) {
            deliveryAddress.city = addressComponent.longName;
          }
          if (addressComponent.types.contains("administrative_area_level_1")) {
            deliveryAddress.state = addressComponent.longName;
          }
          if (addressComponent.types.contains("country")) {
            deliveryAddress.country = addressComponent.longName;
          }
        }
      } else {
        // Lấy từ tọa độ nếu thiếu thông tin
        deliveryAddress = await fetchCityFromCoordinates(deliveryAddress);
      }
    } else if (result is Address) {
      // Gán dữ liệu từ Address
      deliveryAddress.address = result.addressLine ?? '';
      deliveryAddress.latitude = result.coordinates?.latitude ?? 0;
      deliveryAddress.longitude = result.coordinates?.longitude ?? 0;
      deliveryAddress.city = result.locality ?? '';
      deliveryAddress.state = result.adminArea ?? '';
      deliveryAddress.country = result.countryName ?? '';
    }

    // Tạo link Google Maps
    final latitude = deliveryAddress.latitude;
    final longitude = deliveryAddress.longitude;
    final address = Uri.encodeComponent(deliveryAddress.address ?? "");

    final googleMapLink = latitude != null && longitude != null
        ? "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude"
        : address.isNotEmpty
            ? "https://www.google.com/maps/search/?api=1&query=$address"
            : null;

    return googleMapLink;
  }
}
