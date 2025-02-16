import 'dart:ffi';

import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/models/real_estate.dart';
import 'package:sod_user/models/real_estate_category.dart';
import 'package:sod_user/view_models/real_estate_search.vm.dart';
import 'package:sod_user/views/pages/real_estate/widgets/real_estate_dropdown.btn.dart';
import 'package:sod_user/views/pages/real_estate/widgets/real_estate_filter_overlay.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/list_items/real_estate_overlay_filter.list_time.dart';
import 'package:sod_user/widgets/list_items/real_estate_with_detail.list_item.dart';
import 'package:sod_user/widgets/list_items/real_estate_with_detail_horizontal.list_item.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class RealEstateSearchPage extends StatefulWidget {
  const RealEstateSearchPage({Key? key, this.initialQuery}) : super(key: key);
  final Map<String, dynamic>? initialQuery;
  @override
  _RealEstateSearchPageState createState() => _RealEstateSearchPageState();
}

class _RealEstateSearchPageState extends State<RealEstateSearchPage> {
  GlobalKey pageKey = GlobalKey<State>();
  @override
  void initState() {
    super.initState();
  }

  Widget buildRealEstateList(String style, ScrollController controller, List<RealEstate> realEstates) {
    if(style == "grid")
      return GridView.count(
                            controller: controller,
                            padding: const EdgeInsets.all(8.0),
                            crossAxisCount: 2,
                            childAspectRatio: 0.63,
                            children: realEstates
                                .map((realEstate) =>
                                    RealEstateWithDetail(realEstate))
                                .toList())
                        .expand();
    return ListView.builder(
  controller: controller,
  padding: const EdgeInsets.all(8.0),
  itemCount: realEstates.length,
  itemBuilder: (context, index) {
    final realEstate = realEstates[index];
    return RealEstateWithDetailHorizontal(realEstate);
  },
).expand();
  }
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<RealEstateSearchViewModel>.reactive(
      viewModelBuilder: () =>
          RealEstateSearchViewModel(context, query: widget.initialQuery),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: !AppStrings.isSingleVendorMode,
          elevation: 0,
          onSearchChange: model.onSearchChanged,
          fab: RealEstateFilterOverlay(
            filterOptions: [
              RealEstateFilterOverlayListItem<RealEstateCategory>(
                  options: model.categories,
                  tranformOption: (RealEstateCategory a) => a.category.name,
                  animationDuration: Durations.extralong1,
                  selectedOption: model.categories.firstOrNullWhere((category) => category.category.id == model.getQuery("category_id")),
                  title: "Category",
                  onChange: (RealEstateCategory? a) {
                    if (a != null) model.addQuery("category_id", a.category.id);
                  }),
              RealEstateFilterOverlayListItem<String>(
                  options: model.sellingTypes,
                  tranformOption: (String a) => a,
                  animationDuration: Durations.extralong1,
                  selectedOption: model.getQuery("selling_type"),
                  title: "Selling type",
                  onChange: (String? a) {
                    if (a != null) model.addQuery("selling_type", a);
                  }),
              RealEstateFilterOverlayListItem<String>(
                  options: model.directionList,
                  tranformOption: (String a) => a,
                  animationDuration: Durations.medium1,
                  selectedOption: model.getQuery("direction"),
                  title: "House Direction",
                  onChange: (String? a) {
                    if (a != null) model.addQuery("direction", a);
                  }),
              RealEstateFilterOverlayListItem<int>(
                  options: List.generate(10, (index) => index + 1),
                  tranformOption: (int a) => a.toString(),
                  animationDuration: Durations.medium1,
                  selectedOption: int.parse(model.getQuery("bedroom") ?? "1"),
                  title: "Bedroom",
                  onChange: (int? a) {
                    if (a != null) model.addQuery("direction", a.toString());
                  })
            ],  
            onApplyFilters: () {
               model.getRealEstates();
               model.filterKey.currentState?.hideOverlay();
            }
          ),
          title: "Real Estate",
          appBarColor: context.theme.colorScheme.background,
          appBarItemColor: AppColor.primaryColor,
          isSearch: true,
          isIconNotifi: true,
          isIconMessage: true,
          showCart: false,
          key: model.pageKey,
          body: VStack([
            model.categories.length == 0
                ? SizedBox.shrink()
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: HStack([
                      RealEstateDropDownButton<String>(
                          name: "Selling type",
                          options: model.sellingTypes,
                          tranformOption: (String a) => a,
                          onChange: (String? a) {
                            model.addQuery("selling_type", a);
                            model.getRealEstates();
                          },
                          initialValue: widget.initialQuery != null
                              ? widget.initialQuery!["selling_type"]
                              : null),
                      RealEstateDropDownButton<RealEstateCategory>(
                        name: "Type",
                        options: model.categories,
                        tranformOption: (RealEstateCategory a) =>
                            a.category.name,
                        onChange: (RealEstateCategory? a) {
                          if (a != null)
                            model.addQuery("category_id", a.category.id);
                            model.getRealEstates();
                        },
                        initialValue: (widget.initialQuery == null ||
                                widget.initialQuery!["category_id"] == null)
                            ? null
                            : model.categories.firstOrNullWhere((element) =>
                                element.category.id.toString() ==
                                widget.initialQuery!["category_id"]),
                      ),
                      RealEstateDropDownButton(
                        name: "Bedroom",
                        options: [1, 2, 3, 4, 5, 5],
                        tranformOption: (a) => a.toString(),
                        onChange: (int? a) {
                          model.addQuery("bedroom", a);
                          model.getRealEstates();
                        },
                      )
                    ], spacing: 4)
                        .px8(),
                  ),
            HStack(
              [
                RealEstateDropDownButton(
                  name: "City",
                  options: model.cities,
                  tranformOption: (a) => a as String,
                  onChange: (a) {},
                  startIcon: Icons.pin_drop_outlined,
                ),
                HStack([
                  RealEstateDropDownButton(
                    name: "Sort by",
                    options: ["Post date", "Price"],
                    tranformOption: (a) => a as String,
                    onChange: (String? a) {
                      if(a == null)
                        model.addQuery("orderBy", null);
                      else if(a == "Post date")
                      model.addQuery("orderBy", "created_at");
                      else
                      model.addQuery("orderBy", "price");
                      model.getRealEstates();
                    },
                  ),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          model.listStyle =
                              model.listStyle == "grid" ? "list" : "grid";
                        });
                      },
                      icon: Icon(model.listStyle == "grid"
                          ? Icons.grid_view_outlined
                          : Icons.list_alt))
                ])
              ],
              alignment: MainAxisAlignment.spaceBetween,
            ).wFull(context).px8(),
            model.isBusy
                ? BusyIndicator().centered()
                : (model.realEstates.length == 0
                    ? "There is no real estate found."
                        .tr()
                        .text
                        .normal
                        .semiBold
                        .makeCentered()
                    : buildRealEstateList(model.listStyle, model.scrollController, model.realEstates))
          ]),
        );
      },
    );
  }
}
