import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:internlog/core/network/dio_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/constants.dart';
import '../../../core/theme/typography.dart';

class DownloadService {
  static final DioClient _dioClient = DioClient();
  static final Dio _dio = Dio();

  /// Tell Android to index the new file so it appears in the Downloads app
  static void scanFile(String path) {
    const platform = MethodChannel('downloads/scanner');
    try {
      platform.invokeMethod('scanFile', {'path': path});
    } catch (e) {
      print('Failed to scan file: $e');
    }
  }

  /// Shared GET/POST byte‐stream downloader
  static Future<void> _downloadFile({
    required BuildContext context,
    required String url,
    required String fileName,
    bool usePost = false,               // ← new flag
  }) async {
    try {
      // 1) storage permission
      final status = await Permission.storage.request();
      if (!status.isGranted) throw Exception('Storage permission denied');

      // 2) ensure /Download exists
      final downloadsDir = Directory('/storage/emulated/0/Download');
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
      final savePath = '${downloadsDir.path}/$fileName';

      // 3) show "Downloading…" snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: AppConstants.itemSpacing),
                Text('Downloading $fileName…', style: AppTypography.body),
              ],
            ),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      // 4) perform GET or POST
      final options = Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (status) => status == 200,
        headers: await _dioClient.getHeaders(),
      );
      late Response<List<int>> response;
      if (usePost) {
        response = await _dio.post<List<int>>(url, options: options);
      } else {
        response = await _dio.get<List<int>>(url, options: options);
      }
      if (response.statusCode != 200) {
        throw Exception('Server returned ${response.statusCode}');
      }

      // 5) write to disk
      final file = File(savePath);
      await file.writeAsBytes(response.data!);

      // 6) index in Android
      scanFile(savePath);

      // 7) success snackbar
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
      // error snackbar
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

  /// PDF logbook via GET
  static Future<void> downloadLogbookPdf(
      BuildContext context, {
        required int internshipId,
      }) async {
    final url = 'http://10.111.147.152:8000/api/logbooks/$internshipId/download/';
    final fileName = 'logbook_$internshipId.pdf';
    await _downloadFile(
      context: context,
      url: url,
      fileName: fileName,
      usePost: false,
    );
  }

  /// DOCX internship report via POST
  static Future<void> downloadInternshipReport(
      BuildContext context, {
        required int internshipId,
      }) async {
    final url = 'http://10.111.147.152:8000/api/internships/$internshipId/generate-report/';
    final fileName = 'internship_report_$internshipId.docx';
    await _downloadFile(
      context: context,
      url: url,
      fileName: fileName,
      usePost: true,    // ← POST for report
    );
  }
}
