import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class PayerScanController extends GetxController {
  var isTorchOn = false.obs;
  late MobileScannerController scannerController;

  @override
  void onInit() {
    super.onInit();
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      torchEnabled: false,
      formats: [BarcodeFormat.qrCode],
      autoStart: true,
    );
  }

  void toggleTorch() {
    isTorchOn.value = !isTorchOn.value;
    scannerController.toggleTorch();
  }
}
