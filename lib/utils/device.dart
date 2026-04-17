import 'package:flutter_device_imei/flutter_device_imei.dart';

 Future<String?>? getDeviceIMEI() async {
  var imei = await  FlutterDeviceImei.instance.getIMEI();
  // print("  ✅  ✅  ✅  ✅  ✅  ✅   Device IMEI/Identifier: $imei");

  return imei;
}