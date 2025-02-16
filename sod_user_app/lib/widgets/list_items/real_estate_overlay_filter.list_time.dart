import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstateFilterOverlayListItem<T> extends StatefulWidget {
  final List<T> options;
  final T? selectedOption;
  final bool multiSelect;
  final String title;
  final void Function(T?) onChange;
  final String Function(T) tranformOption;

  final Duration animationDuration;

  const RealEstateFilterOverlayListItem(
      {super.key,
      required this.options,
      this.selectedOption,
      this.multiSelect = false,
      required this.tranformOption,
      required this.animationDuration,
      required this.title,
      required this.onChange});

  @override
  State<RealEstateFilterOverlayListItem<T>> createState() =>
      _RealEstateFilterOverlayListItemState<T>();
}

class _RealEstateFilterOverlayListItemState<T>
    extends State<RealEstateFilterOverlayListItem<T>> {
  T? selectedOption = null;

  final GlobalKey _wrapKey = GlobalKey();
  double _wrapHeight = 0.0;

  void _calculateWrapHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBox =
          _wrapKey.currentContext!.findRenderObject() as RenderBox;
      setState(() {
        _wrapHeight = renderBox.size.height;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _calculateWrapHeight();
    selectedOption = widget.selectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return
        // Actual collapsible drawer
        Container(
      height: _wrapHeight == 0.0 ?(widget.options.length / 4).ceil() * 100 : _wrapHeight,
      key: _wrapKey,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          const Divider(color: Colors.white),
          // Content
          Expanded(
              child: VStack([
            HStack(
              [
                "${widget.title.tr()}:".text.bold.xl.make(),
              ],
            ).wFull(context),
            Wrap(
              children: [
                ...widget.options
                    .map((option) => TextButton(
                        onPressed: () {
                          setState(() {
                            if (selectedOption == option)
                              selectedOption == null;
                            else
                              selectedOption = option;
                          });
                          widget.onChange(option);
                        },
                        style: ButtonStyle(
                            backgroundColor: selectedOption == option
                                ? WidgetStateProperty.all(
                                    AppColor.primaryColor.withOpacity(0.1))
                                : WidgetStateProperty.all(
                                    AppColor.faintBgColor)),
                        child: widget
                            .tranformOption(option)
                            .tr()
                            .text
                            .color(selectedOption == option
                                ? AppColor.primaryColorDark
                                : Colors.black)
                            .normal
                            .make()))
                    .toList()
              ],
              spacing: 10,
            ).px8()
          ])),
        ],
      ),
    ).wFull(context);
  }
}
