import 'dart:typed_data';

import 'package:image/image.dart' as img;

const maxHikvisionFaceImageDimension = 1024;
const maxHikvisionFaceImageBytes = 200 * 1024;

/// Converts backend images to a conservative format accepted by Face ID.
///
/// Some terminals close the TCP connection instead of returning an ISAPI
/// error when the source image is too large. Keeping the normalization here
/// makes every face upload (manual and backend synchronization) safe.
List<int> normalizeHikvisionFaceImage(List<int> bytes) {
  final decoded = img.decodeImage(Uint8List.fromList(bytes));
  if (decoded == null) {
    throw const FormatException('Face ID uchun rasmni o‘qib bo‘lmadi.');
  }

  final oriented = img.bakeOrientation(decoded);
  final largestSide = oriented.width > oriented.height
      ? oriented.width
      : oriented.height;
  final scale = largestSide > maxHikvisionFaceImageDimension
      ? maxHikvisionFaceImageDimension / largestSide
      : 1.0;
  final targetWidth = (oriented.width * scale).round();
  final targetHeight = (oriented.height * scale).round();
  var resized = scale == 1.0
      ? oriented
      : img.copyResize(
          oriented,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.average,
        );

  // The terminal rejects images above roughly 200 KB. Quality alone is not
  // enough for detailed photos, so reduce quality first and then dimensions
  // until the encoded JPEG is within the device limit.
  const qualities = [90, 80, 70, 60, 50, 40, 30, 20, 10];
  while (true) {
    List<int>? smallestJpeg;
    for (final quality in qualities) {
      final jpeg = img.encodeJpg(resized, quality: quality);
      smallestJpeg = jpeg;
      if (jpeg.length <= maxHikvisionFaceImageBytes) return jpeg;
    }

    final largestSide = resized.width > resized.height
        ? resized.width
        : resized.height;
    if (largestSide <= 80) return smallestJpeg!;

    final nextLargestSide = largestSide > 256
        ? (largestSide * 0.8).round()
        : largestSide - 16;
    final nextScale = nextLargestSide / largestSide;
    resized = img.copyResize(
      resized,
      width: (resized.width * nextScale)
          .round()
          .clamp(1, resized.width)
          .toInt(),
      height: (resized.height * nextScale)
          .round()
          .clamp(1, resized.height)
          .toInt(),
      interpolation: img.Interpolation.average,
    );
  }
}
