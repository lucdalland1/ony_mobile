import 'package:flutter/material.dart';


class IconButtonWidget extends StatelessWidget {
  final void Function()? onPressed;
  final Widget icon;
  const IconButtonWidget({
    required this.onPressed,
    required this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed,
     icon: icon);
  }
}