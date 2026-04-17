import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/View/const.dart';

void chargementDialog()=> Get.dialog(
              Center(
                child: Card(
                  margin: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: CupertinoActivityIndicator(
                      color: globalColor,
                    ),
                  ),
                ),
              ),
              barrierDismissible: false,
);

