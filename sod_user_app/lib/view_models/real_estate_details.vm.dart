import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_ui_settings.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/models/real_estate.dart';
import 'package:sod_user/models/user.dart';
import 'package:sod_user/requests/real_estate.request.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/services/chat.service.dart';
import 'package:sod_user/services/firebase.service.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/views/pages/auth/login.page.dart';
import 'package:sod_user/views/pages/chat/chat_detail.page.dart';

class RealEstateDetailsViewModel extends MyBaseViewModel {
  RealEstateDetailsViewModel(BuildContext context, this.realEstate) {
    this.viewContext = context;
  }
  RealEstate realEstate;
  final RealEstateRequest realEstateRequest = RealEstateRequest();

  List<String>? checkedPhotos;

  void initialise() async {
    getRealEstateDetails();
  }

  void getRealEstateDetails() async {
    //
    setBusyForObject(realEstate, true);

    try {
      final oldRealEstateHeroTag = realEstate.heroTag;
      realEstate = await realEstateRequest.realEstateDetails(realEstate.id);
      realEstate.heroTag = oldRealEstateHeroTag;

      clearErrors();
      // kiểm tra ảnh sản phẩm có hợp lệ hay không để hiển thị
      checkPhotos();

      // khởi tạo để cập nhật UI khi không có ảnh nào hợp lệ
      if (checkedPhotos == null) {
        checkedPhotos = [];
      }
    } catch (error) {
      setError(error);
      toastError("$error");
    } finally {
      setBusyForObject(realEstate, false);
    }
  }

  void checkPhotos() async {
    if (realEstate.photos == null) return;
    for (String photo in realEstate.photos!) {
      bool isValid = await Utils.checkImageUrl(photo);
      if (isValid) {
        if (checkedPhotos == null) {
          checkedPhotos = [];
        }
        checkedPhotos!.add(photo);
        notifyListeners();
      }
    }
  }

  chatVendor({
    required BuildContext context,
    bool loadNext = true,
  }) async {
    if (realEstate.vendor == null) {
      setError("Unable to connect to vendor".tr());
      return;
    }
    if (!AuthServices.authenticated()) {
      final result = Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(
            required: true,
          ),
        ),
      );
      print(result);
      return;
    }
    openChat(realEstate.vendor!.id);
    return;

    // Old chat
    // final currentUser  = await AuthServices.getCurrentUser();
    // print(AuthServices.currentUser);
    // Map<String, PeerUser> peers = {
    //   'user_${currentUser.id}': PeerUser(
    //     id: 'user_${currentUser.id}',
    //     name: currentUser.name,
    //     image: currentUser.photo,
    //   ),
    //   'vendor_${realEstate.vendor!.id}': PeerUser(
    //     id: "vendor_${realEstate.vendor!.id}",
    //     name: realEstate.vendor!.name,
    //     image: realEstate.vendor!.logo,
    //   ),
    // };
    // //
    // final chatEntity = ChatEntity(
    //   onMessageSent: ChatService.sendChatMessage,
    //   mainUser: peers['vendor_${realEstate.vendor!.id}']!,
    //   peers: peers,
    //   //don't translate this
    //   path: 'realEstates/' +
    //       "${realEstate.vendor!.id}_${currentUser!.id}" +
    //       "/customerVendor/chats",
    //   title: "Chat with customer".tr(),
    //   supportMedia: AppUISettings.canCustomerChatSupportMedia,
    // );
    // //
    // Navigator.of(viewContext).pushNamed(
    //   AppRoutes.chatRoute,
    //   arguments: chatEntity,
    // );
  }

  void openChat(int? otherUserId) async {
    if (otherUserId == null) return;

    final currentUser  = await AuthServices.getCurrentUser();
    final currentUserId = currentUser.id;
    final otherUser = await FirebaseService().getUserById(otherUserId);
    final chatId = await FirebaseService().createChat(currentUserId, otherUserId);

    Navigator.of(viewContext).push(MaterialPageRoute(builder: (context) {
      return ChatDetailPage(
        chatId: chatId,
        currentUserId: currentUserId,
        otherUser: otherUser,
      );
    }));
  }
}
