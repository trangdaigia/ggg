import 'package:flutter/material.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:sod_user/driver_lib/view_models/home.vm.dart';
import 'package:sod_user/services/app.service.dart';


class OnOffButton extends StatelessWidget {
  const OnOffButton({
    super.key,
    required this.stateColor,
    required this.homeVm,
  });
  final HomeViewModel homeVm;
  final Color stateColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: homeVm.toggleOnlineStatus,
      child: Container(
        decoration: BoxDecoration(
          color: stateColor,
          borderRadius: BorderRadius.horizontal(left: Radius.circular(50), right: Radius.circular(50)),
        ),
        width: 80,
        height: 50,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Stack(children: [
            Center(
              child: Row(
                mainAxisAlignment: !AppService().driverIsOnline ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Text(
                      AppService().driverIsOnline ? 'On' : "Off",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: !AppService().driverIsOnline ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: Duration(
                    milliseconds: 200,
                  ),
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(70), border: Border.all(color: Colors.black)),
                    width: 40,
                    height: 40,
                  ),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
