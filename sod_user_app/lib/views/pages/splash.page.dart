import 'package:flutter/material.dart';
import 'package:sod_user/view_models/splash.vm.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>  {
  @override
  Widget build(BuildContext context) {
    return BasePage(
      body: ViewModelBuilder<SplashViewModel>.reactive(
        viewModelBuilder: () => SplashViewModel(context),
        onViewModelReady: (vm) => vm.initialise(),
        builder: (context, model, child) {
          return VStack(
            [
              SizedBox(
                width: MediaQuery.of(context).size.width * 1,
                height: MediaQuery.of(context).size.width * 1,
                child: Center(
                  child: Image.asset(
                    model.getSplashImagePath(),
                    width: 200,
                    height: 200,
                  ),
                ),
              ),
              //linear progress indicator
              LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.theme.primaryColor,
                ),
              ).wOneThird(context).centered(),
            ],
            crossAlignment: CrossAxisAlignment.center,
            alignment: MainAxisAlignment.center,
          ).centered();
        },
      ),
    );
  }
}
