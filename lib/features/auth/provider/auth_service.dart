import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../model/auth_model.dart';

class AuthService {
  // Login
  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Token save karo
      await StorageService.saveToken(authResponse.token);

      return authResponse;
    } on DioException catch (e) {
      // Server se jo message aaye vo dikhao
      final message = e.response?.data?['message'] ?? 'Login failed';
      throw Exception(message);
    }
  }

  // Register
  Future<AuthResponse> register(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      final response = await ApiClient.dio.post(
        '/auth/register',
        data: {'fullName': fullName, 'email': email, 'password': password},
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await StorageService.saveToken(authResponse.token);
      return authResponse;
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ?? 'Registration failed';
      throw Exception(message);
    }
  }

  // Logout
  Future<void> logout() async {
    await StorageService.clearAll();
  }
}
