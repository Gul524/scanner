import 'package:flutter/material.dart';
import 'package:scanner/config/navigation.dart';
import 'package:scanner/pages/homepage/allfileTab/oldFiles.dart';
import 'package:scanner/pages/homepage/homewidgets.dart';
import 'package:scanner/pages/pdfPage/pdfImageSelectionPage.dart';
import 'package:scanner/sevices/data.dart';
import 'package:scanner/utils/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Navigations nav = Navigations();
  bool isSearching = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    OldPdf.getDir();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  PickImagefunction() async {
    await ImageToPDFLogic.captureAndProcessImage(context);
    nav.push(context, const SelectionImages());
  }

  camerafunction() async {
    await ImageToPDFLogic.pickMultipleImages();
    nav.push(context, const SelectionImages());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: ImagePickerButton(
        camfunc: PickImagefunction,
        galerypicfunc: camerafunction,
      ),
      appBar: AppBar(
        foregroundColor: colors.themeColor,
        backgroundColor: colors.primary,
        leading: IconButton(
          onPressed: () {}, 
          icon: const Icon(Icons.menu)
        ),
        title: isSearching
          ? TextField(
              controller: searchController,
              style: TextStyle(color: colors.themeColor),
              decoration: InputDecoration(
                hintText: 'Search PDFs...',
                hintStyle: TextStyle(color: colors.themeColor.withOpacity(0.7)),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  OldPdf.searchQuery = value;
                });
              },
            )
          : const Text(
              "Image to PDF",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchController.clear();
                  OldPdf.searchQuery = '';
                }
              });
            },
            icon: Icon(isSearching ? Icons.close : Icons.search)
          )
        ],
      ),
      body: const HomeBody(),
    );
  }
}
