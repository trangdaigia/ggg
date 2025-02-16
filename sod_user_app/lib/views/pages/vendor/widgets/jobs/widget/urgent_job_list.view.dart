import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/view_models/vendor/job/job.vm.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_detail_page.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_more.dart';
import 'package:stacked/stacked.dart';

import 'job_list_item.dart';

class UrgentJobList extends StatelessWidget {
  const UrgentJobList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<JobViewModel>.reactive(
      viewModelBuilder: () => JobViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 15),
                model.isBusy
                    ? Center(child: CircularProgressIndicator())
                    : model.job.isEmpty
                        ? Center(child: Text('Không có công việc tuyển gấp'))
                        : SizedBox(
                            height: 320,
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 2 / 4,
                              ),
                              itemCount: model.job.length,
                              itemBuilder: (context, index) {
                                final job = model.job[index];
                                return JobListItem(
                                  title: job.name,
                                  salary: job.salary,
                                  company: job.company,
                                  location: job.location,
                                  imageUrl: job.imageUrl,
                                  isUrgent: true,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            JobDetailPage(job: job),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                SizedBox(height: 10),
                Divider(color: Colors.grey[200]),
                SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobMore(
                            isUrgent: true, showAll: true, categoryId: null),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Xem thêm các việc làm khác',
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
                SizedBox(height: 5),
                Divider(color: Colors.grey[200]),
              ],
            ),
          ),
        );
      },
    );
  }
}
