import 'package:flutter/material.dart';
import 'package:firebase_storage_image/firebase_storage_image.dart';

class YourImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image(
      image: FirebaseStorageImage(
        'gs://project-12345.appspot.com/path/to/image.png',
      ),
    );
  }
}

class YourCircleAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundImage: FirebaseStorageImage(
        'gs://project-12345.appspot.com/path/to/avatar_image.png',
      ),
    );
  }
}

class YourImageIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ImageIcon(
      FirebaseStorageImage(
        'gs://project-12345.appspot.com/path/to/icon_image.png',
      ),
    );
  }
}
