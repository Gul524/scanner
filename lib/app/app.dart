import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import '../pages/pdfPage/pdfImageSelectionPage.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: SelectionImages, initial: true),
    // Add other routes here
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: SnackbarService),
  ],
)
class App {} 