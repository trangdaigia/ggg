import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_user/driver_lib/constants/app_images.dart';
import 'package:sod_user/driver_lib/view_models/profile_detail.vm.dart';
import 'package:sod_user/driver_lib/widgets/base.page.dart';
import 'package:sod_user/driver_lib/widgets/busy_indicator.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_rating_bar/src/rating_bar.dart';
import 'package:sod_user/driver_lib/views/pages/profile/review_card.dart';
import 'package:sod_user/driver_lib/widgets/custom_list_view.dart';
import 'package:sod_user/driver_lib/constants/app_colors.dart';

class ProfileDetailPage extends StatefulWidget {
  const ProfileDetailPage({Key? key}) : super(key: key);

  @override
  State<ProfileDetailPage> createState() => _ProfileDetailPageState();
}

class _ProfileDetailPageState extends State<ProfileDetailPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ProfileDetailViewModel>.reactive(
      viewModelBuilder: () => ProfileDetailViewModel(context),
      onViewModelReady: (model) {
        model.setTabController(TabController(length: 2, vsync: this));
        model.initialise();
      },
      builder: (context, model, child) {
        return BasePage(
          showLeadingAction: true,
          showAppBar: true,
          title: "Profile Detail".tr(),
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverToBoxAdapter(
                child: Row(
                  children: [
                    CachedNetworkImage(
                      imageUrl: model.currentUser?.user.photo ?? "",
                      progressIndicatorBuilder: (context, url, progress) =>
                          BusyIndicator(),
                      errorWidget: (context, imageUrl, progress) {
                        return Image.asset(AppImages.user);
                      },
                      fit: BoxFit.cover,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: imageProvider,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        "${model.currentUser?.user.name ?? 'User name'.tr()}"
                            .text
                            .size(20)
                            .bold
                            .make(),
                        if (!model.busy(model.currentUser)) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              '${(double.parse(model.currentUser?.rating.toString() ?? "0")).toStringAsFixed(1)}'
                                  .text
                                  .bold
                                  .size(16)
                                  .make()
                                  .pOnly(right: 4),
                              RatingBar.builder(
                                ignoreGestures: true,
                                initialRating: double.parse(
                                    model.currentUser?.rating.toString() ??
                                        "0"),
                                direction: Axis.horizontal,
                                itemCount: 5,
                                itemSize: 20,
                                itemPadding: EdgeInsets.all(2),
                                itemBuilder: (context, _) => Icon(
                                    FlutterIcons.star_ant,
                                    color: Colors.yellow[700]),
                                onRatingUpdate: (_) {},
                              ),
                            ],
                          ),
                          ("${model.reviewFormOrther.length} " + "Reviews".tr())
                              .tr()
                              .text
                              .size(16)
                              .make(),
                        ],
                      ],
                    ).expand(),
                    IconButton(
                      onPressed: () => model.editProfile(),
                      icon: Icon(FlutterIcons.edit_faw5),
                    ),
                  ],
                ).p(12).backgroundColor(AppColor.onboarding1Color),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverTabBarDelegate(
                  TabBar(
                    controller: model.tabController,
                    tabs: [
                      Tab(
                        text: 'Review from other'.tr() +
                            ' (${model.reviewFormOrther.length})',
                      ),
                      Tab(
                        text: 'My review'.tr() + ' (${model.myReview.length})',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            body: TabBarView(
              controller: model.tabController,
              children: [
                // Tab 1: Review from other
                RefreshIndicator(
                  onRefresh: () async => model.refreshReviewsFromOther(),
                  child: model.busy(model.reviewFormOrther)
                      ? BusyIndicator().centered()
                      : CustomListView(
                          isLoading: false,
                          dataSet: model.reviewFormOrther,
                          emptyWidget:
                              Text('No Review from other'.tr()).centered(),
                          itemBuilder: (context, index) {
                            final review = model.reviewFormOrther[index];
                            return ReviewCard(
                              photo: review.user?.photo,
                              name: review.user?.name ?? 'User name'.tr(),
                              review: review.review,
                              rating: review.rating,
                              createdAt: review.createdAt,
                            ).px(16).py(8);
                          },
                        ).pOnly(bottom: 16),
                ),
                // Tab 2: My review
                RefreshIndicator(
                  onRefresh: () async => model.refreshMyReview(),
                  child: model.busy(model.myReview)
                      ? BusyIndicator().centered()
                      : CustomListView(
                          isLoading: false,
                          dataSet: model.myReview,
                          emptyWidget:
                              Text('No Review from me'.tr()).centered(),
                          itemBuilder: (context, index) {
                            final review = model.myReview[index];
                            return ReviewCard(
                              photo: model.currentUser?.user.photo,
                              name: model.currentUser?.user.name ?? 'User name'.tr(),
                              review: review.review,
                              rating: review.rating,
                              createdAt: review.createdAt,
                            ).px(16).py(8);
                          },
                        ).pOnly(bottom: 16),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColor.onboarding1Color, // Đặt màu nền cho tab bar
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
