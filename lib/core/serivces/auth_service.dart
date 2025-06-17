import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    if (token == null) return false;

    _dio.options.headers['Authorization'] = 'Bearer $token';
    return true;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    _dio.options.headers.remove('Authorization');
  }
}