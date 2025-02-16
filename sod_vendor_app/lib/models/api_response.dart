class ApiResponse {
  int get totalDataCount => _body["meta"]["total"];
  int get totalPageCount => _body["pagination"]["total_pages"];
  List get data => _body is Map ? _body["data"] ?? [] : [];
  // Just a way of saying there was no error with the request and response return
  dynamic get body => _body is Map && _body["data"]is List ? data : _body;
  bool get allGood => errors == null || errors?.length == 0;
  bool hasError() => errors != null && ((errors?.length ?? 0) > 0);
  bool hasData() => data.isNotEmpty;
  int code;
  String message;
  dynamic _body;
  List? errors;
  
  ApiResponse({
    required this.code,
    required this.message,
    dynamic body, // Constructor parameter without an underscore
    this.errors,
  }) : _body = body; // Assign to private variable

  toJson() {
    return {
      'code': code,
      'message': message,
      'body': _body,
      'errors': errors,
      'data': data
    };
  }

  factory ApiResponse.fromResponse(dynamic response) {
    //
    int code = response.statusCode;
    dynamic _body = response.data ?? null; // Would mostly be a Map
    List errors = [];
    String message = "";

    switch (code) {
      case 200:
        try {
          message = _body is Map ? (_body["message"] ?? "") : "";
        } catch (error) {
          print("Message reading error ==> $error");
        }

        break;
      default:
        message = _body["message"] ?? "";
        print(
            "ERROR ==> Whoops! Something went wrong, please contact support.");
        errors.add(message);
        break;
    }

    return ApiResponse(
      code: code,
      message: message,
      body: _body,
      errors: errors,
    );
  }
}
