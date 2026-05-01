class AuthResponse {
  final String token;
  final String role;
  final int userId;
  final String name;

  AuthResponse({
    required this.token,
    required this.role,
    required this.userId,
    required this.name,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      role: json['role'],
      userId: json['userId'],
      name: json['name'],
    );
  }
}
