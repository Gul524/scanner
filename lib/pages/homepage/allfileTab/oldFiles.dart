import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:scanner/config/navigation.dart';
import 'package:scanner/pages/pdfPage/pdf_viewer_screen.dart';
import 'package:scanner/services/ad_service.dart';
import 'package:scanner/services/appServices.dart';
import 'package:scanner/sevices/data.dart';
import 'package:scanner/utils/colors.dart';
import 'package:share_plus/share_plus.dart';

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  Navigations nav = Navigations();

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    AdService.bannerAd = AdService.createBannerAd()..load();
  }

  @override
  void dispose() {
    AdService.bannerAd?.dispose();
    super.dispose();
  }

  viewPdf(File file, context) {
    nav.push(context,
        PDFViewerScreen(file: file, fileName: file.path.split('/').last));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          height: 100,
          decoration: BoxDecoration(
            color: colors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: colors.primary.withOpacity(0.3)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: AdService.bannerAd != null
                ? Center(
                    child: SizedBox(
                      width: AdService.bannerAd!.size.width.toDouble(),
                      height: AdService.bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: AdService.bannerAd!),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.ad_units, size: 40, color: colors.primary),
                        const SizedBox(height: 8),
                        Text(
                          "Advertisement Space",
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            OldPdf.searchQuery.isEmpty ? "Recent PDFs" : "Search Results",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.InvrsethemeColor,
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: OldPdf.fetchPdfFiles(),
            builder: (context, snp) {
              if (snp.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snp.hasData) {
                final data = snp.data;
                print(data);
                if (data != null && data.isNotEmpty) {
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final file = data[index];
                      final fileName = file.path.split('/').last;
                      final modifiedDate = file.lastModifiedSync().toLocal();

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: colors.themeColor,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.picture_as_pdf,
                              color: colors.primary,
                              size: 28,
                            ),
                          ),
                          title: Text(
                            fileName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          subtitle: Text(
                            "${modifiedDate.day}/${modifiedDate.month}/${modifiedDate.year}   ${modifiedDate.hour}:${modifiedDate.minute}",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          trailing: SizedBox(
                            width: 100,
                            child: FittedBox(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        Appservices.fileShare(file.path);
                                      },
                                      icon: Icon(
                                        Icons.share,
                                        color: colors.primary,
                                        size: 30,
                                      )),
                                  IconButton(
                                      onPressed: () async {
                                        await Appservices.deleteFile(file.path);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(Messages.EdeleteMSj),
                                        ));
                                        setState(() {});
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: colors.primary,
                                        size: 30,
                                      ))
                                ],
                              ),
                            ),
                          ),
                          onTap: () => viewPdf(file, context),
                        ),
                      );
                    },
                  );
                }
                return _buildEmptyState(OldPdf.searchQuery.isEmpty
                    ? "No PDF files found"
                    : "No matching PDFs found");
              }
              return _buildEmptyState("No PDF files found");
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.picture_as_pdf_outlined,
            size: 64,
            color: colors.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: colors.InvrsethemeColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (OldPdf.searchQuery.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              "Create your first PDF by scanning documents",
              style: TextStyle(
                fontSize: 14,
                color: colors.InvrsethemeColor.withOpacity(0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
