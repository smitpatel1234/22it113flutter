import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class BarcodeService {
  // Scan a barcode
  Future<String?> scanBarcode() async {
    try {
      final barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#FF6666', // Line color
        'Cancel', // Cancel button text
        true, // Show flash icon
        ScanMode.BARCODE, // Scan mode
      );

      // Check if scanning was canceled
      if (barcodeScanRes == '-1') {
        return null;
      }

      return barcodeScanRes;
    } on PlatformException {
      return null;
    } catch (e) {
      print('Error scanning barcode: $e');
      return null;
    }
  }
}
