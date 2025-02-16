import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/constants/app_text_styles.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:localize_and_translate/localize_and_translate.dart';

import 'package:velocity_x/velocity_x.dart';

class BasePage extends StatefulWidget {
  final bool showAppBar;
  final bool showLeadingAction;
  final IconData? leadingIconData;
  final Widget? leading;
  final bool showCart;
  final bool extendBodyBehindAppBar;
  final Function? onBackPressed;
  final String title;
  final Widget body;
  final Widget? bottomSheet;
  final Widget? bottomNavigationBar;
  final Widget? fab;
  final bool isLoading;
  final List<Widget>? actions;

  final Color? appBarItemColor;
  final Color? backgroundColor;
  final double? elevation;

  BasePage({
    this.showAppBar = false,
    this.showLeadingAction = false,
    this.leadingIconData,
    this.leading,
    this.extendBodyBehindAppBar = false,
    this.showCart = false,
    this.onBackPressed,
    this.title = "",
    required this.body,
    this.bottomSheet,
    this.bottomNavigationBar,
    this.fab,
    this.isLoading = false,
    this.actions,
    this.elevation,
    this.appBarItemColor,
    this.backgroundColor,
    Key? key,
  }) : super(key: key);

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: translator.activeLocale.languageCode == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
        resizeToAvoidBottomInset: false,
        backgroundColor: widget.backgroundColor ?? AppColor.onboarding3Color,
        appBar: widget.showAppBar
            ? AppBar(
                centerTitle: true,
                backgroundColor: AppColor.onboarding3Color,
                automaticallyImplyLeading: widget.showLeadingAction,
                elevation: widget.elevation,
                leading: widget.showLeadingAction
                    ? widget.leading == null
                        ? IconButton(
                            icon: Icon(
                              widget.leadingIconData ??
                                  FlutterIcons.arrow_left_fea,
                            ),
                            onPressed: widget.onBackPressed != null
                                ? () => widget.onBackPressed!()
                                : () => Navigator.pop(context),
                          )
                        : widget.leading
                    : null,
                title: Text(
                  widget.title,
                  style: AppTextStyle.h2TitleTextStyle(),
                ),
                actions: widget.actions ?? [],
              )
            : null,
        body: VStack(
          [
            //
            widget.isLoading
                ? LinearProgressIndicator()
                : UiSpacer.emptySpace(),

            //
            widget.body.expand(),
          ],
        ),
        bottomSheet: widget.bottomSheet,
        bottomNavigationBar: widget.bottomNavigationBar,
        floatingActionButton: widget.fab,
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }
}
