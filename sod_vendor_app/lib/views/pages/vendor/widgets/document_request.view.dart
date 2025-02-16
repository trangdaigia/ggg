import 'package:flutter/material.dart';
import 'package:sod_vendor/view_models/document_request.vm.dart';
import 'package:sod_vendor/views/pages/vendor/document_request.page.dart';
import 'package:sod_vendor/widgets/busy_indicator.dart';
import 'package:sod_vendor/widgets/menu_item.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class DocumentRequestView extends StatelessWidget {
  const DocumentRequestView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DocumentRequestViewModel>.reactive(
      viewModelBuilder: () => DocumentRequestViewModel(),
      onViewModelReady: (model) => model.initialise(),
      builder: (
        BuildContext context,
        DocumentRequestViewModel model,
        Widget? child,
      ) {
        //if model is busy
        if (model.isBusy) {
          return BusyIndicator().centered().p(5);
        }
        //if current user has document requested or pending verification
        if (model.currentVendor != null &&
            (!model.currentVendor!.documentRequested &&
                !model.currentVendor!.pendingDocumentApproval)) {
          return SizedBox();
        }

        //
        return MenuItem(
          title: "Document Request".tr(),
          onPressed: () {
            context.nextPage(DocumentRequestPage());
          },
          suffix: VxBox(
            child: "1".text.white.bold.xl.make().px(6),
          ).p3.roundedSM.red500.make(),
          topDivider: true,
          divider: true,
        ).px(12).pOnly(bottom: 12);
      },
    );
  }
}
