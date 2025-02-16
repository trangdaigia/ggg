import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_images.dart';
import 'package:sod_user/models/vendor.dart';
import 'package:sod_user/utils/ui_spacer.dart';
import 'package:sod_user/view_models/vendor_reviews.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:sod_user/widgets/custom_list_view.dart';
import 'package:sod_user/widgets/list_items/review.list_item.dart';
import 'package:sod_user/widgets/states/empty.state.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class VendorReviewsPage extends StatefulWidget {
  const VendorReviewsPage(this.vendor, {Key? key}) : super(key: key);

  final Vendor vendor;
  @override
  _VendorReviewsPageState createState() => _VendorReviewsPageState();
}

class _VendorReviewsPageState extends State<VendorReviewsPage> {
  GlobalKey pageKey = GlobalKey<State>();
  @override
  Widget build(BuildContext context) {
    return BasePage(
      showAppBar: true,
      showLeadingAction: true,
      title: "${widget.vendor.name} " + "Reviews".tr(),
      key: pageKey,
      body: ViewModelBuilder<VendorReviewsViewModel>.reactive(
        viewModelBuilder: () => VendorReviewsViewModel(context, widget.vendor),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, vm, child) {
          return CustomListView(
            canPullUp: true,
            canRefresh: true,
            refreshController: vm.refreshController,
            onRefresh: vm.getVendorReviews,
            onLoading: () => vm.getVendorReviews(initialLoading: false),
            isLoading: vm.isBusy,
            loadingWidget: BusyIndicator().centered(),
            dataSet: vm.reviews,
            separatorBuilder: (context, index) =>
                UiSpacer.verticalSpace(space: 15),
            padding: EdgeInsets.all(20),
            itemBuilder: (context, index) {
              //
              final review = vm.reviews[index];
              return ReviewListItem(review);
            },
            emptyWidget: EmptyState(
                    imageUrl: AppImages.noReview,
                    title: "No Review".tr(),
                    description:
                        "When customer drop review, you will see them here"
                            .tr())
                .centered(),
          );
        },
      ),
    );
  }
}
