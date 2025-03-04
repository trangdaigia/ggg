import 'package:flutter/material.dart';
import 'package:sod_user/widgets/busy_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({
    this.loading = false,
    required this.child,
    this.loadingWidget,
    Key? key,
  }) : super(key: key);

  final bool loading;
  final Widget? loadingWidget;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return loading ? (loadingWidget ?? BusyIndicator().centered()) : child;
  }
}
