import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/constants/app_strings.dart';
import 'package:sod_user/view_models/vendor/job/job.vm.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/bottom_appbar_item.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_add_page.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_categories.view.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_detail_page.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_list_item.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_manage_job_add.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_more.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/latest_jobs_list.view.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/urgent_job_list.view.dart';
import 'package:sod_user/widgets/base.page.dart';
import 'package:stacked/stacked.dart';
import 'package:velocity_x/velocity_x.dart';

class JobPage extends StatelessWidget {
  const JobPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BasePage(
      backgroundColor: Colors.white,
      showAppBar: true,
      showLeadingAction: !AppStrings.isSingleVendorMode,
      elevation: 0,
      title: "Việc làm",
      appBarColor: context.theme.colorScheme.primary,
      appBarItemColor: context.backgroundColor,
      showCart: false,
      isIconNotifi: true,
      isIconMessage: true,
      isBlackColorBackArrow: false,
      isSearch: true,
      body: ViewModelBuilder<JobViewModel>.reactive(
          viewModelBuilder: () => JobViewModel(context),
          onViewModelReady: (model) => model.initialise(),
          builder: (context, vm, child) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Job Categories
                  JobWidget(
                    title: Text(
                      'Việc làm theo ngành nghề',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    titleMore: 'Xem tất cả ${vm.categories.length} nghành nghề',
                    content: _buildCategoriesContent(vm),
                    onPressed: () => vm.onPressedJobCategories(context),
                  ),
                  JobWidget(
                    title: Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.red),
                        SizedBox(width: 5),
                        Text(
                          "Việc làm tuyển gấp",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        SizedBox(width: 5),
                        Icon(Icons.info, color: Colors.grey, size: 18),
                      ],
                    ),
                    titleMore: 'Xem thêm các việc làm khác',
                    content: _buildUrgentJobContent(vm),
                    onPressed: () => vm.onPressedJobUrgent(context),
                  ),
                  //
                  // JobWidget(
                  //   title: Text(
                  //     "Việc làm từ nhà tuyển dụng tiêu biểu",
                  //     style:
                  //         TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  //   ),
                  //   titleMore: 'Xem thêm các việc làm khác',
                  //   content: _buildUrgentJobContent(vm),
                  //   onPressed: () => vm.onPressedJobUrgent(context),
                  // ),
                  // Lastest Job List
                  LatestJobsList()
                ],
              ),
            );
          }),
      // key: model.pageKey,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.withOpacity(0.1),
              width: 1.0,
            ),
          ),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Quản lý tin button
              BottomAppBarItem(
                icon: Icons.list_alt,
                label: 'Quản lý tin',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobManageJobAdd(),
                    ),
                  );
                },
              ),
              _buildVerticalDivider(),

              // Đăng tin button
              SizedBox(
                width: 180,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 15),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JobAddPage(),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit_calendar_outlined, color: Colors.white),
                  label: Text(
                    'Đăng tin',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypicalEmployeeContent(JobViewModel model) {
    return model.isBusy
        ? Center(child: CircularProgressIndicator())
        : model.job.isEmpty
            ? Center(child: Text('Không có công việc tuyển gấp'))
            : SizedBox(
                height: 320,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                            builder: (context) => JobDetailPage(job: job),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
  }

  Widget _buildUrgentJobContent(JobViewModel model) {
    return model.isBusy
        ? Center(child: CircularProgressIndicator())
        : model.job.isEmpty
            ? Center(child: Text('Không có công việc tuyển gấp'))
            : SizedBox(
                height: 320,
                child: GridView.builder(
                  scrollDirection: Axis.horizontal,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
                            builder: (context) => JobDetailPage(job: job),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
  }

  Widget _buildCategoriesContent(JobViewModel model) {
    return model.isBusy
        ? Center(child: CircularProgressIndicator())
        : model.categories.isEmpty
            ? Text('Không có ngành nghề nào.')
            : Container(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: model.categories.length,
                  itemBuilder: (context, index) {
                    final jobCategory = model.categories[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => JobMore(
                              showAll: false,
                              categoryId: jobCategory.id,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.grey[200],
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    model.getAppImage(),
                                    height: 60,
                                    width: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            SizedBox(
                              width: 80,
                              child: Text(
                                jobCategory.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
  }

  //
  Widget _buildVerticalDivider() {
    return SizedBox(
      height: 30,
      child: VerticalDivider(
        color: Colors.grey[500],
        thickness: 1,
        width: 20,
        indent: 5,
        endIndent: 5,
      ),
    );
  }
}
