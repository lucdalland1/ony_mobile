import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../Color/app_color_model.dart';
import '../../Widget/container.dart';
import '../../Widget/icon.dart';

class MaCarte extends StatefulWidget {
  const MaCarte({super.key});

  @override
  State<MaCarte> createState() => _MaCarteState();
}

class _MaCarteState extends State<MaCarte> {
  @override
  Widget build(BuildContext context) {


    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Material(
      child: Column(
        children: [
              
        ],
      ),
    );
  }
}