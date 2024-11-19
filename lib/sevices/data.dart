import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:scanner/config/navigation.dart';
import 'package:scanner/pages/pdfPage/pdf_viewer_screen.dart';
import 'package:scanner/utils/colors.dart';
import 'package:image/image.dart' as img;

class Errormsj {
  static String? fatchingPDFfilesFromDIR;
}

class OldPdf {
  static List<File> pdfFiles = [];
  static Directory? directory;
  static bool dirStatus = false;
  static String searchQuery = '';

  static Future<void> getDir() async {
    directory = await getExternalStorageDirectory();
    if (directory != null) {
      dirStatus = true;
    }
  }

  static Future<List<File>> fetchPdfFiles() async {
    List<File> files = [];
    Directory directory = Directory((await getExternalStorageDirectory())!.path);
    try {
      final entities = directory.listSync(recursive: true);
      for (FileSystemEntity entity in entities) {
        if (entity is File && entity.path.endsWith(".pdf")) {
          files.add(entity);
        }
      }
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      if (searchQuery.isNotEmpty) {
        files = files.where((file) {
          final fileName = file.path.split('/').last.toLowerCase();
          return fileName.contains(searchQuery.toLowerCase());
        }).toList();
      }
      pdfFiles = files;
      return pdfFiles;
    } catch (e) {
      Errormsj.fatchingPDFfilesFromDIR = e.toString();
      print("while fatching eror : $e");
    }
    return pdfFiles;
  }
}

class ImageToPDFLogic {
  static List<File> cropImagesList = [];
  static String? readyPdfPath;
  static File? currentPDF;
  static bool storingStatus = false;
  static String? filename;
  static TextEditingController fileNameTec = TextEditingController(text: filename);
  static Function()? onImagesChanged;
  static bool isBlackAndWhite = false;
  static bool isFullPage = true;
  static String? pdfPath;

