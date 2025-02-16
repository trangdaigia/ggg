import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firestore_chat/firestore_chat.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:sod_user/constants/app_file_limit.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/constants/app_ui_settings.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/api_response.dart';
import 'package:sod_user/models/cart.dart';
import 'package:sod_user/models/option.dart';
import 'package:sod_user/models/order.dart';
import 'package:sod_user/models/payment_method.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/requests/order.request.dart';
import 'package:sod_user/services/app.service.dart';
import 'package:sod_user/services/auth.service.dart';
import 'package:sod_user/services/camera.service.dart';
import 'package:sod_user/services/cart.service.dart';
import 'package:sod_user/services/cart_ui.service.dart';
import 'package:sod_user/services/chat.service.dart';
import 'package:sod_user/utils/translate_for_flavor.utils.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/cart.vm.dart';
import 'package:sod_user/view_models/checkout_base.vm.dart';
import 'package:sod_user/views/pages/chat/chat_detail.page.dart';
import 'package:sod_user/views/pages/checkout/widgets/payment_methods.view.dart';
import 'package:sod_user/widgets/bottomsheets/driver_rating.bottomsheet.dart';
import 'package:sod_user/widgets/bottomsheets/order_cancellation.bottomsheet.dart';
import 'package:sod_user/widgets/bottomsheets/receive_behalf_complaint_dialog.dart';
import 'package:sod_user/widgets/bottomsheets/vendor_rating.bottomsheet.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/services/firebase.service.dart';

class OrderDetailsViewModel extends CheckoutBaseViewModel {
  //
  Order order;
  OrderRequest orderRequest = OrderRequest();
  List<File> photos = [];
  TextEditingController complaintController = TextEditingController();
  List<XFile> selectedImages = [];
  List<Option> selectedProductOptions = [];
  List<int> selectedProductOptionsIDs = [];
  final cart = Cart();
  List<Cart> cartItems = [];
  CartViewModel cartVM =
      CartViewModel(AppService().navigatorKey.currentContext!);
  //
  OrderDetailsViewModel(BuildContext context, this.order) {
    this.viewContext = context;
  }

  initialise() {
    fetchOrderDetails();
    fetchPaymentOptions();
  }

  Future<void> releaseReOrder() async {
    int index = -1;
    cartItems.forEach((c) {
      index = 0;
      cartItems.removeAt(index);
      index = index + 1;
    });
  }

  Future<void> showInReorderPage() async {
    order.orderProducts?.forEach((p) async {
      cart.price =
          p.product!.showDiscount ? p.product?.sellPrice : p.product?.price;
      cart.product = p.product;
      cart.selectedQty = p.product!.selectedQty;
      print(
          "Information Reorder ${cart.price}, ${cart.product}, ${cart.selectedQty}");
      bool canShowInReorder = await CartUIServices.handleCartEntry(
          viewContext, cart, p.product as Product);
      if (canShowInReorder) {
        cartItems.add(cart);
        await CartServices.addToCart(cart);
        print("Show products in the cart Successfully");
      } else {
        print("Error when showing the product in the cart");
      }
    });
  }

  void callVendor() {
    launchUrlString("tel:${order.vendor?.phone}");
  }

  void callDriver() {
    launchUrlString("tel:${order.driver?.user.rawPhone}");
  }

  void callRecipient() {
    launchUrlString("tel:${order.recipientPhone}");
  }

  chatVendor() {
    openChat(order.vendor?.id);
    return;
    
    // Old chat
    // Map<String, PeerUser> peers = {
    //   '${order.userId}': PeerUser(
    //     id: '${order.userId}',
    //     name: order.user.name,
    //     image: order.user.photo,
    //   ),
    //   'vendor_${order.vendor?.id}': PeerUser(
    //     id: "vendor_${order.vendor?.id}",
    //     name: order.vendor?.name ?? "",
    //     image: order.vendor?.logo,
    //   ),
    // };
    // //
    // final chatEntity = ChatEntity(
    //   onMessageSent: ChatService.sendChatMessage,
    //   mainUser: peers['${order.userId}']!,
    //   peers: peers,
    //   //don't translate this
    //   path: 'orders/' + order.code + "/customerVendor/chats",
    //   title: "Chat with vendor".tr(),
    //   supportMedia: AppUISettings.canCustomerChatSupportMedia,
    // );
    // //
    // Navigator.of(viewContext).pushNamed(
    //   AppRoutes.chatRoute,
    //   arguments: chatEntity,
    // );
  }

