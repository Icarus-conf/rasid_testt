import 'package:flutter/material.dart';
import 'package:rasid_test/Features/Home/presentation/views/home_view.dart';
import 'package:rasid_test/Features/Qr_scanner/views/qr_scanner_view.dart';
import 'package:rasid_test/Features/Qr_scanner/views/widgets/scanner_view.dart';

class RoutesName {
  static const String qrScannerView = '/';
  static const String scannerView = 'scannerView';
  static const String homeView = 'homeView';
  static const String finishTaskView = 'finishTaskView';
}

class AppRoutes {
  static Route onGenerate(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.qrScannerView:
        return MaterialPageRoute(
          builder: (context) => const QrScannerView(),
        );

      case RoutesName.scannerView:
        return MaterialPageRoute(
          builder: (context) => const ScannerView(),
        );

      case RoutesName.homeView:
        return MaterialPageRoute(
          builder: (context) => const HomeView(),
        );

      default:
        return MaterialPageRoute(
          builder: (context) => unDefineRoute(),
        );
    }
  }

  static Widget unDefineRoute() {
    return const Scaffold(
      body: Center(
        child: Text('Route not found!'),
      ),
    );
  }
}
