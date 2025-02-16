import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:sod_vendor/constants/app_routes.dart';
import 'package:sod_vendor/models/product.dart';
import 'package:sod_vendor/requests/product.request.dart';
import 'package:sod_vendor/view_models/base.view_model.dart';
import 'package:sod_vendor/views/pages/product/edit_product.page.dart';
import 'package:sod_vendor/views/pages/product/new_product.page.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class ProductViewModel extends MyBaseViewModel {
  //
  ProductViewModel(BuildContext context) {
    this.viewContext = context;
  }

  //
  ProductRequest productRequest = ProductRequest();
  List<Product> products = [];
  //
  int queryPage = 1;
  String keyword = "";
  RefreshController refreshController = RefreshController();

  void initialise() {
    fetchMyProducts();
  }

  //
  fetchMyProducts({bool initialLoading = true}) async {
    if (initialLoading) {
      setBusy(true);
      refreshController.refreshCompleted();
      queryPage = 1;
    } else {
      queryPage++;
    }

    try {
      final mProducts = await productRequest.getProducts(
        page: queryPage,
        keyword: keyword,
        forceRefresh: true,
      );
      if (!initialLoading) {
        products.addAll(mProducts);
        refreshController.loadComplete();
      } else {
        products = mProducts;
      }
      clearErrors();
    } catch (error) {
      print("Product Error ==> $error");
      setError(error);
    }

    setBusy(false);
  }

  //
  productSearch(String value) {
    keyword = value;
    fetchMyProducts();
  }

  //
  openProductDetails(Product product) {
    Navigator.of(viewContext).pushNamed(
      AppRoutes.productDetailsRoute,
      arguments: product,
    );
  }

  void newProduct() async {
    final result = await Navigator.of(viewContext).push(
      MaterialPageRoute(
        builder: (context) => NewProductPage(),
      ),
    );
    //
    if (result != null) {
      fetchMyProducts();
    }
  }

  editProduct(Product product) async {
    //
    final result = await Navigator.push(
      viewContext,
      MaterialPageRoute(builder: (context) => EditProductPage(product)),
    );
    if (result != null) {
      fetchMyProducts();
    }
  }

  changeProductStatus(Product product) {
    //
    CoolAlert.show(
      context: viewContext,
      type: CoolAlertType.confirm,
      title: "Status Update".tr(),
      text: "Are you sure you want to".tr() +
          " ${(product.isActive != 1 ? "Activate" : "Deactivate").tr()} ${product.name}?",
      onConfirmBtnTap: () {
        processStatusUpdate(product);
      },
    );
  }

  processStatusUpdate(Product product) async {
    //
    product.isActive = product.isActive == 1 ? 0 : 1;
    //
    setBusyForObject(product.id, true);
    try {
      final apiResponse = await productRequest.updateDetails(
        product,
      );
      //
      if (apiResponse.allGood) {
        fetchMyProducts();
      }
      //show dialog to present state
      CoolAlert.show(
        context: viewContext,
        type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
        title: "Status Update".tr(),
        text: apiResponse.message,
      );
      clearErrors();
    } catch (error) {
      print("Update Status Package Type Pricing Error ==> $error");
      setError(error);
    }
    setBusyForObject(product.id, false);
  }
  //

  deleteProduct(Product product) {
    //
    CoolAlert.show(
      context: viewContext,
      type: CoolAlertType.confirm,
      title: "Delete Product".tr(),
      text: "Are you sure you want to delete".tr() + " ${product.name}?",
      onConfirmBtnTap: () {
        processDeletion(product);
      },
    );
  }

  processDeletion(Product product) async {
    //
    setBusyForObject(product.id, true);
    try {
      final apiResponse = await productRequest.deleteProduct(
        product,
      );
      //
      if (apiResponse.allGood) {
        products.removeWhere((element) => element.id == product.id);
      }
      //show dialog to present state
      CoolAlert.show(
        context: viewContext,
        type: apiResponse.allGood ? CoolAlertType.success : CoolAlertType.error,
        title: "Delete Product".tr(),
        text: apiResponse.message,
      );
      clearErrors();
    } catch (error) {
      print("delete product Error ==> $error");
      setError(error);
    }
    setBusyForObject(product.id, false);
  }
}
