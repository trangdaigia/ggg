import 'package:flutter/material.dart';

class JobListItem extends StatelessWidget {
  final String title;
  final int salary;
  final String company;
  final String location;
  final String imageUrl;
  final bool isUrgent;
  final bool isRecent;
  final String time;
  final String km;
  final VoidCallback onTap;
  final double widthImage;
  final double heightImage;

  const JobListItem({
    required this.title,
    required this.salary,
    required this.company,
    required this.location,
    required this.imageUrl,
    this.time = "",
    this.km = "",
    required this.onTap,
    this.isUrgent = false,
    this.isRecent = false,
    this.widthImage = 100,
    this.heightImage = 100,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String getCity(String location) {
      // Kiểm tra nếu chuỗi chứa "Việt Nam"
      int vietnamIndex = location.lastIndexOf(', Việt Nam');

      if (vietnamIndex != -1) {
        // Lấy phần chuỗi đứng trước "Việt Nam"
        String beforeVietnam = location.substring(0, vietnamIndex);
        int cityIndex = beforeVietnam.lastIndexOf(', ');

        // Nếu tìm thấy dấu phẩy trước "Việt Nam", trả về phần sau dấu phẩy đó
        if (cityIndex != -1) {
          return beforeVietnam.substring(cityIndex + 2);
        }
      }

      // Nếu không tìm thấy "Việt Nam", lấy phần cuối của chuỗi
      List<String> parts = location.split(', ');
      return parts.isNotEmpty ? parts.last : location;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: Colors.grey.shade400)),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  if (isUrgent || isRecent)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            imageUrl,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                children: [
                                  Icon(
                                    isUrgent
                                        ? Icons.local_fire_department
                                        : Icons.new_releases_rounded,
                                    color: Colors.orange,
                                    size: 15,
                                  ),
                                  Text(
                                    isUrgent ? 'Gấp' : 'New',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đến ${salary ~/ 1000000} triệu/tháng',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.business,
                                color: Colors.grey[600], size: 20),
                            SizedBox(width: 5),
                            Text(
                              company,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Row(
                          children: [
                            Icon(Icons.location_pin,
                                color: Colors.grey[600], size: 20),
                            SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                getCity(location),
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(
                          time,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
