import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/views/pages/vendor/widgets/jobs/widget/job_list_item.dart';

class ProfileDetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.primaryColor,
        actions: [
          Icon(Icons.more_vert),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfo(),
                  SizedBox(height: 16),
                  Divider(color: Colors.grey[300]),
                  SizedBox(height: 8),
                  Text(
                    'Đang hiển thị (2)',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  // _buildJobList(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 190,
          child: Column(
            children: [
              Image.asset(
                'assets/images/splash_icon.png',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 10,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 70,
                    height: 70,
                    child: Image.asset(
                      'assets/images/user.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 3,
                  right: 2,
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Trần Văn Tuấn',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 35,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5)),
                ),
                onPressed: () {},
                child: Text('+ Theo dõi', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        _buildFollowerInfo(),
        SizedBox(height: 10),
        _buildDetailRow(Icons.chat_bubble_outline, 'Tỷ lệ phản hồi chat:', ' 88% (Trong 3 giờ)'),
        SizedBox(height: 10),
        _buildDetailRow(Icons.calendar_today_outlined, 'Đã tham gia:', ' 4 năm'),
        SizedBox(height: 10),
        _buildVerificationRow(),
        SizedBox(height: 10),
        _buildDetailRow(Icons.location_on, ' Thành phố:', ' Thủ Đức, Tp Hồ Chí Minh', isBold: true),
      ],
    );
  }

  Widget _buildFollowerInfo() {
    return RichText(
      text: TextSpan(
        style: TextStyle(color: Colors.black, fontSize: 14),
        children: [
          TextSpan(text: 'Người theo dõi: '),
          TextSpan(text: '4', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: ' | Đang theo dõi: '),
          TextSpan(text: '0', style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {bool isBold = false}) {
    return Row(
      children: [
        Icon(icon, size: 18),
        SizedBox(width: 4),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 14),
            children: [
              TextSpan(text: label, style: TextStyle(fontWeight: FontWeight.normal)),
              TextSpan(text: value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationRow() {
    return Row(
      children: [
        Icon(Icons.verified_user_outlined, size: 18),
        SizedBox(width: 4),
        RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.black, fontSize: 14),
            children: [
              TextSpan(text: 'Đã xác thực: ', style: TextStyle(fontWeight: FontWeight.normal)),
              WidgetSpan(
                child: Row(
                  children: [
                    Icon(Icons.facebook, size: 18),
                    SizedBox(width: 5),
                    Icon(Icons.email, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Column(
          children: [
            SizedBox(height: 15),
            JobListItem(
              title: 'Tuyển lễ tân ca đêm biết dọn phòng',
              salary: 8 ,
              company: 'Di4l Company',
              location: 'TP.Hồ Chí Minh',
              imageUrl: 'assets/images/splash_icon.png',
              time: "4 tuần trước",
              onTap: () {
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => JobDetailPage(job: job),
                //   ),
                // );
              },
            ),
          ],
        );
      },
    );
  }
}
