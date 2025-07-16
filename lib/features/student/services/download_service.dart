import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/constants.dart';
import '../../../core/theme/typography.dart';

class DownloadService {
  static final DioClient _dioClient = DioClient();
  static final Dio _dio = Dio();

  static void scanFile(String path) {
    const platform = MethodChannel('downloads/scanner');
    try {
      platform.invokeMethod('scanFile', {'path': path});
    } catch (_) {}
  }

  static Future<void> _downloadFile({
    required BuildContext context,
    required String url,
    required String fileName,
    bool usePost = false,
  }) async {
    try {
      // --- Permissions ---
      if (Platform.isAndroid) {
        // Android 11+ needs MANAGE_EXTERNAL_STORAGE
        if (!(await Permission.manageExternalStorage.isGranted)) {
          final status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            throw Exception('Storage permission denied');
          }
        }
      }

      // --- Prepare Downloads directory ---
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final savePath = '${downloadsDir.path}/$fileName';

      // --- Fetch bytes ---
      final options = Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (s) => s != null && s < 500,
        headers: await _dioClient.getHeaders(),
      );
      late Response<List<int>> resp;
      if (usePost) {
        resp = await _dio.post<List<int>>(url, options: options);
      } else {
        resp = await _dio.get<List<int>>(url, options: options);
      }
      if (resp.statusCode != 200) {
        throw Exception('Server returned ${resp.statusCode}');
      }

      // --- Write file ---
      final file = File(savePath);
      await file.writeAsBytes(resp.data!);

      scanFile(savePath);

      // --- Success Snackbar ---
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppConstants.itemSpacing),
                Expanded(child: Text('$fileName saved to Downloads', style: AppTypography.body)),
              ],
            ),
            backgroundColor: AppColors.approved,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // --- Error Snackbar ---
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: AppConstants.itemSpacing),
                Expanded(child: Text('Download failed: $e', style: AppTypography.body)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  static Future<void> downloadLogbookPdf(BuildContext context, { required int internshipId }) async {
    final url = 'http://10.108.240.152:8000/api/logbooks/$internshipId/download/';
    final fileName = 'logbook_$internshipId.pdf';
    await _downloadFile(context: context, url: url, fileName: fileName, usePost: false);
  }

  static Future<void> downloadInternshipReport(BuildContext context, { required int internshipId }) async {
    final url = 'http://10.108.240.152:8000/api/internships/$internshipId/generate-report/';
    final fileName = 'internship_report_$internshipId.docx';
    await _downloadFile(context: context, url: url, fileName: fileName, usePost: true);
  }
}
