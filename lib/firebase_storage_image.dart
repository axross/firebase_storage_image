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

class FirebaseStorageImage extends ImageProvider<FirebaseStorageImage> {
  final Uri storageLocation;
  final double scale;
  final int maxSizeBytes;

  FirebaseStorageImage(
    this.storageLocation, {
    this.scale = 1.0,
    this.maxSizeBytes = 1000 * 1000 * 2,
  })  : assert(storageLocation != null),
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
    return storageLocation == typedOther.storageLocation &&
        scale == typedOther.scale;
  }

  @override
  int get hashCode => hashValues(storageLocation, scale);

  @override
  String toString() => '$runtimeType("$storageLocation", scale: $scale)';

  Future<Codec> _fetch(FirebaseStorageImage key) async {
    final storage =
        FirebaseStorage(storageBucket: _getBucketUrl(key.storageLocation))
            .ref()
            .child(key.storageLocation.path);

    final bytes = await storage.getData(key.maxSizeBytes);

    return await PaintingBinding.instance.instantiateImageCodec(bytes);
  }

  static String _getBucketUrl(Uri uri) => '${uri.scheme}://${uri.authority}';
}
