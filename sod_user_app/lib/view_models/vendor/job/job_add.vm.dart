import 'package:flutter/material.dart';
import 'package:sod_user/models/job.dart';
import 'package:sod_user/requests/job.request.dart';
import 'package:sod_user/view_models/base.view_model.dart';

class JobAddViewModel extends MyBaseViewModel {
  final TextEditingController businessNameTEC = new TextEditingController();
  final TextEditingController addressTEC = new TextEditingController();
  final TextEditingController workplaceImageUploadButton =
      new TextEditingController();
  final TextEditingController jobTitleTEC = new TextEditingController();
  final TextEditingController vacancyNumberTEC = new TextEditingController();
  final TextEditingController industryDropdown = new TextEditingController();
  final TextEditingController jobTypeDropdown = new TextEditingController();
  final TextEditingController salaryMethodDropdown =
      new TextEditingController();
  final TextEditingController minSalaryTEC = new TextEditingController();
  final TextEditingController maxSalaryTEC = new TextEditingController();
  final TextEditingController jobDescriptionTEC = new TextEditingController();
  final TextEditingController minAgeTEC = new TextEditingController();
  final TextEditingController maxAgeTEC = new TextEditingController();
  final TextEditingController genderRadioGroup = new TextEditingController();
  final TextEditingController educationLevelDropdown =
      new TextEditingController();
  final TextEditingController workExperienceDropdown =
      new TextEditingController();
  final TextEditingController skillsCertificatesTEC =
      new TextEditingController();
  final TextEditingController genderCheckbox = new TextEditingController();
  final TextEditingController birthYearCheckbox = new TextEditingController();
  final TextEditingController workExperienceCheckbox =
      new TextEditingController();
  final TextEditingController educationLevelCheckbox =
      new TextEditingController();
  final TextEditingController certificationsCheckbox =
      new TextEditingController();
  final TextEditingController portraitUploadCheckbox =
      new TextEditingController();
  final TextEditingController customQuestionTEC1 = new TextEditingController();

  int jobTypeIndex = 0;

  JobRequest _jobRequest = JobRequest();

  List<Job> job = [];
  final List<String> listCategories = ['Việc làm', 'Danh mục khác'];
  final List<String> jobType = ['Cá nhân', 'Công ty'];

  late String category;
  Future<void> initialise({bool all = false}) async {
    setBusy(true);
    try {
      category = listCategories[0];

      clearErrors();
    } catch (error) {
      setError(error);
    }
    setBusy(false);
  }

  // Future<void> onPressedCreateJob(BuildContext context) async {
  //   final result = await _jobRequest.createJob({
  //     "business_name": businessNameTEC.text,
  //     "address": addressTEC.text,
  //     "job_title": jobTitleTEC.text,
  //     "vacancy_number": vacancyNumberTEC.text,
  //     "industry": industryDropdown.text,
  //     "job_type": jobTypeDropdown.text,
  //     "salary_method": salaryMethodDropdown.text,
  //     "min_salary": minSalaryTEC.text,
  //     "max_salary": maxSalaryTEC.text,
  //     "job_description": jobDescriptionTEC.text,
  //     "min_age": minAgeTEC.text,
  //     "max_age": maxAgeTEC.text,
  //     "gender": genderRadioGroup.text,
  //     "education_level": educationLevelDropdown.text,
  //     "work_experience": workExperienceDropdown.text,
  //     "skills_certificates": skillsCertificatesTEC.text,
  //     "gender_checkbox": genderCheckbox.text,
  //     "birth_year_checkbox": birthYearCheckbox.text,
  //     "work_experience_checkbox": workExperienceCheckbox.text,
  //     "education_level_checkbox": educationLevelCheckbox.text,
  //     "certifications_checkbox": certificationsCheckbox.text,
  //     "portrait_upload_checkbox": portraitUploadCheckbox.text,
  //   });

  //   if (result.allGood) {
  //     Navigator.pop(context);
  //   } else {
  //     setError(result.message!);
  //   }
  // }

  void onChangeCategory(String value) {
    category = value;
    notifyListeners();
  }

  void setJobTypeIndex(int index) {
    jobTypeIndex = index;
    notifyListeners();
  }

  String getTitleBusinessName() {
    return jobType[jobTypeIndex] == 'Công ty'
        ? 'Tên công ty *'
        : 'Tên hộ kinh doanh *';
  }
}
