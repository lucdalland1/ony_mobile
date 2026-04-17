import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:onyfast/View/const.dart';

PreferredSizeWidget buildAppBar(BuildContext context, String icon, String title, {bool hideBack = false}) {
  return AppBar(
    backgroundColor: globalColor,
    elevation: 0,
    centerTitle: true,
    leading: hideBack
        ? null
        : IconButton(
            icon:IconButton(onPressed: () => Get.back(), icon:  Icon(
        Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios_new,
         color: Colors.white)),
            onPressed: () => Navigator.pop(context),
          ),
    title: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
      ],
    ),
  );
}