  chatDriver() {
    openChat(order.driver?.id);
    return;
    
    // Old chat
    // Map<String, PeerUser> peers = {
    //   '${order.userId}': PeerUser(
    //     id: '${order.userId}',
    //     name: order.user.name,
    //     image: order.user.photo,
    //   ),
    //   '${order.driver?.id}': PeerUser(
    //       id: "${order.driver?.id}",
    //       name: order.driver?.name ?? "Driver".tr(),
    //       image: order.driver?.photo),
    // };
    // //
    // final chatEntity = ChatEntity(
    //   mainUser: peers['${order.userId}']!,
    //   peers: peers,
    //   //don't translate this
    //   path: 'orders/' + order.code + "/customerDriver/chats",
    //   title: TranslateUtils.getTranslateForFlavor("Chat with driver").tr(),
    //   onMessageSent: ChatService.sendChatMessage,
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

    final currentUser = await AuthServices.getCurrentUser();
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

  void fetchOrderDetails() async {
    refreshController.refreshCompleted();
    setBusy(true);
    try {
      order = await orderRequest.getOrderDetails(id: order.id);
      clearErrors();
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      viewContext.showToast(
        msg: "$error",
        bgColor: Colors.red,
      );
    }
    notifyListeners();
    setBusy(false);
  }

  refreshDataSet() {
    fetchOrderDetails();
  }

  //
  rateVendor() async {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      builder: (context) {
        return VendorRatingBottomSheet(
          order: order,
          onSubmitted: () {
            //
            Navigator.pop(viewContext);
            fetchOrderDetails();
          },
        );
      },
    );
  }

  //
  rateDriver() async {
    await Navigator.push(
      viewContext,
      MaterialPageRoute(
        builder: (context) => DriverRatingBottomSheet(
          order: order,
          onSubmitted: () {
            //
            Navigator.pop(viewContext);
            fetchOrderDetails();
          },
        ),
      ),
    );
  }

