class LoginResponseModel {
  final String? token;
  final String? error;

  LoginResponseModel({
    this.token,
    this.error,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json['token'] as String?,
      error: json['error'] as String?,
    );
  }

  bool get isSuccess => token != null && error == null;
}
