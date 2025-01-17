import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

mixin ImageDeletionMixin {
  Future<bool> deleteCloudinaryImage(String url, String imageId) async {
    try {
      final apiKey = dotenv.env['API_KEY']!;
      final apiSecret = dotenv.env['API_SECRET']!;
      final cloudName = dotenv.env['CLOUD_NAME']!;
      final cloudinaryUrl = dotenv.env['CLOUDINARY_URL']!;
      final cloudinaryEndpoint = dotenv.env['CLOUDINARY_URL_ENDPOINT']!;

      if (url.isNotEmpty) {
        final parts = url.split('/');
        final fileName = parts.last.split('.').first;
        final folderPathParts = parts.sublist(7, parts.length - 1);
        final decodedPathParts = folderPathParts.map(Uri.decodeComponent).toList();
        final publicId = decodedPathParts.join('/') + '/' + fileName;

        final timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round();

        final params = {
          'public_id': publicId,
          'timestamp': timestamp.toString(),
        };

        final paramString = params.entries
            .map((entry) => '${entry.key}=${entry.value}')
            .join('&');

        final signature = sha256.convert(utf8.encode('$paramString$apiSecret')).toString();

        final response = await http.post(
          Uri.parse('$cloudinaryUrl$cloudName$cloudinaryEndpoint'),
          body: {
            ...params,
            'signature': signature,
            'api_key': apiKey,
          },
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        );

        if (response.statusCode == 200) {
          await FirebaseFirestore.instance
              .collection('images')
              .doc(imageId)
              .delete();
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }
}