  //
  trackOrder() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.orderTrackingRoute,
      arguments: order,
    );
  }

  cancelOrder() async {
    showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      builder: (context) {
        return OrderCancellationBottomSheet(
          order: order,
          onSubmit: (String reason) {
            Navigator.pop(viewContext);
            processOrderCancellation(reason);
          },
        );
      },
    );
  }

  openImagePickerBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Card(
            child: HStack(
          [
            VxBox(
              child: InkWell(
                onTap: () async {
                  await pickImagePhotoByGallery();
                  Navigator.pop(context);
                },
                child: HStack(
                  [
                    VxBox().height(context.mq.size.height / 24).make(),
                    const Icon(Icons.image),
                    VxBox().height(12).make(),
                    const Text(
                      "Gallery",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    )
                  ],
                  alignment: MainAxisAlignment.center,
                ).w(context.mq.size.width * 0.3),
              ),
            ).width(context.mq.size.width * 0.3).make(),
            VxBox(
              child: InkWell(
                onTap: () async {
                  await pickImageByCamera();
                  Navigator.pop(context);
                },
                child: HStack(
                  [
                    VxBox().height(context.mq.size.height / 24).make(),
                    const Icon(Icons.camera),
                    VxBox().height(12).make(),
                    const Text(
                      "Camera",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    )
                  ],
                  alignment: MainAxisAlignment.center,
                ).w(context.mq.size.width * 0.3),
              ),
            ).width(context.mq.size.width * 0.3).make()
          ],
          alignment: MainAxisAlignment.center,
        ).w(context.mq.size.width * 0.8).h(context.mq.size.height / 5));
      },
    );
  }

  pickImageByCamera() async {
    bool permission = await CameraService.permissionRequest();
    if (permission) {
      XFile? selectedCameraImages =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (selectedCameraImages != null) {
        selectedImages = [];
        selectedImages.add(selectedCameraImages);
      }
      processOrderCompletion();
    }
  }

  pickImagePhotoByGallery() async {
    selectedImages = await ImagePicker().pickMultiImage();
    processOrderCompletion();
  }

  void processOrderCompletion() async {
    setBusyForObject(order, true);
    try {
      if (selectedImages.isNotEmpty) {
        photos = selectedImages.map((e) => File(e.path)).toList();
        Map<String, dynamic> postBody = {
          "_method": "PUT",
          "status": "completed",
        };
        FormData formData = FormData.fromMap(postBody);
        for (File? file in photos) {
          final fileSize = file!.lengthSync() / 1024;
          if (fileSize > AppFileLimit.prescriptionFileSizeLimit) {
            file = await Utils.compressFile(file: file, quality: 60);
          }
          formData.files.add(
            MapEntry("receive_confirm_photos[]",
                await MultipartFile.fromFile(file!.path)),
          );
        }
        final responseMessage = await orderRequest.updateOrderWithFiles(
            id: order.id, body: formData);
        //
        //message
        viewContext.showToast(
          msg: responseMessage,
          bgColor: Colors.green,
          textColor: Colors.white,
        );
      }
      clearErrors();
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      viewContext.showToast(
        msg: "$error",
        bgColor: Colors.red,
        textColor: Colors.white,
      );
    }
    setBusyForObject(order, false);
    fetchOrderDetails();
  }

  //
  processOrderCancellation(String reason) async {
    setBusyForObject(order, true);
    try {
      final responseMessage = await orderRequest.updateOrder(
        id: order.id,
        status: "cancelled",
        reason: reason,
      );
      //
      order.status = "cancelled";
      //message
      viewContext.showToast(
        msg: responseMessage,
        bgColor: Colors.green,
        textColor: Colors.white,
      );

      clearErrors();
    } catch (error) {
      print("Error ==> $error");
      setError(error);
      viewContext.showToast(
        msg: "$error",
        bgColor: Colors.red,
        textColor: Colors.white,
      );
    }
    setBusyForObject(order, false);
  }

  void showVerificationQRCode() async {
    showDialog(
      context: viewContext,
      builder: (context) {
        return Dialog(
          child: VStack(
            [
              QrImage(
                data: order.verificationCode,
                version: QrVersions.max,
                size: viewContext.percentWidth * 40,
              ).box.makeCentered(),
              "${order.verificationCode}".text.medium.xl2.makeCentered().py4(),
              "Verification Code".tr().text.light.sm.makeCentered().py8(),
            ],
          ).p20(),
        );
      },
    );
  }

  void shareOrderDetails() async {
    Share.share(
        "%s is sharing an order code with you. Track order with this code: %s"
            .tr()
            .fill(
      [
        order.user.name,
        order.code,
      ],
    ));
  }

  openPaymentMethodSelection() async {
    //
    setBusyForObject(order.paymentStatus, true);
    await fetchPaymentOptions(vendorId: order.vendorId);
    setBusyForObject(order.paymentStatus, false);
    await showModalBottomSheet(
      context: viewContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (contex) {
        return PaymentMethodsView(this)
            .p20()
            .scrollVertical()
            .box
            .color(contex.theme.colorScheme.surface)
            .topRounded()
            .make();
      },
    );
  }

  changeSelectedPaymentMethod(PaymentMethod? paymentMethod,
      {bool callTotal = true}) async {
    //
    Navigator.pop(viewContext);
    setBusyForObject(order.paymentStatus, true);
    try {
      //
      ApiResponse apiResponse = await orderRequest.updateOrderPaymentMethod(
        id: order.id,
        paymentMethodId: paymentMethod?.id,
        status: "pending",
      );

      //
      order = Order.fromJson(apiResponse.body["order"]);
      if (!["wallet", "cash"].contains(paymentMethod?.slug)) {
        if (paymentMethod?.slug == "offline") {
          openExternalWebpageLink(order.paymentLink);
        } else {
          openWebpageLink(order.paymentLink);
        }
      } else {
        toastSuccessful("${apiResponse.body['message']}");
      }

      //notify wallet view to update, just incase wallet was use for payment
      AppService().refreshWalletBalance.add(true);
    } catch (error) {
      toastError("$error");
    }
    setBusyForObject(order.paymentStatus, false);
  }

  addComplaintDialog() async {
    final mDeliveryAddress = await showModalBottomSheet(
      context: viewContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ReceiveBehalfComplaintDialog(
          controller: complaintController,
          onConfirm: () async {
            setBusyForObject(order, true);
            try {
              final responseMessage =
                  await orderRequest.addReceiveBehalfComplaint(
                id: order.receiveBehalfOrder!.id,
                complaint: complaintController.text,
              );
              //message
              viewContext.showToast(
                msg: responseMessage,
                bgColor: Colors.green,
                textColor: Colors.white,
              );
              clearErrors();
              Navigator.pop(viewContext);
              fetchOrderDetails();
            } catch (error) {
              print("Error ==> $error");
              setError(error);
              viewContext.showToast(
                msg: "$error",
                bgColor: Colors.red,
                textColor: Colors.white,
              );
            }
            setBusyForObject(order, false);
          },
        );
      },
    );
    return mDeliveryAddress;
  }
}
