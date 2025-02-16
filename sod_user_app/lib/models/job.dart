class Job {
  final int id;
  final String name;
  final String company;
  final String location;
  final int salary;
  final String imageUrl;
  final String phone;
  final String description;
  final int adsCategoryId;
  final String adsCategoryName;
  final String formattedDateTime;
  final DateTime createdAt; // Thay đổi kiểu dữ liệu

  Job({
    required this.id,
    required this.name,
    required this.company,
    required this.location,
    required this.salary,
    required this.imageUrl,
    required this.phone,
    required this.description,
    required this.adsCategoryId,
    required this.adsCategoryName,
    required this.formattedDateTime,
    required this.createdAt, // Cập nhật
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      name: json['name'],
      company: json['company'],
      location: json['location'],
      salary: json['salary'],
      imageUrl: json['ads_category_id ']['photo'],
      phone: json['phone'],
      description: json['description'],
      adsCategoryId: json['ads_category_id ']['id'],
      adsCategoryName: json['ads_category_id ']['name'],
      formattedDateTime: json['ads_category_id ']['formatted_date_time'],
      createdAt: DateTime.parse(json['ads_category_id ']
          ['created_at']), // Chuyển đổi chuỗi thành DateTime
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company': company,
      'location': location,
      'salary': salary,
      'imageUrl': imageUrl,
      'phone': phone,
      'description': description,
      'adsCategoryId': adsCategoryId,
      'adsCategoryName': adsCategoryName,
      'formattedDateTime': formattedDateTime,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
