import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/view_models/home.vm.dart';
import 'package:velocity_x/velocity_x.dart';

class WalletHomeFab extends StatelessWidget {
  const WalletHomeFab(this.model, {Key? key}) : super(key: key);

  final HomeViewModel model;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        backgroundColor: AppColor.primaryColorDark,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onPressed: model.openWallet,
        child: Icon(
          Icons.wallet_rounded,
          color: Colors.white,
        ));
  }
}
