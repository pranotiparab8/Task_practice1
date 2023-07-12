import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageCompressionDemo extends StatefulWidget {
  @override
  _ImageCompressionDemoState createState() => _ImageCompressionDemoState();
}

class _ImageCompressionDemoState extends State<ImageCompressionDemo> {
  List<Asset> selectedImages = [];
  List<File> compressedImages = [];

  Future<void> compressImages() async {
    for (var image in selectedImages) {
      ByteData byteData = await image.getByteData(quality: 100);
      Uint8List imageData = byteData.buffer.asUint8List();

      var compressedImage = await FlutterImageCompress.compressWithList(
        imageData,
        quality: 70, // Adjust the quality as per your requirements
      );

      var tempDir = await getTemporaryDirectory();
      var compressedFile = File('${tempDir.path}/${image.name}');
      await compressedFile.writeAsBytes(compressedImage);

      int sizeInBytes = compressedImage.lengthInBytes;
      double sizeInKilobytes = sizeInBytes / 1024;
      double sizeInMegabytes = sizeInKilobytes / 1024;

      print('Size in bytes: $sizeInBytes');
      print('Size in kilobytes: $sizeInKilobytes');
      print('Size in megabytes: $sizeInMegabytes');
      setState(() {
        compressedImages.add(compressedFile);
      });
    }
  }

  Future<void> pickImages() async {
    List<Asset> resultList = [];
    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
      );
    } catch (e) {
      // Handle error
    }

    setState(() {
      selectedImages = resultList;
    });

    if (selectedImages.isNotEmpty) {
      await compressImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Compression Demo'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: pickImages,
            child: Text('Pick Images'),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: compressedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Image.file(
                    compressedImages[index],
                    height: 200,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ImageCompressionDemo(),
  ));
}
