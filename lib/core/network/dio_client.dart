import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  FlutterSecureStorage get storage => _storage;

  DioClient() {
    _dio.options.baseUrl = 'http://10.140.91.152:8000/';
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (!options.path.contains('login') && !options.path.contains('register')) {
          print('Request: ${options.method} ${options.uri}');
        } else {
          print('Request: ${options.method} ${options.uri}');
        }
        final token = await _storage.read(key: 'access_token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (error, handler) async {
        print('Error: ${error.message} Response: ${error.response?.data}');
        if (error.response?.statusCode == 401) {
          // TODO: Handle token refresh if needed
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String contact,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post('api/auth/register/', data: {
        'full_name': fullName,
        'email': email,
        'contact': contact,
        'password': password,
        'confirm_password': confirmPassword,
      });
      await _storage.write(key: 'access_token', value: response.data['access']);
    } on DioException catch (e) {
      print('Register Error Response: ${e.response?.data}');
      throw e.response?.data ?? {'error': 'Registration failed'};
    }
  }

  Future<void> login(String email, String password) async {
    try {
      // Perform login
      final response = await _dio.post('api/auth/login/', data: {
        'email': email,
        'password': password,
      });
      final token = response.data['access'];
      await _storage.write(key: 'access_token', value: token);

      // Fetch user data to check supervisor status
      final userResponse = await _dio.get('api/auth/me');
      final userData = userResponse.data;
      if (userData['role'] == 'supervisor' && userData['supervisor'] != null) {
        final status = userData['supervisor']['status'];
        if (status == 'pending' || status == 'rejected') {
          // Clear token to prevent unauthorized access
          await _storage.delete(key: 'access_token');
          throw Exception(
              'The company is yet to approve your status as a supervisor from that company.');
        }
      }
    } on DioException catch (e) {
      print('Login Error Response: ${e.response?.data}');
      throw e.response?.data['error'] ?? 'Login failed';
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get('api/auth/me');
      return response.data;
    } on DioException catch (e) {
      print('Current User Error Response: ${e.response?.data}');
      throw e.response?.data['error'] ?? 'Failed to get user data';
    }
  }

  Future<List<dynamic>> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      return response.data;
    } on DioException catch (e) {
      print('GET Error Response: ${e.response?.data}');
      throw e.response?.data['error'] ?? 'Failed to fetch data';
    }
  }

  Future<void> selectRole({
    required String role,
    String? matriculeNum,
    int? departmentId,
    int? companyId,
  }) async {
    try {
      final data = {'role': role};
      if (role == 'student') {
        if (matriculeNum == null) throw Exception('Matricule number is required for student role');
        data['matricule_num'] = matriculeNum;
        if (departmentId == null) throw Exception('Department ID is required for student role');
        data['department_id'] = departmentId.toString();
      } else if (role == 'supervisor') {
        if (companyId == null) throw Exception('Company ID is required for supervisor role');
        data['company_id'] = companyId.toString();
      }
      final response = await _dio.post('api/auth/select-role/', data: data);
      print('Role Selection Response: ${response.data}');
    } on DioException catch (e) {
      print('Role Selection Error Response: ${e.response?.data}');
      throw e.response?.data['error'] ?? 'Role selection failed';
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('api/auth/logout/');
    } catch (e) {
      print('Logout Error: $e');
    } finally {
      await _storage.delete(key: 'access_token');
    }
  }
}