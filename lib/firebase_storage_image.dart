library firebase_storage_image;

import 'dart:ui' show Codec, hashValues;
import 'package:firebase_storage/firebase_storage.dart' show FirebaseStorage;
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/painting.dart'
    show
        ImageConfiguration,
        ImageProvider,
        ImageStreamCompleter,
        MultiFrameImageStreamCompleter,
        PaintingBinding;

/// Fetches the given URL from Firebase Cloud Storage, associating it with the given scale.
///
/// By default this will allocate 1MB for download the image. If you want to deal with larger file than 1MB, you have to set `maxSizeBytes` with the proper value.
class FirebaseStorageImage extends ImageProvider<FirebaseStorageImage> {
  /// The URL string from which the image will be fetched.
  final String location;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  /// The size which will be allocated.
  final int maxSizeBytes;

  /// Creates an object that fetches the image from Firebase Cloud Storage.
  ///
  /// [location] must be a [Uri] starting with `gs://`. [maxSizeBytes] is 1MB by default.
  const FirebaseStorageImage(
    this.location, {
    this.scale = 1.0,
    this.maxSizeBytes = 1000 * 1000,
  })  : assert(location != null),
        assert(scale != null),
        assert(maxSizeBytes != null);

  @override
  Future<FirebaseStorageImage> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<FirebaseStorageImage>(this);

  @override
  ImageStreamCompleter load(FirebaseStorageImage key) {
    return MultiFrameImageStreamCompleter(
        codec: _fetch(key),
        scale: key.scale,
        informationCollector: (StringBuffer information) {
          information.writeln('Image provider: $this');
          information.write('Image key: $key');
        });
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final FirebaseStorageImage typedOther = other;
    return location == typedOther.location && scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(location, scale);

  @override
  String toString() => '$runtimeType("$location", scale: $scale)';

  Future<Codec> _fetch(FirebaseStorageImage key) async {
    final uri = Uri.parse(key.location);

    final storage = FirebaseStorage(storageBucket: _getBucketUrl(uri))
        .ref()
        .child(uri.path);

    final bytes = await storage.getData(key.maxSizeBytes);

    return await PaintingBinding.instance.instantiateImageCodec(bytes);
  }

  static String _getBucketUrl(Uri uri) => '${uri.scheme}://${uri.authority}';
}
