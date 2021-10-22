// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:musicplayer/utils/colors.dart';

showModalBottom({
  required BuildContext context,
  required Widget child,
  Color? color,
}) {
  color = color ?? xPrimary;

  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    barrierColor: xDark.withOpacity(.2),
    backgroundColor: xTransparent,
    elevation: .5,
    builder: (context) {
      return Container(
        width: double.infinity,
        color: color,
        child: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: child,
        ),
      );
    },
  );
}
