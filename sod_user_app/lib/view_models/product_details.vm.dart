import 'package:cool_alert/cool_alert.dart';
import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_routes.dart';
import 'package:sod_user/extensions/dynamic.dart';
import 'package:sod_user/models/cart.dart';
import 'package:sod_user/models/option.dart';
import 'package:sod_user/models/option_group.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/requests/favourite.request.dart';
import 'package:sod_user/requests/product.request.dart';
import 'package:sod_user/services/alert.service.dart';
import 'package:sod_user/services/cart.service.dart';
import 'package:sod_user/services/cart_ui.service.dart';
import 'package:sod_user/view_models/base.view_model.dart';
import 'package:sod_user/views/pages/cart/cart.page.dart';
import 'package:sod_user/views/pages/vendor_details/vendor_details.page.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:http/http.dart' as http;

class ProductDetailsViewModel extends MyBaseViewModel {
  //
  ProductDetailsViewModel(BuildContext context, this.product) {
    this.viewContext = context;
    updatedSelectedQty(1);
  }

  //view related
  final productReviewsKey = new GlobalKey();
  //
  ProductRequest _productRequest = ProductRequest();
  FavouriteRequest _favouriteRequest = FavouriteRequest();
  RefreshController refreshController = RefreshController();

  //
  Product product;
  List<Option> selectedProductOptions = [];
  List<int> selectedProductOptionsIDs = [];
  double subTotal = 0.0;
  double total = 0.0;
  final currencySymbol = AppStrings.currencySymbol;
  List<String>? checkedPhotos;

  //
  void getProductDetails() async {
    //
    setBusyForObject(product, true);

    try {
      final oldProductHeroTag = product.heroTag;
      product = await _productRequest.productDetails(product.id);
      product.heroTag = oldProductHeroTag;

      clearErrors();
      calculateTotal();

      // kiểm tra ảnh sản phẩm có hợp lệ hay không để hiển thị
      for (String photo in product.photos) {
        bool isValid = await checkProductImages(photo);
        if (isValid) {
          if (checkedPhotos == null) {
            checkedPhotos = [];
          }
          checkedPhotos!.add(photo);
          notifyListeners();
        }
      }

      // khởi tạo để cập nhật UI khi không có ảnh nào hợp lệ
      if (checkedPhotos == null) {
        checkedPhotos = [];
      } 
    } catch (error) {
      setError(error);
      toastError("$error");
    }
    setBusyForObject(product, false);
  }

  openVendorDetails() {
    viewContext.nextPage(
      VendorDetailsPage(
        vendor: product.vendor,
      ),
    );
  }

  //
  isOptionSelected(Option option) {
    return selectedProductOptionsIDs.contains(option.id);
  }

  //
  toggleOptionSelection(OptionGroup optionGroup, Option option) {
    //
    if (selectedProductOptionsIDs.contains(option.id)) {
      selectedProductOptionsIDs.remove(option.id);
      selectedProductOptions.remove(option);
    } else {
      //if it allows only one selection
      if (optionGroup.multiple == 0) {
        //
        final foundOption = selectedProductOptions.firstOrNullWhere(
          (option) => option.optionGroupId == optionGroup.id,
        );
        selectedProductOptionsIDs.remove(foundOption?.id);
        selectedProductOptions.remove(foundOption);
      }
      //prevent selecting more than the max allowed
      if (optionGroup.maxOptions != null) {
        int selectedOptionsForGroup = selectedProductOptions
            .where((e) => e.optionGroupId == optionGroup.id)
            .length;
        if (selectedOptionsForGroup >= optionGroup.maxOptions!) {
          String errorMsg = "You can only select".tr();
          errorMsg += " ${optionGroup.maxOptions} ";
          errorMsg += "options for".tr();
          errorMsg += " ${optionGroup.name}";
          AlertService.error(text: errorMsg);
          return;
        }
      }

      selectedProductOptionsIDs.add(option.id);
      selectedProductOptions.add(option);
    }

    //
    calculateTotal();
  }

  //
  updatedSelectedQty(int qty) async {
    product.selectedQty = qty;
    calculateTotal();
  }

  //
  calculateTotal() {
    //
    double productPrice =
        !product.showDiscount ? product.price : product.discountPrice;

    //
    double totalOptionPrice = 0.0;
    selectedProductOptions.forEach((option) {
      totalOptionPrice += option.price;
    });

    //
    if (product.plusOption == 1 || selectedProductOptions.isEmpty) {
      subTotal = productPrice + totalOptionPrice;
    } else {
      subTotal = totalOptionPrice;
    }
    total = subTotal * (product.selectedQty);
    notifyListeners();
  }

