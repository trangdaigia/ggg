import 'dart:async';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:sod_user/models/cart.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/services/cart.service.dart';
import 'package:sod_user/widgets/bottomsheets/age_restriction.bottomsheet.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

class CartUIServices extends CartServices {
  //
  static Future<bool> handleCartEntry(
    BuildContext context,
    Cart cart,
    Product product,
  ) async {
    bool? canAddToCart = true;
    if (product.isDigital) {
      canAddToCart = await CartServices.canAddDigitalProductToCart(cart);
    } else {
      canAddToCart = await CartServices.canAddToCart(cart);
      //check the already added product qty
      if (canAddToCart) {
        int freeQty = 0;
        bool thereIsFreeQty =
            await CartServices.cartItemQtyAvailable(cart.product!);
        if (thereIsFreeQty) {
          freeQty = await CartServices.productQtyAllowed(cart.product!);
          thereIsFreeQty = freeQty >= cart.selectedQty!;
        }
        //if there is not enough avaiable qty to process the product to cart
        if (!thereIsFreeQty) {
          //
          await CoolAlert.show(
            context: context,
            title: "Product Available".tr(),
            text:
                ("Product avaiable qty is less than your selected qty. Please reduce selected qty to:"
                        .tr() +
                    " $freeQty " +
                    "or less".tr()),
            type: CoolAlertType.warning,
          );
          throw "Product qty issue";
        }
      }
    }

    //AGE RESTRICTION check
    if (canAddToCart && product.ageRestricted) {
      //
      bool? ageVerified = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return AgeRestrictionBottomSheet();
        },
      );
      //
      if (ageVerified == null) {
        throw new Exception("Not age verified");
      }
    }
    return canAddToCart;
  }

  //verify if cart item qty can be increased
  static Future<bool> cartItemQtyUpdated(
    BuildContext context,
    int newQty,
    Cart cart,
  ) async {
    bool canAddToCart = true;
    int freeQty = await CartServices.productQtyAllowed(cart.product!);
    //if there is not enough avaiable qty to process the product to cart
    if (newQty > freeQty) {
      //
      canAddToCart = false;
      await CoolAlert.show(
        context: context,
        title: "Product Available".tr(),
        text:
            ("Product avaiable qty is less than your selected qty. Please reduce selected qty to:"
                    .tr() +
                " $freeQty " +
                "or less".tr()),
        type: CoolAlertType.warning,
      );
    }

    return canAddToCart;
  }
}
