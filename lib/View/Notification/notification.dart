// // Flutter UI for Onyfast Wallet - Notifications Screen (dynamique via GetX)

// import 'package:flutter/material.dart';
// import 'package:flutter_sizer/flutter_sizer.dart';
// import 'package:get/get.dart';
// import 'package:onyfast/Color/app_color_model.dart';
// import 'package:onyfast/Color/visuelles.dart';
// import 'package:onyfast/Controller/NotificationController.dart';
// import 'package:onyfast/model/app_notification.dart';
// import 'package:timeago/timeago.dart' as timeago;
// // import 'package:timeago/timeago.dart' as timeago_fr show fr;

// class NotificationsPage extends StatelessWidget {
//   final controller = Get.put(NotificationController());

//   NotificationsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColorModel.Bluecolor242,
//         title: Text(
//           "Notifications",
//           style: TextStyle(
//               fontSize: 17.dp,
//               fontWeight: FontWeight.bold,
//               color: AppColorModel.WhiteColor),
//         ),
//         centerTitle: true,
//         leading: BackButton(color: Colors.white),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.notifications, color: Colors.white),
//             onPressed: () => controller.fetchNotifications(),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Obx(() {
//           if (controller.isLoading.value) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return ListView(
//             children: controller.groupedNotifications.entries.map((entry) {
//               return Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(entry.key,
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold)),
//                       TextButton(
//                         onPressed: () {
//                           for (var n in entry.value) {
//                             controller.markAsRead(n);
//                           }
//                         },
//                         child: Text('Tout marquer comme lu',
//                             style: TextStyle(color: Colors.blue)),
//                       )
//                     ],
//                   ),
//                   SizedBox(height: 10),
//                   ...entry.value.map((n) => _notificationItem(n)).toList(),
//                   SizedBox(height: 20),
//                 ],
//               );
//             }).toList(),
//           );
//         }),
//       ),
//     );
//   }

//   Widget _notificationItem(AppNotification n) => ListTile(
//         leading: CircleAvatar(
//           backgroundColor: getColorForType(n.type),
//           child: Icon(getIconForType(n.type), color: Colors.white),
//         ),
//         title: Text(n.title, style: TextStyle(fontWeight: FontWeight.bold)),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(n.body),
//             SizedBox(height: 4),
//             Text(timeago.format(n.date, locale: 'fr'),
//                 style: TextStyle(fontSize: 12, color: Colors.grey)),
//           ],
//         ),
//         isThreeLine: true,
//         trailing: n.isRead
//             ? null
//             : Icon(Icons.fiber_manual_record, color: Colors.blue, size: 12),
//         onTap: () => controller.markAsRead(n),
//       );
// }

// Flutter UI for Onyfast Wallet - Notifications Screen (dynamique via GetX avec Obx)

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:get/get.dart';
import 'package:onyfast/Color/app_color_model.dart';
import 'package:onyfast/Color/visuelles.dart';
import 'package:onyfast/Controller/NotificationController.dart';
import 'package:onyfast/Controller/Validation_token/validationtoken.dart';
import 'package:onyfast/View/OnyPay/listedesPayementEnAttentes.dart';
import 'package:onyfast/model/app_notification.dart';
import 'package:onyfast/verificationcode.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final NotificationController controller = Get.find();
  @override
  void initState() {
    super.initState();
    ValidationTokenController.to.validateToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColorModel.Bluecolor242,
        title: Text(
          controller.loading2.value ? "chargement..." : "Notifications",
          style: TextStyle(
              fontSize: 17.dp,
              fontWeight: FontWeight.bold,
              color: AppColorModel.WhiteColor),
        ),
        centerTitle: true,
        leading: BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          // if (controller.isLoading.value) {
          //   return const Center(child: CupertinoActivityIndicator());
          // }

          if (controller.groupedNotifications.isEmpty) {
            if (controller.isLoading.value) {
              return const Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CupertinoActivityIndicator(), Text('Chargement...')],
              ));
            } else {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.bell_slash,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucune notification',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Vous n\'avez aucune nouvelle notification',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }
          }

          return ListView(
            children: controller.groupedNotifications.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key,
                          style: TextStyle(
                              fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          for (var n in entry.value) {
                            print('🤯🤯🤯🤯🤯${n.toString()}');
                            controller.markAsRead(n);
                          }
                        },
                        child: Text('Tout marquer comme lu',
                            style:
                                TextStyle(color: Colors.blue, fontSize: 12.sp)),
                      )
                    ],
                  ),
                  SizedBox(height: 10),
                  ...entry.value.map(
                      (n) => _NotificationItem(n: n, controller: controller)),
                  SizedBox(height: 20),
                ],
              );
            }).toList(),
          );
        }),
      ),
    );
  }
}

class _NotificationItem extends StatefulWidget {
  final AppNotification n;
  final NotificationController controller;

  const _NotificationItem({required this.n, required this.controller});

  @override
  State<_NotificationItem> createState() => _NotificationItemState();
}

class _NotificationItemState extends State<_NotificationItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final n = widget.n;

    return GestureDetector(
      // 👈 Plus de Obx ici
      onTap: () {
        setState(() => _expanded = !_expanded);
        if (!n.isRead) {
          widget.controller.markAsRead(n);
          setState(() {}); // 👈 Force le rebuild local après markAsRead
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.white : const Color(0xFFF0F4FF),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(
              color: getColorForType(n.type),
              width: 4,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: getColorForType(n.type),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(getIconForType(n.type),
                    color: Colors.white, size: 12.sp),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFF4B6BFB),
                              shape: BoxShape.circle,
                            ),
                          ),
                        // 👇 Flèche expand/collapse
                        Icon(
                          _expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 18,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeago.format(n.date, locale: 'fr'),
                      style: TextStyle(fontSize: 9.sp, color: Colors.grey),
                    ),
                    // 👇 Corps visible seulement si expanded
                    if (_expanded) ...[
                      const SizedBox(height: 6),
                      Text(
                        n.body,
                        style: TextStyle(
                            fontSize: 10.sp, color: Color(0xFF444444)),
                      ),
                      if ((n.type).toUpperCase() ==
                          'Onypay Confirmation'.toUpperCase()) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColorModel.Bluecolor242,
                              side:
                                  BorderSide(color: AppColorModel.Bluecolor242),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            icon: const Icon(Icons.payment_rounded, size: 16),
                            label: const Text('Voir le paiement',
                                style: TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w600)),
                            onPressed: () {
                              CodeVerification().show(
                                context,
                                () async {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.pop(context);
                                  }

                                  Get.to(PaiementsEnAttentePage(),
                                      transition: Transition.cupertino);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
