import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioClient {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Map<String, dynamic>? _currentUser;

  FlutterSecureStorage get storage => _storage;

  DioClient() {
    _dio.options.baseUrl = 'http://10.111.147.152:8000/';
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

        // Enhanced logging for form data
        if (options.data != null) {
          if (options.data is FormData) {
            print('FormData fields: ${(options.data as FormData).fields.map((e) => '${e.key}: ${e.value}')}');
            print('FormData files: ${(options.data as FormData).files.map((e) => '${e.key}: ${e.value.filename}')}');
          } else {
            print('Data: ${options.data}');
          }
        }

        return handler.next(options);
      },
      onError: (error, handler) async {
        print('Error: ${error.message} Response: ${error.response?.data}');
        if (error.response?.statusCode == 401) {
          // Try to refresh token
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry the original request with new token
            final token = await _storage.read(key: 'access_token');
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            final response = await _dio.fetch(error.requestOptions);
            return handler.resolve(response);
          } else {
            // Refresh failed, clear tokens
            await clearTokens();
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await _dio.post('api/auth/token/refresh/', data: {
        'refresh': refreshToken,
      });

      await _storage.write(key: 'access_token', value: response.data['access']);

      // If refresh token is also returned, update it
      if (response.data['refresh'] != null) {
        await _storage.write(key: 'refresh_token', value: response.data['refresh']);
      }

      return true;
    } catch (e) {
      print('Token refresh failed: $e');
      return false;
    }
  }

// Add this to your DioClient class in dio_client.dart
  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
      _dio.options.headers.remove('Authorization');
      _currentUser = null; // Clear cached user
      print('All tokens and user data cleared successfully');
    } catch (e) {
      print('Error clearing tokens: $e');
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
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

      // Store refresh token if provided
      if (response.data['refresh'] != null) {
        await _storage.write(key: 'refresh_token', value: response.data['refresh']);
      }
    } on DioException catch (e) {
      print('Register Error Response: ${e.response?.data}');
      throw e.response?.data ?? {'error': 'Registration failed'};
    }
  }

  Future<Map<String, dynamic>> getHeaders() async {
    final token = await _storage.read(key: 'access_token');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
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

      // Store refresh token if provided
      if (response.data['refresh'] != null) {
        await _storage.write(key: 'refresh_token', value: response.data['refresh']);
      }

      _dio.options.headers['Authorization'] = 'Bearer $token';

      // Fetch user data to check supervisor status
      final userResponse = await _dio.get('api/auth/me');
      final userData = userResponse.data;
      if (userData['role'] == 'supervisor' && userData['supervisor'] != null) {
        final status = userData['supervisor']['status'];
        if (status == 'pending' || status == 'rejected') {
          // Clear token to prevent unauthorized access
          await clearTokens();
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

  Future<Map<String, dynamic>> getUserById(int userId) async {
    try {
      final response = await _dio.get('api/users/$userId');
      return response.data;
    } on DioException catch (e) {
      print('Get User Error Response: ${e.response?.data}');
      throw e.response?.data['error'] ?? 'Failed to fetch user data';
    }
  }

  Future<int?> getCurrentUserId() async {
    try {
      if (_currentUser != null) return _currentUser!['id'] as int?;

      final response = await _dio.get('api/auth/me');
      _currentUser = response.data;
      return _currentUser!['id'] as int?;
    } on DioException catch (e) {
      print('Get Current User ID Error: ${e.response?.data}');
      return null;
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    if (_currentUser != null) return _currentUser!;

    try {
      final response = await _dio.get('api/auth/me');
      _currentUser = response.data;
      return _currentUser!;
    } on DioException catch (e) {
      print('Current User Error Response: ${e.response?.data}');
      throw e.response?.data['error'] ?? 'Failed to get user data';
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _dio.get(endpoint);
      print('GET Response for $endpoint: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('GET Error for $endpoint: ${e.response?.data}');
      throw e.response?.data ?? {'error': 'Failed to fetch data'};
    }
  }

  Future<dynamic> patch(String path, {dynamic data}) async {
    try {
      Options options;
      if (data is FormData) {
        // For form data (file uploads), let Dio handle the content type
        options = Options(
          headers: await getHeaders(),
        );
      } else {
        // For regular JSON data
        options = Options(
          headers: await getHeaders(),
          contentType: 'application/json',
        );
      }

      final response = await _dio.patch(
        path,
        data: data,
        options: options,
      );
      print('PATCH Response for $path: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('PATCH Error Response for $path: ${e.response?.data}');
      throw e;
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      Options options;
      if (data is FormData) {
        // For form data (file uploads), let Dio handle the content type
        options = Options(
          headers: await getHeaders(),
        );
      } else {
        // For regular JSON data
        options = Options(
          headers: await getHeaders(),
          contentType: 'application/json',
        );
      }

      final response = await _dio.post(
        path,
        data: data,
        options: options,
      );
      print('POST Response for $path: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('POST Error Response: ${e.response?.data}');
      throw e;
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

  Future<List<dynamic>> getInternships({String? status}) async {
    try {
      final response = await _dio.get(
        'api/internships/list',
        queryParameters: status != null ? {'status': status} : null,
      );

      // Ensure the response is a List
      if (response.data is List) {
        return response.data;
      }

      throw 'Unexpected response format';
    } on DioException catch (e) {
      print('Get Internships Error Response: ${e.response?.data}');
      throw e.response?.data['error'] ?? 'Failed to fetch internships';
    }
  }

  Future<Map<String, dynamic>> getLogbook(int logbookId) async {
    try {
      final response = await _dio.get('api/logbooks/$logbookId/');
      return response.data;
    } on DioException catch (e) {
      print('Get Logbook Error Response: ${e.response?.data}');
      if (e.response?.statusCode == 404) {
        throw 'Logbook not found';
      }
      throw e.response?.data['error'] ?? 'Failed to fetch logbook';
    }
  }

  Future<Map<String, dynamic>> getOngoingLogbook(int internshipId) async {
    try {
      final response = await _dio.get('api/logbooks/$internshipId/ongoing/');
      return response.data;
    } on DioException catch (e) {
      print('Get Ongoing Logbook Error Response: ${e.response?.data}');
      if (e.response?.statusCode == 403) {
        throw 'Only students can access their logbooks.';
      } else if (e.response?.statusCode == 404) {
        throw 'No ongoing logbook found for this internship.';
      }
      throw e.response?.data['error'] ?? 'Failed to fetch ongoing logbook';
    }
  }

  Future<Map<String, dynamic>> getOngoingInternship() async {
    try {
      final response = await _dio.get('api/internships/ongoing/');
      return response.data;
    } on DioException catch (e) {
      print('Get Ongoing Internship Error Response: ${e.response?.data}');
      if (e.response?.statusCode == 403) {
        throw 'Only students can access their ongoing internship.';
      } else if (e.response?.statusCode == 404) {
        throw 'No ongoing internship found for this student.';
      }
      throw e.response?.data['error'] ?? 'Failed to fetch ongoing internship';
    }
  }

  Future<List<dynamic>> getAssignedStudents() async {
    try {
      final response = await _dio.get('api/supervisors/assigned-students/');
      return response.data;
    } on DioException catch (e) {
      print('Get Assigned Students Error Response: ${e.response?.data}');
      throw e.response?.data['error'] ?? 'Failed to fetch assigned students';
    }
  }

  Future<List<dynamic>> getRecentActivities() async {
    try {
      final response = await _dio.get('api/supervisors/assigned-students/activity/');
      return response.data;
    } on DioException catch (e) {
      print('Get Recent Activities Error Response: ${e.response?.data}');
      throw e.response?.data['error'] ?? 'Failed to fetch recent activities';
    }
  }

  Future<void> createWeeklyLog(int logbookId) async {
    try {
      await _dio.post('api/logbooks/$logbookId/create-week/');
    } on DioException catch (e) {
      print('Create Weekly Log Error: ${e.response?.data}');
      throw e.response?.data['error'] ?? 'Failed to create weekly log';
    }
  }

  Future<String?> logout(String refreshToken) async {
    try {
      final response = await _dio.post(
        'api/auth/logout/',
        data: {'refresh': refreshToken},
      );

      // Success case
      if (response.statusCode == 205) {
        return null; // No error, logout successful
      }

      // Handle unexpected status codes
      return 'Logout failed. Please try again.';
    } on DioException catch (e) {
      // Handle Dio-specific errors
      if (e.response != null) {
        final data = e.response?.data;
        if (data is Map && data.containsKey('error')) {
          return data['error'] as String;
        }

        switch (e.response?.statusCode) {
          case 400:
            return 'Invalid session. Please login again.';
          case 401:
            return 'Session expired. Please login again.';
          case 500:
            return 'Server error. Please try again later.';
          default:
            return 'Logout failed. Please try again.';
        }
      } else {
        return 'Network error. Please check your connection.';
      }
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    } finally {
      await clearTokens(); // Always clear local tokens
    }
  }
}