  static Future<void> pickMultipleImages() async {
    final ImagePicker imagePicker = ImagePicker();

    try {
      final List<XFile> images = await imagePicker.pickMultiImage();
      
      if (images.isNotEmpty) {
        for (XFile image in images) {
          final selectedImage = await ImageCropper().cropImage(
            sourcePath: image.path,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: "Crop Image ${images.indexOf(image) + 1}/${images.length}",
                toolbarColor: colors.primary,
                toolbarWidgetColor: colors.themeColor,
                lockAspectRatio: false,
                hideBottomControls: false,
                initAspectRatio: CropAspectRatioPreset.original,
                statusBarColor: colors.primary,
              ),
              IOSUiSettings(
                title: 'Crop Image ${images.indexOf(image) + 1}/${images.length}',
              ),
            ],
            compressQuality: 100,
          );

          if (selectedImage != null) {
            final croppedImage = File(selectedImage.path);
            if (cropImagesList.isEmpty || !cropImagesList.contains(croppedImage)) {
              cropImagesList.add(croppedImage);
              onImagesChanged?.call();
            }
          }
        }
      }
    } catch (e) {
      print("Error picking multiple images: $e");
    }
  }

  static Future<void> captureAndProcessImage(BuildContext context) async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final XFile? photo = await imagePicker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (photo != null) {
        final croppedImage = await ImageCropper().cropImage(
          sourcePath: photo.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: "Crop",
              toolbarColor: colors.primary,
              toolbarWidgetColor: colors.themeColor,
              lockAspectRatio: false,
              hideBottomControls: false,
              initAspectRatio: CropAspectRatioPreset.original,
              statusBarColor: colors.primary,
            ),
            IOSUiSettings(
              title: 'Crop Image',
            ),
          ],
          compressQuality: 100,
        );

        if (croppedImage != null) {
          final processedImage = File(croppedImage.path);
          if (cropImagesList.isEmpty || !cropImagesList.contains(processedImage)) {
            cropImagesList.add(processedImage);
            onImagesChanged?.call();
          }
        }
      }
    } catch (e) {
      print("Error capturing image: $e");
    }
  }

  static Future<void> reCropImage(BuildContext context, File image, int index) async {
    try {
      final croppedImage = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: "Crop",
            toolbarColor: colors.primary,
            toolbarWidgetColor: colors.themeColor,
            lockAspectRatio: false,
            hideBottomControls: false,
            initAspectRatio: CropAspectRatioPreset.original,
            statusBarColor: colors.primary,
          ),
          IOSUiSettings(
            title: 'Crop Image',
          ),
        ],
        compressQuality: 100,
      );

      if (croppedImage != null) {
        final processedImage = File(croppedImage.path);
        cropImagesList[index] = processedImage;
        onImagesChanged?.call();
      }
    } catch (e) {
      print("Error re-cropping image: $e");
    }
  }

  static Future<void> newPdf() async {
    final pdfDocument = pw.Document();
    
    for (File image in cropImagesList) {
      try {
        final imgBytes = await image.readAsBytes();
        
        // Process image if black and white is selected
        final processedBytes = isBlackAndWhite 
            ? await _convertToBlackAndWhite(imgBytes)
            : imgBytes;
        
        final img = pw.MemoryImage(processedBytes);

        pdfDocument.addPage(
          pw.Page(
            margin: isFullPage 
                ? const pw.EdgeInsets.all(5)
                : const pw.EdgeInsets.all(30),
            build: (context) => pw.Center(
              child: isFullPage
                  ? pw.SizedBox(
                      width: PdfPageFormat.a4.width - 10,
                      height: PdfPageFormat.a4.height - 10,
                      child: pw.Image(img),
                    )
                  : pw.Image(img),
            ),
          ),
        );
      } catch (e) {
        print('Error processing image: $e');
        continue;
      }
    }

    try {
      final tempDir = await getTemporaryDirectory();
      String fileName = "EasyScan_${DateTime.now().millisecondsSinceEpoch}.pdf";
      filename = fileName;
      final tempPath = "${tempDir.path}/$fileName";
      currentPDF = File(tempPath);
      await currentPDF!.writeAsBytes(await pdfDocument.save());
    } catch (e) {
      print('Error saving PDF: $e');
    }
  }

  static Future<Uint8List> _convertToBlackAndWhite(Uint8List bytes) async {
    try {
      img.Image? image = img.decodeImage(bytes);
      if (image == null) return bytes;
      
      // Convert to grayscale
      img.Image grayscale = img.grayscale(image);
      
      // Convert pixels to black and white
      for (var y = 0; y < grayscale.height; y++) {
        for (var x = 0; x < grayscale.width; x++) {
          var pixel = grayscale.getPixel(x, y);
          int grayValue = pixel.r.toInt(); // Convert num to int
          grayscale.setPixel(x, y, img.ColorRgb8(
            grayValue > 128 ? 255 : 0,
            grayValue > 128 ? 255 : 0,
            grayValue > 128 ? 255 : 0));
        }
      }
      
      return Uint8List.fromList(img.encodeJpg(grayscale));
    } catch (e) {
      print('Error converting to black and white: $e');
      return bytes;
    }
  }

  static Future<void> storePdf(String fileName) async {
    storingStatus = false;

    try {
      String filePath = "${OldPdf.directory?.path}/$fileName.pdf";
      if (currentPDF != null) {
        final pdfBytes = await currentPDF!.readAsBytes();
        await File(filePath).writeAsBytes(pdfBytes);
        readyPdfPath = filePath;
        currentPDF = File(filePath);
        storingStatus = true;
        cropImagesList.clear();
        pdfPath = filePath;
      }
    } catch (e) {
      print("Error saving PDF: $e");
      storingStatus = false;
    }
  }

  static Future<void> viewCurrentPdf(BuildContext context) async {
    Navigations nav = Navigations();
    if (currentPDF != null) {
      nav.replace(
        context,
        PDFViewerScreen(
          file: currentPDF!,
          fileName: fileNameTec.text,
        ),
      );
    } else {
      print("No PDF available to view.");
    }
  }
}