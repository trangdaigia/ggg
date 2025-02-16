import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/widgets/list_items/real_estate_overlay_filter.list_time.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstateFilterOverlay extends StatefulWidget {
  final List<RealEstateFilterOverlayListItem<dynamic>> filterOptions;
  final void Function() onApplyFilters;
  final String? title;
  final GlobalKey<RealEstateFilterOverlayState>? key;

  const RealEstateFilterOverlay({
    this.key,
    required this.filterOptions,
    required this.onApplyFilters,
    this.title,
  }) : super(key: key);

  @override
  RealEstateFilterOverlayState createState() => RealEstateFilterOverlayState();
}

class RealEstateFilterOverlayState extends State<RealEstateFilterOverlay> {
  OverlayEntry? _overlayEntry;
  void showOverlay(BuildContext context) {
    if (_overlayEntry == null) {
      _overlayEntry = _createOverlayEntry(context);
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  void hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry(BuildContext context) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: hideOverlay,
            child: Container(
              color: Colors.black38, // Dim background
            ),
          ),
          Positioned(
            top: 100.0,
            left: 20.0,
            right: 20.0,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.only(top: 16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: VStack(
                  [
                    'Filter Options'.tr().text.bold.xl.makeCentered(),
                    10.heightBox,
                    SingleChildScrollView(
                      child: VStack([...widget.filterOptions]).px8(),
                    ).h64(context),
                    10.heightBox,
                    TextButton(
                            onPressed: () {
                              widget.onApplyFilters();
                            },
                            child: "Apply"
                                .tr()
                                .text
                                .xl
                                .bold
                                .color(AppColor.inputFillColor)
                                .makeCentered())
                        .h8(context)
                        .wFull(context)
                        .backgroundColor(AppColor.primaryColor),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => showOverlay(context),
      child: const Icon(Icons.filter_list),
    );
  }
}
