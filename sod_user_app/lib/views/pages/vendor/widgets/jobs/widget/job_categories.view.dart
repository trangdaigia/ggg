import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/view_models/vendor/job/job_category.vm.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_more.dart';
import 'package:stacked/stacked.dart';

class JobWidget extends StatelessWidget {
  JobWidget(
      {Key? key,
      required this.content,
      required this.title,
      required this.titleMore,
      required this.onPressed})
      : super(key: key);

  final Widget content;
  final Widget title;
  final String titleMore;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<JobCategoryViewModel>.reactive(
      viewModelBuilder: () => JobCategoryViewModel(),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                SizedBox(height: 20),
                content,
                Divider(color: Colors.grey[200]),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () => onPressed(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        titleMore,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColor.primaryColor,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: AppColor.primaryColor,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 5,
                  margin: EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(width: 5, color: Colors.grey[200]!),
                    ),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
