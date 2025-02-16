import 'package:flutter/material.dart';

class ApplicationFormModal extends StatelessWidget {
  final bool isBasicInformation;

  const ApplicationFormModal({Key? key, this.isBasicInformation = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isBasicInformation ? MediaQuery.of(context).size.height * 0.5 : MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Thông tin ứng tuyển',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Divider(color: Colors.grey.withOpacity(0.2)),
            SizedBox(height: 10),

            // Chỉ hiện thông tin cơ bản khi isBasicInformation = true
            if (!isBasicInformation)
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/user.png'),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.grey,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            if (!isBasicInformation) ...[
              SizedBox(height: 10),
              Center(
                child: Text(
                  'Hãy tải lên ảnh chân dung rõ nét, chất lượng tốt của bạn. (Yêu cầu từ NTD)',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              SizedBox(height: 20),
            ],

            // Thông tin cá nhân
            Text(
              'Thông tin cá nhân',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            _buildTextField('Họ tên *'),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildTextField('Số điện thoại *'),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: _buildTextField('Năm sinh *'),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildTextField('Địa điểm mong muốn làm việc *'),
            SizedBox(height: 20),
            _buildTextField('Ngành nghề làm việc mong muốn *'),
            SizedBox(height: 25),

            // Thông tin kinh nghiệm chỉ hiện nếu isBasicInformation = false
            if (!isBasicInformation) ...[
              Text(
                'Kinh nghiệm làm việc',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              _buildTextField('Tên công ty / Nơi làm việc'),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField('Từ năm'),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildTextField('Đến năm'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildTextField('Mô tả công ty'),
              SizedBox(height: 25),
            ],

            // Nút nộp thông tin
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Nộp thông tin ứng tuyển',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
