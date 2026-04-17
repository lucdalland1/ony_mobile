import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_sizer/flutter_sizer.dart';

class AppDialog extends StatelessWidget {
  final String title;
  final String body;
  final List<AppDialogAction> actions;
  final Color headerColor;

  const AppDialog({
    super.key,
    required this.title,
    required this.body,
    required this.actions,
    this.headerColor = const Color(0xFF4F46E5),
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _buildIOS();
    }
    return _buildAndroid();
  }

  /// 🍎 iOS
  Widget _buildIOS() {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Padding(
        padding: EdgeInsets.only(top: 1.h),
        child: Text(body),
      ),
      actions: actions
          .map(
            (a) => CupertinoDialogAction(
              onPressed: a.onPressed,
              isDestructiveAction: a.isDestructive,
              isDefaultAction: a.isDefault,
              child: Text(a.label),
            ),
          )
          .toList(),
    );
  }

  /// 🤖 Android
  Widget _buildAndroid() {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 5.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1.5.h),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER coloré
          Container(
            width: double.infinity,
            color: headerColor,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),

          /// BODY
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 1.h),
            child: Text(
              body,
              style: TextStyle(
                fontSize: 10.sp,
                height: 1.5,
              ),
            ),
          ),

          /// ACTIONS
          Padding(
            padding: EdgeInsets.fromLTRB(2.w, 0, 2.w, 2.h),
            child: Row(
              spacing: 2,
              mainAxisAlignment: MainAxisAlignment.end,
              children: actions
                  .map(
                    (a) => SizedBox(
                      width: 20.w,
                      child: MaterialButton(
                        onPressed: a.onPressed,
                        color: a.isDestructive ? headerColor : Colors.transparent,
                        elevation: 0,
                        highlightElevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(1.h),
                          side: a.isDestructive
                              ? BorderSide.none
                              : BorderSide(
                                  color: headerColor,
                                  width: 1,
                                ),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 1.2.h),
                        child: Text(
                          a.label,
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: a.isDestructive ? Colors.white : headerColor,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modèle d'une action
class AppDialogAction {
  final String label;
  final VoidCallback onPressed;
  final bool isDestructive;
  final bool isDefault;

  const AppDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isDefault = false,
  });
}