  //
  addToFavourite() async {
    //
    setBusy(true);

    try {
      //
      final apiResponse = await _favouriteRequest.makeFavourite(product.id);
      if (apiResponse.allGood) {
        //
        product.isFavourite = true;

        //
        AlertService.success(text: apiResponse.message);
      } else {
        viewContext.showToast(
          msg: "${apiResponse.message}",
          bgColor: Colors.red,
          textColor: Colors.white,
          position: VxToastPosition.top,
        );
      }
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  removeFromFavourite() async {
    //
    setBusy(true);

    try {
      //
      final apiResponse = await _favouriteRequest.removeFavourite(product.id);
      if (apiResponse.allGood) {
        //
        product.isFavourite = false;
        //
        AlertService.success(text: apiResponse.message);
      } else {
        viewContext.showToast(
          msg: "${apiResponse.message}",
          bgColor: Colors.red,
          textColor: Colors.white,
          position: VxToastPosition.top,
        );
      }
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  //check if the option groups with required setting has an option selected
  optionGroupRequirementCheck() {
    //check if the option groups with required setting has an option selected
    bool optionGroupRequiredFail = false;
    OptionGroup? optionGroupRequired;
    //
    for (var optionGroup in product.optionGroups) {
      //
      optionGroupRequired = optionGroup;
      //
      final selectedOptionInOptionGroup =
          selectedProductOptions.firstOrNullWhere(
        (e) => e.optionGroupId == optionGroup.id,
      );

      //check if there is an option group that is required but customer is yet to select an option
      if (optionGroup.required == 1 && selectedOptionInOptionGroup == null) {
        optionGroupRequiredFail = true;
        break;
      }
    }

    //
    if (optionGroupRequiredFail) {
      //
      CoolAlert.show(
        context: viewContext,
        title: "Option required".tr(),
        text: "You are required to select at least one option of".tr() +
            " ${optionGroupRequired?.name}",
        type: CoolAlertType.error,
      );

      throw "Option required".tr();
    }
  }

  //
  Future<bool> addToCart({bool force = false, bool skip = false}) async {
    final cart = Cart();
    cart.price = subTotal;
    cart.product = product;
    cart.selectedQty = product.selectedQty;
    cart.options = selectedProductOptions;
    cart.optionsIds = selectedProductOptionsIDs;
    bool done = false;
    //

    try {
      //check if the option groups with required setting has an option selected
      optionGroupRequirementCheck();
      //
      setBusy(true);
      bool canAddToCart = await CartUIServices.handleCartEntry(
        viewContext,
        cart,
        product,
      );

      if (canAddToCart || force) {
        //
        await CartServices.addToCart(cart);
        //
        if (!skip) {
          done = await CoolAlert.show(
            context: viewContext,
            title: "Add to cart".tr(),
            text: "%s Added to cart".tr().fill([product.name]),
            type: CoolAlertType.success,
            showCancelBtn: true,
            confirmBtnColor: AppColor.primaryColor,
            confirmBtnText: "GO TO CART".tr(),
            confirmBtnTextStyle: viewContext.textTheme.bodyLarge?.copyWith(
              fontSize: Vx.dp12,
              color: Colors.white,
            ),
            closeOnConfirmBtnTap: false,
            onConfirmBtnTap: () async {
              //
              Navigator.pop(viewContext, true);
              viewContext.nextPage(CartPage());
            },
            cancelBtnText: "Keep Shopping".tr(),
            cancelBtnTextStyle:
                viewContext.textTheme.bodyLarge?.copyWith(fontSize: Vx.dp12),
          );
        }
      } else if (product.isDigital) {
        //
        CoolAlert.show(
          context: viewContext,
          title: "Digital Product".tr(),
          text:
              "You can only buy/purchase digital products together with other digital products. Do you want to clear cart and add this product?"
                  .tr(),
          type: CoolAlertType.confirm,
          closeOnConfirmBtnTap: false,
          onConfirmBtnTap: () async {
            //
            Navigator.pop(viewContext);
            await CartServices.clearCart();
            addToCart(force: true);
          },
        );
      } else {
        //
        done = await CoolAlert.show(
          context: viewContext,
          title: "Different Vendor".tr(),
          text:
              "Are you sure you'd like to change vendors? Your current items in cart will be lost."
                  .tr(),
          type: CoolAlertType.confirm,
          closeOnConfirmBtnTap: false,
          onConfirmBtnTap: () async {
            //
            Navigator.pop(viewContext);
            await CartServices.clearCart();
            addToCart(force: true);
          },
        );
      }
    } catch (error) {
      print("Cart Error => $error");
      setError(error);
    }
    setBusy(false);
    return done;
  }

  //
  void openVendorPage() {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.vendorDetails,
      arguments: product.vendor,
    );
  }

  buyNow() async {
    try {
      //check if the option groups with required setting has an option selected
      optionGroupRequirementCheck();
      await addToCart(skip: true);
      Navigator.pop(viewContext);
      viewContext.nextPage(CartPage());
    } catch (error) {
      toastError("$error");
    }
  }

  // Kiểm tra hình ảnh sản phẩm có hợp lệ hay không
  Future<bool> checkProductImages(String photoToCheck) async {
    final response = await http.head(Uri.parse(photoToCheck));
    if (response.statusCode == 200) return true;
    return false;
  }
}
