import 'package:flutter/material.dart';
import 'package:sod_user/constants/app_colors.dart';
import 'package:sod_user/view_models/vendor/job/job_add.vm.dart';
import 'package:stacked/stacked.dart';

import 'package:velocity_x/velocity_x.dart';

class JobAddPage extends StatefulWidget {
  JobAddPage({Key? key}) : super(key: key);

  @override
  _JobAddPageState createState() => _JobAddPageState();
}

class _JobAddPageState extends State<JobAddPage> {
  String selectedCategory = 'Việc làm';
  String selectedJobType = 'Cá nhân';
  String selectedGender = 'Không yêu cầu';
  String? selectedIndustry;

  bool requireGender = false;
  bool requireBirthDate = false;
  bool requireExperience = false;
  bool requireEducation = false;
  bool requireCertificate = false;
  bool requirePhoto = false;

  List<TextEditingController> questionControllers = [TextEditingController()];

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<JobAddViewModel>.reactive(
      viewModelBuilder: () => JobAddViewModel(),
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColor.primaryColor,
            title: Text('Đăng tin',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            centerTitle: true,
            leading: IconButton(
              icon: Icon(Icons.close, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Danh mục
                      _buildDropdownField(
                        label: 'Danh mục *',
                        value: selectedCategory,
                        items: vm.listCategories,
                        onChanged: (value) => vm.onChangeCategory(value!),
                      ),
                      SizedBox(height: 16),

                      // Loại người đăng
                      Text('Bạn là *',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.5))),
                      SizedBox(height: 8),
                      Row(
                        children: vm.jobType.asMap().entries.map(
                          (entry) {
                            int index = entry.key;
                            String item = entry.value;

                            return _buildJobTypeButton(
                              type: item,
                              isSelected: vm.jobTypeIndex == index,
                              onPressed: () => vm.setJobTypeIndex(index),
                            ).pOnly(right: 8);
                          },
                        ).toList(),
                      ),

                      SizedBox(height: 20),

                      // Tên hộ kinh doanh
                      _buildTEC(
                        labelText: vm.getTitleBusinessName(),
                        controller: vm.businessNameTEC,
                      ),
                      SizedBox(height: 20),

                      // Địa chỉ
                      _buildTEC(
                        labelText: 'Địa chỉ *',
                        controller: vm.addressTEC,
                      ),
                      SizedBox(height: 20),

                      // Hình nơi làm việc
                      if (selectedJobType == 'Công ty')
                        Column(
                          children: [
                            _buildImageUploader('Hình logo',
                                'Hình có kích thước tối thiểu 240x240'),
                            SizedBox(height: 16),
                          ],
                        ),
                      _buildImageUploader(
                          'Hình nơi làm việc', 'Đăng từ 1 đến 6 tấm hình'),
                      SizedBox(height: 20),

                      // Tiêu đề tin đăng
                      _buildTEC(
                        labelText: 'Tiêu đề tin đăng *',
                        controller: vm.jobTitleTEC,
                      ),
                      SizedBox(height: 20),

                      // Số lượng tuyển dụng
                      _buildTEC(
                        labelText: 'Số lượng tuyển dụng *',
                        isNumber: true,
                        controller: vm.vacancyNumberTEC,
                      ),
                      SizedBox(height: 20),

                      // Ngành nghề
                      _buildDropdownField(
                        label: 'Ngành nghề *',
                        value: selectedIndustry,
                        items: [
                          'Ngành nghề 1',
                          'Ngành nghề 2',
                          'Ngành nghề khác'
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedIndustry = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),

                      // Loại công việc
                      _buildDropdownField(
                        label: 'Loại công việc *',
                        value: selectedIndustry,
                        items: ['Công việc 1', 'Công việc 2', 'Công việc khác'],
                        onChanged: (value) {
                          setState(() {
                            selectedIndustry = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),

                      // Hình thức trả lương
                      _buildDropdownField(
                        label: 'Hình thức trả lương *',
                        value: selectedIndustry,
                        items: [
                          'Hình thức trả lương 1',
                          'Hình thức trả lương 2',
                          'Hình thức trả lương khác'
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedIndustry = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),

                      // Lương tối thiểu và tối đa
                      Row(
                        children: [
                          Expanded(
                            child: _buildTEC(
                              labelText: 'Lương tối thiểu',
                              controller: vm.minSalaryTEC,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTEC(
                              labelText: 'Lương tối đa',
                              controller: vm.maxSalaryTEC,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Job Description with Dashed Red Border
                      _buildDashedBorderInput(
                          label: 'Mô tả công việc *',
                          hintText: 'Mô tả chi tiết...',
                          controller: vm.jobDescriptionTEC),
                      SizedBox(height: 20),

                      // Độ tuổi tối thiểu và tối đa
                      Row(
                        children: [
                          Expanded(
                            child: _buildTEC(
                              labelText: 'Độ tuổi tối thiểu',
                              controller: vm.maxAgeTEC,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: _buildTEC(
                              labelText: 'Độ tuổi tối đa',
                              controller: vm.minAgeTEC,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Giới tính
                      Text('Giới tính *',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.black.withOpacity(0.5))),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          _buildGenderButton('Không yêu cầu'),
                          SizedBox(width: 8),
                          _buildGenderButton('Nam'),
                          SizedBox(width: 8),
                          _buildGenderButton('Nữ'),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Trình độ học vấn
                      _buildDropdownField(
                        label: 'Trình độ học vấn *',
                        value: selectedIndustry,
                        items: [
                          'Trình độ học vấn 1',
                          'Trình độ học vấn 2',
                          'Trình độ học vấn khác'
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedIndustry = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),

                      // Kinh nghiệm làm việc
                      _buildDropdownField(
                        label: 'Kinh nghiệm làm việc *',
                        value: selectedIndustry,
                        items: [
                          'Kinh nghiệm làm việc 1',
                          'Kinh nghiệm làm việc 2',
                          'Kinh nghiệm làm việc khác'
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedIndustry = value;
                          });
                        },
                      ),
                      SizedBox(height: 20),

                      // Chứng chỉ , ...
                      _buildDashedBorderInput(
                        label: "",
                        showLabel: false,
                        hintText: "Chứng chỉ, kỹ năng, tính cách...",
                        controller: vm.skillsCertificatesTEC,
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                //
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CHỌN THÔNG TIN ỨNG VIÊN CẦN CUNG CẤP KHI ỨNG TUYỂN',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 8),
                      _buildCustomCheckbox(
                        title: 'Giới tính',
                        value: requireGender,
                        onChanged: (value) {
                          setState(() {
                            requireGender = value!;
                          });
                        },
                      ),
                      _buildCustomCheckbox(
                        title: 'Năm sinh',
                        value: requireBirthDate,
                        onChanged: (value) {
                          setState(() {
                            requireBirthDate = value!;
                          });
                        },
                      ),
                      _buildCustomCheckbox(
                        title: 'Kinh nghiệm làm việc',
                        value: requireExperience,
                        onChanged: (value) {
                          setState(() {
                            requireExperience = value!;
                          });
                        },
                      ),
                      _buildCustomCheckbox(
                        title: 'Trình độ học vấn',
                        value: requireEducation,
                        onChanged: (value) {
                          setState(() {
                            requireEducation = value!;
                          });
                        },
                      ),
                      _buildCustomCheckbox(
                        title: 'Bằng cấp chứng chỉ',
                        value: requireCertificate,
                        onChanged: (value) {
                          setState(() {
                            requireCertificate = value!;
                          });
                        },
                      ),
                      _buildCustomCheckbox(
                        title: 'Yêu cầu ứng viên tải ảnh chân dung (JPG, PNG)',
                        value: requirePhoto,
                        onChanged: (value) {
                          setState(() {
                            requirePhoto = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'THÔNG TIN KHÁC CẦN ỨNG VIÊN CUNG CẤP KHI ỨNG TUYỂN',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.black.withOpacity(0.5)),
                      ),
                      const SizedBox(height: 8),
                      // Hiển thị danh sách câu hỏi tùy chỉnh
                      ...List<Widget>.generate(questionControllers.length,
                          (index) {
                        return _buildDashedBorderInput(
                            label: 'Câu hỏi ${index + 1}',
                            hintText: 'Nhập câu hỏi...',
                            showLabel: true,
                            controller: vm.customQuestionTEC1);
                      }),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              questionControllers.add(TextEditingController());
                            });
                          },
                          child: const Text(
                            'Thêm câu hỏi',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5)),
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          'Xem trước',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          'Đăng tin',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //
  Widget _buildGenderButton(String gender) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            selectedGender == gender ? AppColor.primaryColor : Colors.grey[300],
        foregroundColor: selectedGender == gender ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: Text(gender),
    );
  }

  //
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    double height = 50, // Thêm biến điều chỉnh độ cao
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black.withOpacity(0.5),
          ),
        ),
        SizedBox(height: 8),
        SizedBox(
          height: height,
          child: DropdownButtonFormField<String>(
            value: value,
            items: items
                .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 15),
                      ),
                    ))
                .toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  //
  Widget _buildTEC({
    required String labelText,
    bool isNumber = false,
    int? maxLength,
    required TextEditingController controller,
  }) {
    return SizedBox(
      height: 50,
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(fontSize: 13),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  //
  Widget _buildImageUploader(String title, String subTitle) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColor.primaryColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(Icons.image, color: AppColor.primaryColor),
          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            decoration: BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius: BorderRadius.circular(5)),
            child: Text(
              title,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(height: 5),
          Text(
            subTitle,
            style: TextStyle(
                color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  //
  Widget _buildJobTypeButton(
      {required String type,
      required Function onPressed,
      required bool isSelected}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isSelected ? AppColor.primaryColor : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: () => onPressed(),
      child: Text(type),
    );
  }

  //
  Widget _buildCustomCheckbox({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }

  //
  Widget _buildDashedBorderInput({
    required String label,
    required String hintText,
    bool showLabel = true,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        SizedBox(height: 8),
        Container(
          decoration: ShapeDecoration(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: BorderSide(
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
          ),
          child: TextField(
            maxLength: 1500,
            maxLines: 5,
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }
}
