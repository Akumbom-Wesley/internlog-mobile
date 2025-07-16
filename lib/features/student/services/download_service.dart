// lib/features/student/services/download_service.dart

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
  static final _dioClient = DioClient();
  static final _dio = Dio();

  /// Ask Android to index the file so it shows up immediately
  static void _scanFile(String path) {
    const platform = MethodChannel('downloads/scanner');
    try {
      platform.invokeMethod('scanFile', {'path': path});
    } catch (_) {}
  }

  /// Show a simple error snackbar
  static void _showError(BuildContext context, String message) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.body),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> _downloadFile({
    required BuildContext context,
    required String url,
    required String fileName,
    bool usePost = false,
  }) async {
    // 1) Permissions
    if (Platform.isAndroid) {
      // Android 11+ needs MANAGE_EXTERNAL_STORAGE
      if (!await Permission.manageExternalStorage.isGranted) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          _showError(context,
              'Storage permission denied. Please grant access to save files.');
          return;
        }
      }
    }

    // 2) Prepare path
    final downloadsDir = Directory('/storage/emulated/0/Download');
    try {
      if (!await downloadsDir.exists()) {
        await downloadsDir.create(recursive: true);
      }
    } catch (e) {
      _showError(context,
          'Unable to prepare download folder. Please check your storage settings.');
      return;
    }
    final savePath = '${downloadsDir.path}/$fileName';

    // 3) Fetch bytes
    Response<List<int>> response;
    try {
      final options = Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        validateStatus: (_) => true, // we'll handle status codes manually
        headers: await _dioClient.getHeaders(),
      );
      if (usePost) {
        response = await _dio.post<List<int>>(url, options: options);
      } else {
        response = await _dio.get<List<int>>(url, options: options);
      }
    } on DioException catch (e) {
      // Network-level error
      if (e.error is SocketException) {
        _showError(context,
            'Network error. Please check your internet connection and try again.');
      } else {
        _showError(context,
            'Failed to connect to the server. Please try again later.');
      }
      return;
    } catch (_) {
      _showError(context, 'Unexpected error during download. Please try again.');
      return;
    }

    // 4) Handle HTTP status codes
    final code = response.statusCode ?? 0;
    if (code == 401 || code == 403) {
      _showError(
          context, 'You are not authorized to download this file. (Error $code)');
      return;
    }
    if (code == 404) {
      _showError(context, 'You have not completed this internship yet');
      return;
    }
    if (code != 200) {
      _showError(
          context, 'Server returned an error ($code). Please try again later.');
      return;
    }

    // 5) Write to disk
    try {
      final file = File(savePath);
      await file.writeAsBytes(response.data!);
      _scanFile(savePath);
    } on FileSystemException {
      _showError(context,
          'Failed to save the file. Please check your storage permissions.');
      return;
    } catch (_) {
      _showError(context, 'An unexpected error occurred saving the file.');
      return;
    }

    // 6) Success
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: AppConstants.itemSpacing),
              Expanded(
                child:
                Text('$fileName saved to your Downloads folder.', style: AppTypography.body),
              ),
            ],
          ),
          backgroundColor: AppColors.approved,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Download the PDF logbook via GET
  static Future<void> downloadLogbookPdf(
      BuildContext context, {
        required int internshipId,
      }) {
    final url = 'http://10.108.240.152:8000/api/logbooks/$internshipId/download/';
    final fileName = 'logbook_$internshipId.pdf';
    return _downloadFile(
      context: context,
      url: url,
      fileName: fileName,
      usePost: false,
    );
  }

  /// Generate & download the internship report via POST
  static Future<void> downloadInternshipReport(
      BuildContext context, {
        required int internshipId,
      }) {
    final url =
        'http://10.108.240.152:8000/api/internships/$internshipId/generate-report/';
    final fileName = 'internship_report_$internshipId.docx';
    return _downloadFile(
      context: context,
      url: url,
      fileName: fileName,
      usePost: true,
    );
  }
}
