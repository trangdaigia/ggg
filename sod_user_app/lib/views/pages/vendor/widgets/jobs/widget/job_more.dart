import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/view_models/vendor/job/job.vm.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/application_form_modal.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_detail_page.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_list_item.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class JobMore extends StatelessWidget {
  const JobMore({
    Key? key,
    this.isUrgent = false,
    this.isLastest = false,
    required this.showAll,
    required this.categoryId,
  }) : super(key: key);

  final bool isUrgent;
  final bool isLastest;
  final bool showAll;
  final int? categoryId;

  @override
  Widget build(BuildContext context) {
    // Hàm timeAgo không thay đổi
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

    return ViewModelBuilder<JobViewModel>.reactive(
      viewModelBuilder: () => JobViewModel(context),
      onViewModelReady: (model) => model.initialise(),
      builder: (context, model, child) {
        if (isLastest) {
          model.job.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }

        return BasePage(
          showAppBar: true,
          showLeadingAction: !AppStrings.isSingleVendorMode,
          elevation: 0,
          title: 'Việc làm bán hàng',
          appBarColor: context.theme.colorScheme.primary,
          appBarItemColor: AppColor.primaryColor,
          showCart: false,
          isIconNotifi: true,
          isIconMessage: true,
          isBlackColorBackArrow: true,
          isSearch: true,
          backgroundColor: Colors.white,
          body: Padding(
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tất cả việc làm',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 20),
                Expanded(
                  child: model.isBusy
                      ? Center(child: CircularProgressIndicator())
                      : showAll
                          ? model.job.isEmpty
                              ? Center(child: Text('Không có việc làm nào'))
                              : ListView.builder(
                                  itemCount: model.job.length,
                                  itemBuilder: (context, index) {
                                    final job = model.job[index];
                                    return Column(
                                      children: [
                                        JobListItem(
                                          title: job.name,
                                          salary: job.salary,
                                          company: job.company,
                                          location: job.location,
                                          imageUrl: job.imageUrl,
                                          isUrgent: isUrgent,
                                          isRecent: isLastest,
                                          time:
                                              timeAgo(job.createdAt.toString()),
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    JobDetailPage(
                                                        job: job,
                                                        isLastest: isLastest),
                                              ),
                                            );
                                          },
                                        ),
                                        // SizedBox(height: 20),
                                      ],
                                    );
                                  },
                                )
                          : ListView.builder(
                              itemCount: model.job
                                  .where(
                                      (job) => job.adsCategoryId == categoryId)
                                  .length,
                              itemBuilder: (context, index) {
                                final job = model.job
                                    .where((job) =>
                                        job.adsCategoryId == categoryId)
                                    .toList()[index];
                                ;
                                return Column(
                                  children: [
                                    JobListItem(
                                      title: job.name,
                                      salary: job.salary,
                                      company: job.company,
                                      location: job.location,
                                      imageUrl: job.imageUrl,
                                      isUrgent: isUrgent,
                                      isRecent: isLastest,
                                      time: timeAgo(job.createdAt.toString()),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  JobDetailPage(
                                                      job: job,
                                                      showBanner: false)),
                                        );
                                      },
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                );
                              },
                            ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Để lại thông tin, nhận việc ngay',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Hãy để lại số điện thoại để nhà tuyển dụng gọi cho bạn khi có công việc phù hợp nhé!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          _showCreateProfileModal(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                        ),
                        child: Text(
                          'TẠO HỒ SƠ',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCreateProfileModal(BuildContext context) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return ApplicationFormModal(isBasicInformation: true);
        });
  }
}
