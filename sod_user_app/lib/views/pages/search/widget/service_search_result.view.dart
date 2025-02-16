import 'package:flutter/material.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/main_search.vm.dart';
import 'package:sod_user/widgets/custom_grid_view.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/service.list_item.dart';
import 'package:sod_user/widgets/states/search.empty.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceSearchResultView extends StatefulWidget {
  ServiceSearchResultView(this.vm, {Key? key}) : super(key: key);

  final MainSearchViewModel vm;
  @override
  State<ServiceSearchResultView> createState() =>
      _ServiceSearchResultViewState();
}

class _ServiceSearchResultViewState extends State<ServiceSearchResultView> {
  @override
  Widget build(BuildContext context) {
    final refreshController = widget.vm.refreshControllers.last;
    //
    return (widget.vm.search?.layoutType == null ||
            widget.vm.search?.layoutType == "grid")
        ? CustomGridView(
            padding: EdgeInsets.symmetric(vertical: 0),
            refreshController: refreshController,
            canPullUp: true,
            canRefresh: true,
            onRefresh: widget.vm.searchProducts,
            onLoading: () => widget.vm.searchProducts(initial: false),
            dataSet: widget.vm.services,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            isLoading: widget.vm.busy(widget.vm.services),
            childAspectRatio: (context.screenWidth / 2) / 200,
            separatorBuilder: (p0, p1) => UiSpacer.vSpace(0),
            emptyWidget: EmptySearch(type: "service"),
            itemBuilder: (ctx, index) {
              final filteredServices = widget.vm.services.where((service) => service.description != "").toList();
              if (index >= filteredServices.length) {
                return SizedBox.shrink(); 
              }
              final service = filteredServices[index];
              return ServiceListItem(
                service: service,
                onPressed: widget.vm.servicePressed,
                height: 150,
                imgW: 60,
              );
            },
          )
        : CustomListView(
            padding: EdgeInsets.symmetric(vertical: 20),
            refreshController: refreshController,
            canPullUp: true,
            canRefresh: true,
            onRefresh: widget.vm.searchProducts,
            onLoading: () => widget.vm.searchProducts(initial: false),
            dataSet: widget.vm.services,
            isLoading: widget.vm.busy(widget.vm.services),
            emptyWidget: EmptySearch(type: "service"),
            itemBuilder: (ctx, index) {
              final service = widget.vm.services[index];
              return ServiceListItem(
                service: service,
                onPressed: widget.vm.servicePressed,
                height: 80,
                imgW: 60,
              );
            },
            separatorBuilder: (p0, p1) => UiSpacer.vSpace(10),
          );
  }
}