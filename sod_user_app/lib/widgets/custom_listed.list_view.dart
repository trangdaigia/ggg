import 'package:flutter/material.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/widgets/states/empty.state.dart';
import 'package:sod_user/widgets/states/loading.shimmer.dart';
import 'package:pull_to_refresh_flutter3/pull_to_refresh_flutter3.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomListedListView extends StatelessWidget {
  //
  final ScrollController? scrollController;
  final Widget? title;
  final Widget? loadingWidget;
  final Widget? errorWidget;
  final Widget? emptyWidget;
  final List<Widget> items;
  final bool isLoading;
  final bool hasError;
  final bool justList;
  final bool reversed;
  final bool noScrollPhysics;
  final Axis scrollDirection;
  final EdgeInsets? padding;

  //
  final bool canRefresh;
  final RefreshController? refreshController;
  final Function? onRefresh;
  final Function? onLoading;
  final bool canPullUp;

  const CustomListedListView({
    required this.items,
    this.scrollController,
    this.title,
    this.loadingWidget,
    this.errorWidget,
    this.emptyWidget,
    this.isLoading = false,
    this.hasError = false,
    this.justList = true,
    this.reversed = false,
    this.noScrollPhysics = false,
    this.scrollDirection = Axis.vertical,
    this.padding,

    //
    this.canRefresh = false,
    this.refreshController,
    this.onRefresh,
    this.onLoading,
    this.canPullUp = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return this.justList
        ? _getBody()
        : VStack(
            [
              this.title ?? UiSpacer.emptySpace(),
              _getBody(),
            ],
            crossAlignment: CrossAxisAlignment.start,
          );
  }

  Widget _getBody() {
    final contentBody = this.isLoading
        ? this.loadingWidget ?? LoadingShimmer()
        : this.hasError
            ? this.errorWidget ?? EmptyState(description: "There is an error")
            : this.items.isEmpty
                ? this.emptyWidget ?? UiSpacer.emptySpace()
                : this.justList
                    ? _getListView()
                    : Expanded(
                        child: _getListView(),
                      );

    return this.canRefresh
        ? SmartRefresher(
            scrollDirection: this.scrollDirection,
            enablePullDown: true,
            enablePullUp: canPullUp,
            controller: this.refreshController!,
            onRefresh: this.onRefresh != null ? () => this.onRefresh!() : null,
            onLoading: this.onLoading != null ? () => this.onLoading!() : null,
            child: contentBody,
          )
        : contentBody;
  }

  //get listview
  Widget _getListView() {
    return ListView.custom(
      controller: this.scrollController,
      padding: this.padding,
      shrinkWrap: true,
      reverse: this.reversed,
      physics: this.noScrollPhysics ? NeverScrollableScrollPhysics() : null,
      scrollDirection: this.scrollDirection,
      childrenDelegate: SliverChildListDelegate(items),
    );
  }
}
