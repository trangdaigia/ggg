import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:sod_vendor/constants/app_colors.dart';
import 'package:sod_vendor/models/service.dart';
import 'package:sod_vendor/utils/ui_spacer.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:sod_vendor/view_models/service_details.vm.dart';
import 'package:sod_vendor/views/pages/service/widgets/service_details.bottomsheet.dart';
import 'package:sod_vendor/views/pages/service/widgets/service_details_price.section.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:sod_vendor/widgets/custom_image.view.dart';
import 'package:sod_vendor/widgets/custom_masonry_grid_view.dart';
import 'package:sod_vendor/widgets/html_text_view.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class ServiceDetailsPage extends StatelessWidget {
  const ServiceDetailsPage(
    this.service, {
    Key? key,
  }) : super(key: key);

  //
  final Service service;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ServiceDetailsViewModel>.reactive(
      viewModelBuilder: () => ServiceDetailsViewModel(context, service),
      builder: (context, vm, child) {
        return BasePage(
          extendBodyBehindAppBar: true,
          onBackPressed: () => vm.goBack(),
          body: Stack(
            children: [
              //
              CustomImage(
                imageUrl:
                    vm.service.photos.isNotEmpty ? vm.service.photos.first : '',
                width: double.infinity,
                height: context.percentHeight * 50,
              ),

              //service details section
              VStack(
                [
                  //empty space
                  UiSpacer.verticalSpace(space: context.percentHeight * 40),
                  //details
                  VStack(
                    [
                      //name
                      vm.service.name.text.medium.xl3.make(),
                      //price
                      ServiceDetailsPriceSectionView(vm.service),

                      //rest details
                      UiSpacer.verticalSpace(),
                      VStack(
                        [
                          //photos
                          CustomMasonryGridView(
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            items: vm.service.photos
                                .map(
                                  (photo) => CustomImage(
                                    imageUrl: photo,
                                    width: double.infinity,
                                    height: 100,
                                  ).box.roundedSM.clip(Clip.antiAlias).make(),
                                )
                                .toList(),
                          ),

                          //description
                          HtmlTextView(vm.service.description, padding: 0),
                        ],
                      )
                          .box
                          .p12
                          .color(context.theme.colorScheme.surface)
                          .shadowXs
                          .roundedSM
                          .make(),

                      //spaces
                      UiSpacer.verticalSpace(),
                      UiSpacer.verticalSpace(),
                      UiSpacer.verticalSpace(),
                    ],
                  )
                      .wFull(context)
                      .p20()
                      .box
                      .color(context.theme.colorScheme.surface)
                      .topRounded(value: 30)
                      .make(),
                ],
              ).scrollVertical(),

              //appbar section
              Positioned(
                top: kToolbarHeight,
                left: !Utils.isArabic ? Vx.dp20 : null,
                right: Utils.isArabic ? Vx.dp20 : null,
                child: Icon(
                  !Utils.isArabic
                      ? FlutterIcons.arrow_left_fea
                      : FlutterIcons.arrow_right_fea,
                  color: AppColor.primaryColor,
                )
                    .p12()
                    .box
                    .roundedSM
                    .color(context.theme.colorScheme.surface)
                    .make()
                    .onTap(
                      () => Navigator.pop(context),
                    ),
              ),
            ],
          ),
          //
          bottomNavigationBar: ServiceDetailsBottomSheet(vm),
        );
      },
    );
  }
}
