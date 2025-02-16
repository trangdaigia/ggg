import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/view_models/vendor/job/job.vm.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_detail_page.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_more.dart';
import 'package:stacked/stacked.dart';

import 'job_list_item.dart';

class LatestJobsList extends StatelessWidget {
  const LatestJobsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<JobViewModel>.reactive(
      viewModelBuilder: () => JobViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        var sortedJobs = model.job.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.new_releases_rounded, color: Colors.red),
                  SizedBox(width: 5),
                  Text(
                    "Việc làm mới nhất",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(width: 5),
                  Icon(Icons.info, color: Colors.grey, size: 18),
                ],
              ),
              SizedBox(height: 15),
              model.isBusy
                  ? Center(child: CircularProgressIndicator())
                  : sortedJobs.isEmpty
                      ? Center(child: Text('Không có việc làm mới'))
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
                            itemCount: sortedJobs.length,
                            itemBuilder: (context, index) {
                              final job = sortedJobs[index];
                              return JobListItem(
                                title: job.name,
                                salary: job.salary,
                                company: job.company,
                                location: job.location,
                                imageUrl: job.imageUrl,
                                isRecent: true,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JobDetailPage(
                                          job: job, isLastest: true),
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
                          isLastest: true, showAll: true, categoryId: null),
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
        );
      },
    );
  }
}
