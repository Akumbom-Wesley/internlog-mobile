import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/constants.dart';
import '../../../core/theme/typography.dart';

class DownloadService {
  static final DioClient _dioClient = DioClient();
  static final Dio _dio = Dio();

  /// Notify Android to index the file so it's visible in Files app
  static void scanFile(String path) {
    const platform = MethodChannel('downloads/scanner');
    try {
      platform.invokeMethod('scanFile', {'path': path});
    } catch (e) {
      print('Failed to scan file: $e');
    }
  }

  static Future<void> _downloadFile({
    required BuildContext context,
    required String url,
    required String fileName,
  }) async {
    try {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }

      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }

      final savePath = '${downloadsDir.path}/$fileName';

      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
          validateStatus: (status) => status! < 500,
          headers: await _dioClient.getHeaders(),
        ),
      );

      final file = File(savePath);
      await file.writeAsBytes(response.data!);
      scanFile(savePath); //

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: AppConstants.itemSpacing),
                Expanded(
                  child: Text('$fileName saved to Downloads', style: AppTypography.body),
                ),
              ],
            ),
            backgroundColor: AppColors.approved,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
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

  static Future<void> downloadLogbookPdf(BuildContext context, {required int internshipId}) async {
    final url = 'http://10.111.147.152:8000/api/logbooks/$internshipId/download/';
    final fileName = 'logbook_$internshipId.pdf';
    await _downloadFile(context: context, url: url, fileName: fileName);
  }

  static Future<void> downloadInternshipReport(BuildContext context, {required int requestId}) async {
    final url = 'http://10.111.147.152:8000/api/internships/$requestId/generate-report/';
    final fileName = 'internship_report_$requestId.docx';
    await _downloadFile(context: context, url: url, fileName: fileName);
  }
}
