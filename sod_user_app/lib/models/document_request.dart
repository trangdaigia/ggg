class DocumentRequest {
  int id;
  String status;
  String modelType;
  int modelId;

  DocumentRequest({
    required this.id,
    required this.status,
    required this.modelType,
    required this.modelId,
  });

  factory DocumentRequest.fromJson(Map<String, dynamic> json) {
    return DocumentRequest(
      id: json['id'] as int,
      status: json['status'] as String,
      modelType: json['model_type'] as String,
      modelId: json['model_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'model_type': modelType,
      'model_id': modelId,
    };
  }
}
