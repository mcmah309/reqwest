import 'dart:io';
import 'dart:math';

import 'package:mime/mime.dart';
import 'package:reqwest/src/error.dart';
import 'package:rust/rust.dart';

import 'body.dart';

/// Multipart form
class Form {
  final String boundary = _genBoundary();
  final List<Part> _parts = [];
  final Map<String, List<String>> _headers = {};

  Form();

// boundary : Added as field

  Future<Result<(), ReqError>> file(String name, Path path) async {
    final fileName = path.fileName();
    try {
      final file = File(path.asString());
      int length = await file.length();
      final fileStream = File(path.asString()).openRead();
      final mimeType = lookupMimeType(fileName);
      _parts.add(Part(
          value: fileStream.toBody(),
          meta: PartMetadata(fileName: fileName, mimeType: mimeType),
          bodyLength: length));
      return Ok(());
    } catch (e) {
      return Err(ReqError(e.toString()));
    }
  }

// part
// percent_encode_attr_chars
// percent_encode_noop
// percent_encode_path_segment
// text
}

class Part {
  PartMetadata meta;
  Body value;
  int? bodyLength;

  Part({required this.meta, required this.value, this.bodyLength});
}

class PartMetadata {
  final String? fileName;
  final String? mimeType; // todo
  final Map<String, List<String>> headers; // todo do not expose for mutation

  PartMetadata({this.fileName, this.mimeType, this.headers = const {}});
}

String _genBoundary() {
  int random64Bit() {
    // Generate a 64-bit random integer using Dart's Random class.
    final random = Random();
    return (random.nextInt(1 << 32) << 32) | random.nextInt(1 << 32);
  }

  final a = random64Bit();
  final b = random64Bit();
  final c = random64Bit();
  final d = random64Bit();

  // Format the string in the same style as the Rust code.
  return '${a.toRadixString(16).padLeft(16, '0')}-'
      '${b.toRadixString(16).padLeft(16, '0')}-'
      '${c.toRadixString(16).padLeft(16, '0')}-'
      '${d.toRadixString(16).padLeft(16, '0')}';
}
