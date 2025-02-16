import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/models/job.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/application_form_modal.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/bottom_appbar_item.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_card_similar.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/profile_detail_page.dart';

class JobDetailPage extends StatefulWidget {
  JobDetailPage(
      {Key? key,
      required this.job,
      this.isLastest = false,
      this.showBanner = true})
      : super(key: key);
  final Job job;
  final bool isLastest;
  final bool showBanner;

  @override
  _JobListItem createState() => _JobListItem();
}

class _JobListItem extends State<JobDetailPage> {
  String timeAgo(String? dateTimeString) {
    if (dateTimeString == null) {
      return 'Không rõ';
    }

    DateTime dateTime = DateFormat('yyyy-MM-dd HH:mm:ss').parse(dateTimeString);
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

  var currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                Image(
                  image: NetworkImage(widget.job.imageUrl),
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                if (widget.showBanner)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(5),
                              bottomRight: Radius.circular(5))),
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 15),
                        child: Row(
                          children: [
                            Icon(
                              widget.isLastest
                                  ? Icons.new_releases_rounded
                                  : Icons.local_fire_department,
                              color: Colors.orange,
                              size: 25,
                            ),
                            Text(
                              widget.isLastest ? "New" : "Gấp",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    widget.job.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),

                  //
                  Row(
                    children: [
                      Text(
                        'Đến ${currencyFormatter.format(widget.job.salary)}đ/tháng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                          fontSize: 15,
                        ),
                      ),
                      // Text('12.000.000 ',
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.red,
                      //         fontSize: 15)),
                      // Text('đ/tháng',
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.bold,
                      //         color: Colors.red,
                      //         fontSize: 15)),
                      Spacer(),
                      // favorite
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.red)),
                        child: Row(
                          children: [
                            Text(
                              'Lưu tin',
                              style: TextStyle(color: Colors.red, fontSize: 13),
                            ),
                            SizedBox(width: 5),
                            Icon(Icons.favorite_border_outlined,
                                size: 17, color: Colors.red)
                          ],
                        ),
                      )
                    ],
                  ),

                  Text(timeAgo(widget.job.createdAt?.toString()),
                      style: TextStyle(color: Colors.grey)),

                  // Company
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          widget.job.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.house,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    widget.job.company,
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.blue),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_pin,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    widget.job.location,
                                    style: TextStyle(fontSize: 13),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Divider(color: Colors.grey[200]),
                  SizedBox(height: 5),

                  //
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/user.png',
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          Text('Trần Văn Tuấn',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                'Hoạt động 1 ngày trước',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileDetailPage(),
                            ),
                          );
                        },
                        child: Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.orange)),
                          child: Row(
                            children: [
                              Text(
                                'Xem trang',
                                style: TextStyle(
                                    color: Colors.orange, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 15),

                  //
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoColumn('Công ty', Icons.work),
                      _buildVerticalDivider(),
                      _buildInfoColumn('Đánh giá', Icons.more_horiz),
                      _buildVerticalDivider(),
                      _buildInfoColumn('Phản hồi chat', null, '92%'),
                    ],
                  ),

                  SizedBox(height: 5),
                  Divider(color: Colors.grey[200]),
                  SizedBox(height: 5),

                  Text('Thông tin tuyển dụng',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: Html(
                      data: widget.job.description,
                    ),
                  ),

                  SizedBox(height: 5),
                  Text.rich(
                    TextSpan(
                      text: 'Liên hệ ngay: ${widget.job.phone}',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hình thức trả lương
                      _buildInfoRow(
                        Icons.attach_money,
                        'Hình thức trả lương: Lương khoán',
                      ),
                      SizedBox(height: 15),

                      // Loại công việc
                      _buildInfoRow(
                        Icons.access_time,
                        'Loại công việc: Toàn thời gian',
                      ),
                      SizedBox(height: 15),

                      // Nghành
                      _buildInfoRow(
                        Icons.business_center,
                        'Ngành nghề: Nhân viên kinh doanh',
                      ),
                      SizedBox(height: 15),
                      _buildInfoRow(
                        Icons.accessibility,
                        'Giới tính: Không yêu cầu',
                      ),
                      SizedBox(height: 15),

                      // Tên công ty
                      _buildInfoRow(
                        Icons.business,
                        'Tên công ty: Công ty TNHH Di4l',
                        isExpanded: true,
                      ),

                      // Số lượng tuyển dụng
                      SizedBox(height: 15),
                      _buildInfoRow(
                        Icons.people,
                        'Số lượng tuyển dụng: 2',
                      ),
                      SizedBox(height: 15),

                      // Học vấn
                      _buildInfoRow(
                        Icons.school,
                        'Học vấn tối thiểu: Cấp 3',
                      ),
                      SizedBox(height: 15),

                      // Chứng chỉ
                      _buildInfoRow(
                        Icons.star,
                        'Chứng chỉ / kỹ năng: Giao Tiếp tốt\nXử lý tình huống nhanh nhạy...',
                        isExpanded: true,
                        maxLines: 2,
                      ),
                      SizedBox(height: 15),

                      // Tuổi
                      _buildInfoRow(Icons.cake, 'Tuổi tối thiểu: 22'),
                      SizedBox(height: 15),
                      _buildInfoRow(Icons.cake, 'Tuổi tối đa: 33'),
                    ],
                  ),
                  SizedBox(height: 20),

                  //
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Title
                          Text(
                            'Có thắc mắc về công việc này?',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 10),

                          // Subtitle
                          Text(
                            'Hãy để lại số điện thoại để nhà tuyển dụng có thể gọi lại cho bạn và trao đổi kỹ hơn nhé!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 20),

                          // Name TextField
                          _buildTextField('Họ tên'),
                          SizedBox(height: 15),
                          _buildTextField('Số điện thoại', isPhone: true),
                          SizedBox(height: 20),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  padding: EdgeInsets.symmetric(horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5))),
                              child: Text('Để lại thông tin',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  //
                  Text(
                    'Các bài đăng tương tự',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 5),

                  JobCardSimilar(currentJobId: widget.job.id),
                  SizedBox(height: 5),
                  Divider(
                    color: Colors.grey[200],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Xem tất cả',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 15,
                        color: AppColor.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
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
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Gọi điện button
              BottomAppBarItem(
                icon: Icons.phone,
                label: 'Gọi điện',
                onPressed: () {
                  // Xử lý khi nhấn nút gọi điện
                },
              ),
              _buildVerticalDivider(),

              // Chat button
              BottomAppBarItem(
                icon: Icons.chat,
                label: 'Chat',
                onPressed: () {
                  // Xử lý khi nhấn nút chat
                },
              ),
              _buildVerticalDivider(),

              // Ứng tuyển button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 15),
                ),
                onPressed: () {
                  showApplicationFormModal(context);
                },
                icon: Icon(Icons.assignment_ind, color: Colors.white),
                label: Text(
                  'Ứng tuyển',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showApplicationFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ApplicationFormModal();
      },
    );
  }

  //
  Widget _buildInfoColumn(String title, IconData? icon, [String? value]) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey, fontSize: 13),
        ),
        SizedBox(height: 5),
        if (icon != null)
          Icon(icon, size: 15)
        else if (value != null)
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
      ],
    );
  }

  //
  Widget _buildVerticalDivider() {
    return SizedBox(
      height: 30,
      child: VerticalDivider(
        color: Colors.grey,
        thickness: 1,
        width: 20,
        indent: 5,
        endIndent: 5,
      ),
    );
  }

  //
  Widget _buildInfoRow(IconData icon, String text,
      {bool isExpanded = false, int? maxLines}) {
    return Row(
      children: [
        Icon(icon),
        SizedBox(width: 10),
        if (isExpanded)
          Expanded(
            child: Text(
              text,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(text),
      ],
    );
  }

  //
  Widget _buildTextField(String label, {bool isPhone = false}) {
    return SizedBox(
      height: 45,
      child: TextField(
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 13),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
