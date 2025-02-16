import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sod_user/view_models/vendor/job/job.vm.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_detail_page.dart';
import 'package:stacked/stacked.dart';

class JobCardSimilar extends StatelessWidget {
  JobCardSimilar({Key? key, required this.currentJobId}) : super(key: key);
  final int currentJobId;

  @override
  Widget build(BuildContext context) {
    String timeAgo(String? dateTimeString) {
      if (dateTimeString == null) {
        return 'Không rõ';
      }

      DateTime dateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeString);
      Duration difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    }

    String getCity(String location) {
      int vietnamIndex = location.lastIndexOf(', Việt Nam');

      if (vietnamIndex != -1) {
        String beforeVietnam = location.substring(0, vietnamIndex);
        int cityIndex = beforeVietnam.lastIndexOf(', ');
        if (cityIndex != -1) {
          return beforeVietnam.substring(cityIndex + 2);
        }
      }
      List<String> parts = location.split(', ');
      return parts.isNotEmpty ? parts.last : location;
    }

    return ViewModelBuilder<JobViewModel>.reactive(
      viewModelBuilder: () => JobViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        if (model.isBusy) {
          return Center(child: CircularProgressIndicator());
        }

        final similarJobs =
            model.job.where((job) => job.id != currentJobId).toList();

        return SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: similarJobs.length,
            itemBuilder: (context, index) {
              final job = similarJobs[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailPage(job: job),
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Container(
                    width: 190,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image and favorite icon
                        Image.network(
                          job.imageUrl,
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Job title
                              Text(
                                job.name,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              SizedBox(height: 5),
                              // Salary
                              Text(
                                'Đến ${job.salary ~/ 1000000} triệu/tháng',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                              SizedBox(height: 5),
                              // Location and date
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 14, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(
                                    getCity(job.location),
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 14, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(
                                    timeAgo(job.createdAt.toString()),
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
