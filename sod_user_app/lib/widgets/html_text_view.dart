import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:sod_user/constants/app_text_styles.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:velocity_x/velocity_x.dart';

class HtmlTextView extends StatelessWidget {
  const HtmlTextView(this.htmlContent, {Key? key}) : super(key: key);

  final String htmlContent;

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      htmlContent,
      //Chỉnh style cho text
      textStyle: AppTextStyle.h5TitleTextStyle(fontWeight: FontWeight.w400),
      //
      onTapImage: (ImageMetadata imageMetadata) {
        try {
          launchUrlString(imageMetadata.sources.first.url);
        } catch (e) {
          print(e);
        }
      },
      onTapUrl: (url) {
        return launchUrlString(url);
      },
    ).px20();
  }
}
