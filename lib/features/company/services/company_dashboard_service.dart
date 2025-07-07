import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:internlog/core/theme/colors.dart';

class CompanyDashboardService {
final DioClient _dioClient = DioClient();
final DateFormat _dateFormat = DateFormat('d MMMM, yyyy');

Future<Map<String, dynamic>> fetchCompanyData() async {
try {
final userData = await _dioClient.getCurrentUser();
final companyId = userData['company_admin']?['company']?['id']?.toString();
if (companyId == null) throw Exception('Company ID not found');

final internshipsResponse = await _dioClient.get('api/internships/$companyId/list?status=approved');
final requestsResponse = await _dioClient.get('api/companies/admins/requests/');

final activeInternships = (internshipsResponse is List) ? internshipsResponse : [];
final pendingRequests = (requestsResponse is List) ? requestsResponse : [];

return {
'activeInternships': activeInternships,
'pendingRequests': pendingRequests,
};
} catch (e) {
throw Exception('Error fetching company data: $e');
}
}

Future<List<dynamic>> getSupervisors(String companyId) async {
try {
final response = await _dioClient.get('api/companies/$companyId/supervisors/');
return response is List ? response : [];
} catch (e) {
throw Exception('Error fetching supervisors: $e');
}
}

Future<void> approveRequest(int requestId, int supervisorId) async {
try {
await _dioClient.post(
'api/companies/admins/requests/approve/$requestId/',
data: {'supervisor_id': supervisorId},
);
} catch (e) {
throw Exception('Error approving request: $e');
}
}

Future<void> rejectRequest(int requestId) async {
try {
await _dioClient.post(
'api/companies/admins/requests/approve/$requestId/',
data: {'status': 'rejected'},
);
} catch (e) {
throw Exception('Error rejecting request: $e');
}
}

String formatDate(String? date) {
if (date == null || date.isEmpty) return 'Not available';
try {
final parsedDate = DateTime.parse(date);
return _dateFormat.format(parsedDate);
} catch (e) {
return 'Not available';
}
}
}
