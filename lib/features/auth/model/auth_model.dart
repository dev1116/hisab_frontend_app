class AuthResponse {
  final String token;
  final String email;
  final String fullName;
  final int userId;

  AuthResponse({
    required this.token,
    required this.email,
    required this.fullName,
    required this.userId,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return AuthResponse(
      token: data['token'],
      email: data['email'],
      fullName: data['fullName'],
      userId: data['userId'],
    );
  }
}
