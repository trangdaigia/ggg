import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_text_styles.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/utils/utils.dart';
import 'package:sod_user/views/shared/go_to_cart.view.dart';
import 'package:sod_user/widgets/cart_page_action.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:measure_size/measure_size.dart';
import 'package:velocity_x/velocity_x.dart';

class BasePage extends StatefulWidget {
  final bool showAppBar;
  final bool showLeadingAction;
  final bool? extendBodyBehindAppBar;
  final Function? onBackPressed;
  final bool showCart;
  final dynamic title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget body;
  final Widget? bottomSheet;
  final Widget? bottomNavigationBar;
  final Widget? fab;
  final FloatingActionButtonLocation? fabLocation;
  final bool isLoading;
  final Color? appBarColor;
  final double? elevation;
  final Color? appBarItemColor;
  final Color? backgroundColor;
  final void Function(String query)? onSearchChange;
  final bool showCartView;
  final PreferredSize? customAppbar;
  final bool resizeToAvoidBottomInset;
  final bool isSearch;
  final bool isIconNotifi;
  final bool isIconMessage;
  final bool isBlackColorBackArrow;
  BasePage({
    this.showAppBar = false,
    this.leading,
    this.showLeadingAction = false,
    this.onBackPressed,
    this.showCart = false,
    this.title = "",
    this.actions,
    required this.body,
    this.bottomSheet,
    this.bottomNavigationBar,
    this.fab,
    this.fabLocation,
    this.isLoading = false,
    this.appBarColor,
    this.appBarItemColor,
    this.backgroundColor,
    this.elevation,
    this.extendBodyBehindAppBar,
    this.showCartView = false,
    this.customAppbar,
    this.resizeToAvoidBottomInset = false,
    this.isSearch = false,
    this.isIconNotifi = false,
    this.isIconMessage = false,
    this.isBlackColorBackArrow = false,
    Key? key, this.onSearchChange,
  }) : super(key: key);

  @override
  _BasePageState createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> {
  //
  double bottomPaddingSize = 0;

  //
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: translator.activeLocale.languageCode == "ar"
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: KeyboardDismisser(
        child: Scaffold(
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          backgroundColor: widget.backgroundColor ?? AppColor.faintBgColor,
          extendBodyBehindAppBar: widget.extendBodyBehindAppBar ?? false,
          appBar: widget.customAppbar != null
              ? widget.customAppbar
              : widget.showAppBar
                  ? AppBar(
                      centerTitle: true,
                      backgroundColor: widget.appBarColor ??
                          context.theme.colorScheme
                              .surface, //context.primaryColor,
                      elevation: widget.elevation,
                      automaticallyImplyLeading: widget.showLeadingAction,
                      leading: widget.showLeadingAction
                          ? widget.leading == null
                              ? IconButton(
                                  icon: Icon(
                                    !Utils.isArabic
                                        ? FlutterIcons.arrow_left_fea
                                        : FlutterIcons.arrow_right_fea,
                                    color: widget.isBlackColorBackArrow
                                        ? Colors.black
                                        : (widget.appBarItemColor ??
                                            Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color),
                                  ),
                                  onPressed: widget.onBackPressed != null
                                      ? () => widget.onBackPressed!()
                                      : () => Navigator.pop(context),
                                )
                              : widget.leading
                          : null,
                      title: widget.title is Widget
                          ? widget.title
                          : widget.isSearch
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: TextField(
                                          onChanged: widget.onSearchChange ?? (String a) {},
                                          decoration: InputDecoration(
                                            hintText: widget.title,
                                            border: InputBorder.none,
                                            hintStyle:
                                                TextStyle(color: Colors.grey),
                                            prefixIcon: Icon(Icons.search,
                                                color: Colors.grey, size: 20),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : "${widget.title}"
                                  .text
                                  .textStyle(AppTextStyle.h3TitleTextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color!))
                                  .maxLines(1)
                                  .overflow(TextOverflow.ellipsis)
                                  .color(Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color)
                                  .make(),
                      actions: widget.actions ??
                          <Widget>[
                            if (widget.showCart)
                              PageCartAction()
                            else
                              UiSpacer.emptySpace(),
                            if (widget.isIconNotifi)
                              Icon(Icons.notifications, color: Colors.black).pSymmetric(h: 15),
                            if (widget.isIconMessage)
                              Icon(Icons.message, color: Colors.black).pOnly(right: 10),
                          ],
                    )
                  : null,
          body: Stack(
            children: [
              //body
              VStack(
                [
                  //
                  widget.isLoading
                      ? LinearProgressIndicator()
                      : UiSpacer.emptySpace(),

                  //
                  widget.body.pOnly(bottom: bottomPaddingSize).expand(),
                ],
              ),

              //cart view
              Align(
                alignment: Alignment.bottomCenter,
                child: Visibility(
                  visible: widget.showCartView,
                  child: MeasureSize(
                    onChange: (size) {
                      setState(() {
                        bottomPaddingSize = size.height;
                      });
                    },
                    child: GoToCartView(),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: widget.bottomNavigationBar,
          bottomSheet: widget.bottomSheet,
          floatingActionButton: widget.fab,
          floatingActionButtonLocation: widget.fabLocation,
        ),
      ),
    );
  }
}
