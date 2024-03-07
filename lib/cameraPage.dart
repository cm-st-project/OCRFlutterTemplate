import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late final ImagePicker _picker;
  String text = "";

  final textDetector = TextRecognizer();

  File? image;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    _picker = ImagePicker();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      // App going into background
    } else if (state == AppLifecycleState.resumed) {
      // App coming into foreground
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    image = File(pickedFile!.path);
    if (pickedFile != null) {
      _processImage();
    } else {
      print('No image selected.');
    }
  }

  Future<void> _processImage() async {
    try {
      final inputImage = InputImage.fromFile(image!);
      final RecognizedText recognisedText =
          await textDetector.processImage(inputImage);
      setState(() {
        text = recognisedText.text;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred when processing the image'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text Recognition Sample'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          if (image != null) Image.file(image!),
          ElevatedButton(
              onPressed: () => _getImage(ImageSource.gallery),
              child: const Text('Get/Process Image')),
          Text(text),
        ],
      ),
    );
  }
}
