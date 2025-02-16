import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/search.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/models/vendor_type.dart';
import 'package:sod_user/view_models/vendor/section_vendors.vm.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/food_vendor.list_item.dart';
import 'package:sod_user/widgets/list_items/horizontal_vendor.list_item.dart';
import 'package:sod_user/widgets/list_items/vendor.list_item.dart';
import 'package:sod_user/widgets/section.title.dart';
import 'package:sod_user/widgets/states/vendor.empty.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SectionVendorsView extends StatefulWidget {
  const SectionVendorsView(
    this.vendorType, {
    this.title = "",
    this.scrollDirection = Axis.vertical,
    this.type = SearchFilterType.sales,
    this.itemWidth,
    this.viewType,
    this.separator,
    this.byLocation = false,
    this.itemsPadding,
    this.titlePadding,
    this.hideEmpty = false,
    this.lstVendorType,
    Key? key,
  }) : super(key: key);
  final List<VendorType>? lstVendorType;
  final VendorType? vendorType;
  final Axis scrollDirection;
  final SearchFilterType type;
  final String title;
  final double? itemWidth;
  final dynamic viewType;
  final Widget? separator;
  final bool byLocation;
  final EdgeInsets? itemsPadding;
  final EdgeInsets? titlePadding;
  final bool hideEmpty;

  @override
  State<SectionVendorsView> createState() => _SectionVendorsViewState();
}

class _SectionVendorsViewState extends State<SectionVendorsView> {
  @override
  Widget build(BuildContext context) {
    return CustomVisibilty(
      visible: !AppStrings.enableSingleVendor,
      child: ViewModelBuilder<SectionVendorsViewModel>.reactive(
        viewModelBuilder: () => SectionVendorsViewModel(
          context,
          widget.vendorType,
          type: widget.type,
          byLocation: widget.byLocation,
        ),
        onViewModelReady: (model) => model.initialise(),
        builder: (context, model, child) {
          List<Vendor> lstVendor = [];
          if (widget.lstVendorType != null) {
            for (int i = 0; i < widget.lstVendorType!.length; i++) {
              for (int j = 0; j < model.vendors.length; j++) {
                if (widget.lstVendorType![i].name ==
                    model.vendors[j].vendorType.name) {
                  lstVendor.add(model.vendors[j]);
                }
              }
            }
            model.vendors = lstVendor;
          }
          Widget listView = CustomListView(
            scrollDirection: widget.scrollDirection,
            padding:
                widget.itemsPadding ?? EdgeInsets.symmetric(horizontal: 10),
            dataSet: model.vendors,
            isLoading: model.isBusy,
            noScrollPhysics: widget.scrollDirection != Axis.horizontal,
            itemBuilder: (context, index) {
              //
              final vendor = model.vendors[index];
              //
              if (widget.viewType != null &&
                  widget.viewType == HorizontalVendorListItem) {
                return HorizontalVendorListItem(
                  vendor,
                  onPressed: model.vendorSelected,
                );
              } else if (vendor.vendorType.isFood) {
                return FittedBox(
                    child: FoodVendorListItem(
                  vendor: vendor,
                  onPressed: model.vendorSelected,
                ).w(widget.itemWidth ?? (context.percentWidth * 50)));
              } else {
                //
                return VendorListItem(
                  vendor: vendor,
                  onPressed: model.vendorSelected,
                ).w(widget.itemWidth ?? (context.percentWidth * 50));
              }
            },
            emptyWidget: EmptyVendor(),
            separatorBuilder: widget.separator != null
                ? (ctx, index) => widget.separator!
                : null,
          );

          //
          return Visibility(
            visible: !widget.hideEmpty || (model.vendors.isNotEmpty),
            child: VStack(
              [
                //
                Visibility(
                  visible: widget.title.isNotBlank,
                  child: Padding(
                    padding: widget.titlePadding ?? EdgeInsets.all(12),
                    child: SectionTitle("${widget.title}"),
                  ),
                ),

                //vendors list
                if (model.vendors.isEmpty)
                  listView.h(model.vendors.isEmpty ? 240 : 195).wFull(context)
                else if (widget.scrollDirection == Axis.horizontal)
                  listView.h(240).wFull(context)
                else
                  listView.wFull(context)
              ],
            ),
          );
        },
      ),
    );
  }
}
