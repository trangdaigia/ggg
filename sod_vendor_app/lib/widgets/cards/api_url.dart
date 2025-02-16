import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_vendor/constants/app_text_styles.dart';
import 'package:sod_vendor/view_models/api_url.vm.dart';
import 'package:sod_vendor/widgets/base.page.dart';
import 'package:sod_vendor/widgets/buttons/custom_button.dart';
import 'package:sod_vendor/utils/utils.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:stacked/src/view_models/view_model_builder.dart';

class ChangeApiUrl extends StatefulWidget {
  ChangeApiUrl({super.key});

  @override
  State<ChangeApiUrl> createState() => _ChangeApiUrlState();
}

class _ChangeApiUrlState extends State<ChangeApiUrl> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChangeApiUrlViewModel>.reactive(
      viewModelBuilder: () => ChangeApiUrlViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      disposeViewModel: false,
      builder: (context, vm, child) {
        return BasePage(
          showAppBar: true,
          showLeadingAction: true,
          elevation: 0,
          title: "Change URL API".tr(),
          appBarItemColor: Utils.textColorByTheme(),
          backgroundColor: context.theme.colorScheme.surface,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: vm.urlController,
                decoration: InputDecoration(
                  labelText: "Enter new Api Url".tr(),
                  prefixText: 'https://',
                  suffixText: '/api',
                  prefixStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                  suffixStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: AppTextStyle.h4TitleTextStyle(),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    onPressed: vm.onDefaultUrlClick,
                    title: 'Default'.tr(),
                  ),
                  CustomButton(
                    loading: vm.isTesting,
                    onPressed: vm.onConfirmClick,
                    title: 'Confirm'.tr(),
                  ),
                ],
              ),
            ],
          ).p12(),
        );
      },
    );
  }
}
