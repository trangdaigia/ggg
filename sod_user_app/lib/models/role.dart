class Role {
  int id;
  String name;
  String? guardName;
  DateTime? createdAt;

  Role({
    required this.id,
    required this.name,
    this.guardName,
    this.createdAt,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as int,
      name: json['name'] as String,
      guardName: json['guard_name'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'guard_name': guardName,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
