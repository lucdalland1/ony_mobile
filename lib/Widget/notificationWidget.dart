import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:onyfast/Controller/NotificationController.dart';
import 'package:onyfast/View/Notification/notification.dart';
import 'package:onyfast/View/const.dart';

class NotificationWidget extends StatelessWidget {
  final bool isWhite;
  const NotificationWidget({super.key,  this.isWhite = true,
});

  @override
  Widget build(BuildContext context) {
    return Obx((){
      return Badge(
      isLabelVisible: true,
      label: Text('${NotificationController.to.unreadCount}'),
      offset: isWhite? const Offset(-8, 9):const Offset(-3, 2),
      child: IconButton(
        icon: Icon(CupertinoIcons.bell, color: isWhite ? Colors.white : globalColor),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        onPressed: () {
          Get.to(NotificationsPage(), transition: Transition.cupertino);
        },
      ),
    );
    });
  }
}
