import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sod_user/driver_lib/widgets/busy_indicator.dart';
import 'package:velocity_x/velocity_x.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({
    required this.imageUrl,
    this.height = Vx.dp40,
    this.width,
    this.boxFit,
    Key? key,
  }) : super(key: key);

  final String imageUrl;
  final double height;
  final double? width;
  final BoxFit? boxFit;
  @override
  Widget build(BuildContext context) {
    return imageUrl.endsWith('.svg')
        ? SvgPicture.network(
            imageUrl,
            fit: this.boxFit ?? BoxFit.contain,
            height: height,
            width: width,
          )
        : CachedNetworkImage(
            imageUrl: this.imageUrl,
            fit: this.boxFit ?? BoxFit.contain,
            progressIndicatorBuilder: (context, imageURL, progress) =>
                BusyIndicator().centered(),
          ).h(this.height).w(this.width ?? context.percentWidth);
  }
}
