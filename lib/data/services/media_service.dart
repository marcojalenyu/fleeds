import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

/// A service for handling media-related operations (Cloudinary)
class MediaService {

  static const String _cloudName = 'dgootykfi';
  static const String _uploadPreset = 'fleeds_uploads';

  final allowedExtensions = ['png', 'jpg', 'jpeg', 'gif', 'webp'];
  final maxSizeMB = 5;

  bool isAllowedFileType(String extension) {
    return allowedExtensions.contains(extension.toLowerCase());
  }

  bool isFileSizeValid(Uint8List bytes, String extension) {
    final sizeMB = bytes.lengthInBytes / (1024 * 1024);
    if (allowedExtensions.contains(extension.toLowerCase())) {
      return sizeMB <= maxSizeMB;
    }
    return false;
  }

  /// Opens the file picker and returns the picked file, or null if cancelled/invalid.
  Future<PlatformFile?> pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: true,
    );

    if (result == null || result.files.single.bytes == null) return null;

    final file = result.files.single;
    final ext = (file.extension ?? '').toLowerCase();

    if (!isAllowedFileType(ext)) return null;
    if (!isFileSizeValid(file.bytes!, ext)) return null;

    return file;
  }

  /// Uploads [bytes] to Cloudinary and returns the secure URL, or null on failure.
  Future<String?> uploadMedia(Uint8List bytes, String fileName) async {
    
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(http.MultipartFile.fromBytes('file', bytes, filename: fileName));

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['secure_url'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}