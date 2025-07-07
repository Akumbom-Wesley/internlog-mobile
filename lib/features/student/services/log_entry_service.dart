import 'package:dio/dio.dart';
import 'package:internlog/core/network/dio_client.dart';
import '../widgets/logentry_helpers.dart';

class LogEntryService {
  final DioClient _dioClient = DioClient();

  Future<Map<String, dynamic>> fetchEntry(int entryId) async {
    final response = await _dioClient.get('api/logbook-entries/$entryId/');
    return parseEntryResponse(response);
  }

  String handleError(dynamic error) {
    if (error is DioException && error.response?.statusCode == 404) {
      return 'Log entry not found.';
    }
    return 'Failed to load entry: ${error.toString()}';
  }
}