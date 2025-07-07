import '../../../core/network/dio_client.dart';

class UserProfileService {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> fetchUserData(int? userId) async {
    try {
      final Map<String, dynamic> userData;
      final bool isCurrentUser;
      String? userRole;

      if (userId != null && userId != 0) {
        // Fetch specific user by ID
        userData = await _dioClient.getUserById(userId);
        isCurrentUser = false;
      } else {
        // Fetch current user
        userData = await _dioClient.getCurrentUser();
        isCurrentUser = true;
        userRole = userData['role'];
      }

      return {
        'userData': userData,
        'isCurrentUser': isCurrentUser,
        'userRole': userRole,
      };
    } catch (e) {
      print('Failed to fetch user data: $e');
      rethrow;
    }
  }
}