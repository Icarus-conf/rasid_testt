import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rasid_test/Config/routes/routes_config.dart';
import 'package:rasid_test/Features/Qr_scanner/views/widgets/scanner_overlay.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  MobileScannerController cameraController = MobileScannerController();
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    log("Building QRScannerScreen UI");

    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (barcodeCapture) {
              log("onDetect triggered");

              if (!isProcessing) {
                setState(() {
                  isProcessing = true;
                });

                final List<Barcode> barcodes = barcodeCapture.barcodes;
                log("Detected ${barcodes.length} barcode(s)");

                for (final barcode in barcodes) {
                  log("Processing barcode: ${barcode.rawValue}");
                  if (barcode.rawValue != null) {
                    final String code = barcode.rawValue!;
                    log('QR Code detected: $code');

                    Navigator.of(context).pushNamedAndRemoveUntil(
                        RoutesName.homeView, (Route<dynamic> route) => false);

                    log("Navigating to HomeView");

                    break;
                  } else {
                    log("No rawValue found in barcode");
                  }
                }
              } else {
                log("Already processing a QR code, ignoring further detections");
              }
            },
          ),
          const QRScannerOverlay(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    log("Disposing QRScannerScreen and cameraController");
    cameraController.dispose();
    super.dispose();
  }
}
