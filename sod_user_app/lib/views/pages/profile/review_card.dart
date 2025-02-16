import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:localize_and_translate/localize_and_translate.dart';
import 'package:velocity_x/velocity_x.dart';

class ReviewCard extends StatelessWidget {
  final String? name;
  final String? review;
  final int? rating;
  final String? photo;
  final DateTime? createdAt;

  const ReviewCard({
    super.key,
    required this.name,
    required this.review,
    required this.rating,
    required this.photo,
    required this.createdAt,
  });

  String _getTimeAgoText(Duration difference) {
    String differenceText;

    if (difference.inDays >= 30) {
      differenceText = "${difference.inDays ~/ 30} " + "months ago".tr();
    } else if (difference.inDays >= 7 && difference.inDays < 30) {
      differenceText = "${difference.inDays ~/ 7} " + "weeks ago".tr();
    } else if (difference.inDays > 0) {
      differenceText = "${difference.inDays} " + "days ago".tr();
    } else if (difference.inHours > 0) {
      differenceText = "${difference.inHours} " + "hours ago".tr();
    } else if (difference.inMinutes > 0) {
      differenceText = "${difference.inMinutes} " + "minutes ago".tr();
    } else {
      differenceText = "Just now".tr();
    }

    return differenceText;
  }

  @override
  Widget build(BuildContext context) {
    final currentDate = DateTime.now();
    final difference = currentDate.difference(createdAt ?? DateTime.now());
    final differenceText = _getTimeAgoText(difference);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 26,
          backgroundImage: NetworkImage(photo ?? ""),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name ?? "",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Row(
              children: [
                RatingBar.builder(
                  ignoreGestures: true,
                  initialRating: rating?.toDouble() ?? 0,
                  direction: Axis.horizontal,
                  itemCount: 5,
                  itemSize: 16,
                  itemPadding: EdgeInsets.all(0),
                  itemBuilder: (context, _) =>
                      Icon(FlutterIcons.star_ant, color: Colors.yellow[700]),
                  onRatingUpdate: (_) {},
                ),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      VerticalDivider(
                        color: Colors.grey,
                        thickness: 1,
                      ).px(4),
                      Text(
                        differenceText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 6),
            Text(
              review == null || review!.isEmpty ? "No review".tr() : review!,
              style: TextStyle(
                fontSize: 14,
                color: review == null || review!.isEmpty
                    ? Colors.grey
                    : Colors.black,
              ),
            ),
          ],
        ).expand(),
      ],
    );
  }
}
