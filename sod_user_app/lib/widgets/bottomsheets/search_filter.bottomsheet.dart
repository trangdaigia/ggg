import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:sod_user/models/search.dart';
import 'package:sod_user/models/tag.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/search_filter.vm.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/buttons/custom_button.dart';
import 'package:sod_user/widgets/cards/custom.visibility.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SearchFilterBottomSheet extends StatelessWidget {
  const SearchFilterBottomSheet({
    Key? key,
    required this.onSubmitted,
    required this.vm,
    required this.search,
  }) : super(key: key);

  //
  final Search? search;
  final SearchFilterViewModel vm;
  final Function(Search) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<SearchFilterViewModel>.reactive(
      viewModelBuilder: () => vm,
      onViewModelReady: (vm) => vm.fetchSearchData(),
      disposeViewModel: false,
      builder: (context, vm, child) {
        return VStack(
          [
            UiSpacer.swipeIndicator(),
            UiSpacer.vSpace(),
            //

            (vm.busy(vm.searchData))
                ? BusyIndicator().centered().p20()
                : VStack(
                    [
                      //Layout type
                      "Layout Type".tr().text.semiBold.lg.make(),
                      FormBuilderRadioGroup(
                        name: "view_type",
                        decoration: InputDecoration(border: InputBorder.none),
                        initialValue: search?.layoutType ?? "grid",
                        options: [
                          FormBuilderFieldOption(
                            value: "grid",
                            child: "GridView".tr().text.make(),
                          ),
                          FormBuilderFieldOption(
                            value: "list",
                            child: "ListView".tr().text.make(),
                          )
                        ],
                        onChanged: (String? value) {
                          search?.layoutType = value;
                        },
                      ),
                      UiSpacer.divider().py(6),
                      //sort
                      "Sort by".tr().text.semiBold.lg.make(),
                      FormBuilderRadioGroup(
                        name: "sort",
                        decoration: InputDecoration(border: InputBorder.none),
                        initialValue: search?.sort ?? "asc",
                        options: [
                          FormBuilderFieldOption(
                            value: "asc",
                            child: "Ascending (A-Z)".tr().text.make(),
                          ),
                          FormBuilderFieldOption(
                            value: "desc",
                            child: "Descending (Z-A)".tr().text.make(),
                          )
                        ],
                        onChanged: (String? value) {
                          search?.sort = value;
                        },
                      ),

                      UiSpacer.vSpace(10),
                      UiSpacer.divider(),
                      UiSpacer.vSpace(10),
                      //price
                      "Price".tr().text.semiBold.lg.make(),
                      FormBuilderRangeSlider(
                        name: "price",
                        decoration: InputDecoration(border: InputBorder.none),
                        initialValue: RangeValues(
                          vm.searchData?.priceRange?[0] ?? 0,
                          vm.searchData?.priceRange?[1] ?? 100,
                        ),
                        min: vm.searchData?.priceRange?[0] ?? 0,
                        max: vm.searchData?.priceRange?[1] ?? 100,
                        onChanged: (values) {
                          search?.minPrice = values?.start.toString();
                          search?.maxPrice = values?.end.toString();
                        },
                      ).wFull(context),

                      UiSpacer.vSpace(10),
                      UiSpacer.divider(),
                      UiSpacer.vSpace(10),
                      //tags
                      CustomVisibilty(
                        visible: (vm.searchData?.tags ?? []).isNotEmpty,
                        child: VStack(
                          [
                            "Filter by".tr().text.semiBold.lg.make(),
                            FormBuilderCheckboxGroup<Tag>(
                              name: "tag",
                              initialValue: search?.tags ?? [],
                              wrapDirection: Axis.vertical,
                              decoration:
                                  InputDecoration(border: InputBorder.none),
                              options: (vm.searchData?.tags ?? []).map(
                                (e) {
                                  return FormBuilderFieldOption<Tag>(
                                    value: e,
                                    child: e.name.text.make(),
                                  );
                                },
                              ).toList(),
                              onChanged: (List<Tag>? values) {
                                search?.tags = values;
                              },
                            ),
                            UiSpacer.vSpace(10),
                            UiSpacer.divider(),
                            UiSpacer.vSpace(10),
                          ],
                        ),
                      ),

                      //filter by location or not
                      HStack(
                        [
                          Checkbox(
                            value: search?.byLocation,
                            onChanged: (value) {
                              search?.byLocation = value;
                              vm.notifyListeners();
                            },
                          ),
                          UiSpacer.smHorizontalSpace(),
                          "Filter by location".tr().text.make().expand(),
                        ],
                      ).onInkTap(() {
                        search?.byLocation = !(search?.byLocation ?? true);
                        vm.notifyListeners();
                      }),
                      //tags

                      //
                      CustomButton(
                        title: "Submit".tr(),
                        onPressed: () {
                          onSubmitted(search!);
                          Navigator.pop(context);
                        },
                      ).centered().py16(),
                    ],
                  ),
          ],
        )
            .p20()
            .scrollVertical()
            .box
            .topRounded()
            .color(context.theme.colorScheme.surface)
            .make();
        // .h(context.percentHeight * 90);
      },
    );
  }
}
