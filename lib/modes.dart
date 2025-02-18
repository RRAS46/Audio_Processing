import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;

class FileOperations {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<File?> pickFile({required FileType fileType, List<String>? extensions}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: fileType,
      allowedExtensions: extensions,
    );

    if (result != null) {
      return File(result.files.single.path!);
    }
    return null;
  }

  String sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[^\w\.-]'), '_') // Replace invalid characters with '_'
        .replaceAll(' ', '_') // Replace spaces with '_'
        .replaceAll(RegExp(r'_{2,}'), '_') // Replace multiple underscores with one
        .replaceAll(RegExp(r'\.{2,}'), '.') // Replace multiple dots with one
        .replaceAll(RegExp(r'^\.|\.$'), '') // Remove leading/trailing dots
        .toLowerCase(); // Optionally make it lowercase
  }

  Future<void> uploadFile({
    required File file,
    required String fileName,
    required String bucketName,
    required String folderPath,
  }) async {
    try {
      await _supabase.storage
          .from(bucketName)
          .upload('$folderPath/$fileName', file);
    } catch (e) {
      throw Exception("File upload failed: $e");
    }
  }

  Future<void> insertIntoTable({
    required String audioName,
    required String jsonName,
    required String command,
    required String userId,
    required String timestampz,
  }) async {
    final data = {
      'uuid': Uuid().v4(),
      'audio_name': audioName,
      'annotations_name': jsonName,
      'command': command,
      'created_by_uuid': userId,
      'created_at': timestampz,
    };

    try {
      await _supabase.from("audio").insert(data);
    } catch (e) {
      throw Exception("Database insertion failed: $e");
    }
  }

  String generateTimestamp() {
    initializeTimeZones();
    final now = tz.TZDateTime.now(tz.UTC);
    return now.toIso8601String();
  }

  String generateFormattedDate() {
    initializeTimeZones();
    final now = tz.TZDateTime.now(tz.UTC);
    return DateFormat('yyyy_MM_dd-HH_mm_ss').format(now);
  }

}
