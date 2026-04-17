
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class OrientationController extends GetxController {
  var isPortrait = true.obs;

  void updateOrientation(BuildContext context) {
    isPortrait.value = MediaQuery.of(context).orientation == Orientation.portrait;
  }
}