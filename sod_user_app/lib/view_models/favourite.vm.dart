import 'package:flutter/material.dart';
import 'package:sod_user/models/product.dart';
import 'package:sod_user/requests/favourite.request.dart';
import 'package:sod_user/view_models/base.view_model.dart';

class FavouriteViewModel extends MyBaseViewModel {
  //
  FavouriteRequest favouriteRequest = FavouriteRequest();
  Product product;

  //
  FavouriteViewModel(BuildContext context, this.product) {
    this.viewContext = context;
  }

  //
  removeFavourite() async {
    setBusy(true);
    //
    final apiResponse = await favouriteRequest.removeFavourite(
      product.id,
    );

    //remove from list
    if (apiResponse.allGood) {
      product.isFavourite = false;
    } else {
      toastError("${apiResponse.message}");
    }

    setBusy(false);
  }

  //
  addFavourite() async {
    setBusy(true);
    //
    final apiResponse = await favouriteRequest.makeFavourite(
      product.id,
    );

    //remove from list
    if (apiResponse.allGood) {
      product.isFavourite = true;
    } else {
      toastError("${apiResponse.message}");
    }

    setBusy(false);
  }
}
