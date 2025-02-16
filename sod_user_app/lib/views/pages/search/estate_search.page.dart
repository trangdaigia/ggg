import 'package:flutter/material.dart';
import 'package:sod_user/view_models/main_search.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:stacked/stacked.dart';


class MainSearchPage extends StatelessWidget {
  const MainSearchPage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<MainSearchViewModel>.reactive(
      viewModelBuilder: () => MainSearchViewModel(context),
      onViewModelReady: (vm) => vm.initialise(),
      disposeViewModel: false,
      builder: (context, vm, child) {
        return BasePage(
          body: SafeArea(
            bottom: false,
            child: Center(child: Text("asdaksdasdasdsa"))
          ),
        );
      },
    );
  }
}
