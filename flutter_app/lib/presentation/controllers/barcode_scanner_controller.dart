import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../services/barcode_service.dart';

class BarcodeScannerController extends GetxController {
  final BarcodeService barcodeService;

  BarcodeScannerController({required this.barcodeService});

  late MobileScannerController scannerController;
  final RxBool isScanning = true.obs;

  @override
  void onInit() {
    super.onInit();
    scannerController = barcodeService.createController();
  }

  void onBarcodeDetected(BarcodeCapture capture) {
    if (!isScanning.value) return;

    final barcode = barcodeService.parseBarcode(capture);
    if (barcode != null) {
      isScanning.value = false;
      Get.back(result: barcode);
    }
  }

  @override
  void onClose() {
    barcodeService.disposeController();
    super.onClose();
  }
}
