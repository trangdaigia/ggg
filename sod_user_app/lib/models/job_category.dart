class JobCategory {
  final int id;
  final String name;

  JobCategory({required this.id, required this.name});

  factory JobCategory.fromJson(Map<String, dynamic> json) {
    return JobCategory(
      id: json['id'],
      name: json['name'],
    );
  }
}
