import 'dart:io';
import 'package:flutter/material.dart';
import 'package:scanner/config/navigation.dart';
import 'package:scanner/pages/homepage/homepage.dart';
import 'package:scanner/pages/homepage/homewidgets.dart';
import 'package:scanner/sevices/data.dart';
import 'package:scanner/utils/assets.dart';
import 'package:scanner/utils/colors.dart';

class SelectionImages extends StatefulWidget {
  const SelectionImages({super.key});

  @override
  State<SelectionImages> createState() => _SelectionImagesState();
}

class _SelectionImagesState extends State<SelectionImages> {
  Navigations nav = Navigations();

  @override
  void initState() {
    super.initState();
    ImageToPDFLogic.onImagesChanged = () {
      setState(() {});
    };
  }

  PickImagefunction() async {
    await ImageToPDFLogic.pickMultipleImages();
  }

  camerafunction() async {
    await ImageToPDFLogic.captureAndProcessImage(context);
  }

  deleteImage(int index) {
    setState(() {
      ImageToPDFLogic.cropImagesList.removeAt(index);
    });
  }

  bottomSheet(BuildContext parentContext) {
    bool isStoringComplete = false;

    showModalBottomSheet(
      context: parentContext,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            height: 500,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colors.themeColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 2,
                ),
              ],
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Image.asset(myImages.Logo)),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextField(
                    controller: ImageToPDFLogic.fileNameTec,
                    enabled: !isStoringComplete,
                    decoration: const InputDecoration(
                      labelText: 'File Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                if (!isStoringComplete) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "PDF Options",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: colors.InvrsethemeColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SwitchListTile(
                          title: Text(
                            'Black & White',
                            style: TextStyle(color: colors.InvrsethemeColor),
                          ),
                          value: ImageToPDFLogic.isBlackAndWhite,
                          onChanged: (bool value) {
                            setModalState(() {
                              ImageToPDFLogic.isBlackAndWhite = value;
                            });
                          },
                          activeColor: colors.primary,
                        ),
                        SwitchListTile(
                          title: Text(
                            'Full Page Images',
                            style: TextStyle(color: colors.InvrsethemeColor),
                          ),
                          value: ImageToPDFLogic.isFullPage,
                          onChanged: (bool value) {
                            setModalState(() {
                              ImageToPDFLogic.isFullPage = value;
                            });
                          },
                          activeColor: colors.primary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  MyButton(
                    text: "SAVE",
                    onTap: () async {
                      await ImageToPDFLogic.newPdf();
                      await ImageToPDFLogic.storePdf(
                          ImageToPDFLogic.fileNameTec.text);

                      if (ImageToPDFLogic.storingStatus) {
                        setModalState(() {
                          isStoringComplete = true;
                          ImageToPDFLogic.fileNameTec.clear();
                        });

                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(
                            content: Text('PDF saved successfully!'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          const SnackBar(
                            content: Text('Failed to save PDF'),
                            duration: Duration(seconds: 2),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                  ),
                ] else
                  Column(
                    children: [
                      Padding( 
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Text(
                              "File saved as:",
                              style: TextStyle(
                                color: colors.InvrsethemeColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ImageToPDFLogic.fileNameTec.text,
                              style: TextStyle(
                                color: colors.InvrsethemeColor,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              ImageToPDFLogic.pdfPath ?? '',
                              style: TextStyle(
                                color: colors.InvrsethemeColor.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.themeColor,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.pushAndRemoveUntil(
                                    parentContext,
                                    MaterialPageRoute(
                                      builder: (context) => const HomePage(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                icon: const Icon(Icons.home),
                                label: const Text('Go Home'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  foregroundColor: colors.themeColor,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  ImageToPDFLogic.viewCurrentPdf(parentContext);
                                },
                                icon: const Icon(Icons.picture_as_pdf),
                                label: const Text('View PDF'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.primary,
        foregroundColor: colors.themeColor,
        title: const Text("Select Images"),
        actions: [
          if (ImageToPDFLogic.cropImagesList.isNotEmpty)
            IconButton(
                onPressed: () {
                  ImageToPDFLogic.newPdf();
                  bottomSheet(context);
                },
                icon: const Icon(Icons.check))
        ],
      ),
      body: Column(
        children: [
          if (ImageToPDFLogic.cropImagesList.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library_outlined,
                      size: 64,
                      color: colors.primary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Select multiple images to create PDF",
                      style: TextStyle(
                        fontSize: 16,
                        color: colors.InvrsethemeColor.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: ImageToPDFLogic.cropImagesList.length,
                  itemBuilder: (context, index) {
                    return ImageContainer(
                      file: ImageToPDFLogic.cropImagesList[index],
                      index: index,
                      onDelete: () {
                        deleteImage(index);
                      },
                    );
                  },
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: ImagePickerButton(
        camfunc: camerafunction,
        galerypicfunc: PickImagefunction,
      ),
    );
  }
}

class ImageContainer extends StatelessWidget {
  final File file;
  final int index;
  final VoidCallback onDelete;

  const ImageContainer({
    super.key,
    required this.file,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            ImageToPDFLogic.reCropImage(context, file, index);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                file,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: IconButton(
            icon: Icon(
              Icons.delete,
              color: colors.primary,
            ),
            onPressed: onDelete,
          ),
        ),
      ],
    );
  }
}
