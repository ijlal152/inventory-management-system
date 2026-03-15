import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeService {
  MobileScannerController? _controller;

  MobileScannerController createController() {
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    return _controller!;
  }

  void disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  String? parseBarcode(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      return barcodes.first.rawValue;
    }
    return null;
  }
}
