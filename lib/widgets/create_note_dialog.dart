import 'dart:math';

import 'package:flutter/material.dart';
import 'package:weekly_todo/constants.dart';
import 'package:weekly_todo/utils/extensions.dart';
import 'package:weekly_todo/widgets/dde_button.dart';

class CreateNoteDialog {
  static Future<(String, String?)?> show(BuildContext context, {required String week}) {
    return showDialog(
      context: context,
      barrierColor: DColors.barrier,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 600,
            height: 320,
            padding: const EdgeInsets.all(DSize.windowPadding),
            decoration: BoxDecoration(
              borderRadius: DRadius.borderRadiusMedium,
              color: DColors.backgroundNormal,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: DSize.defaultPadding,
                  spreadRadius: DSize.widgetPadding,
                  offset: Offset(0, DSize.widgetPadding),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '新的一周开始咯',
                  style: DTextStyle.title,
                ),
                Text(
                  '将自动从【$week】的数据中\n继承未完成的任务',
                  style: DTextStyle.subTitle,
                  textAlign: TextAlign.center,
                ),
                DButton.confirm(
                  width: min(context.screenSize.shortestSide * 0.3, 260),
                  onTap: () {
                    context.pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
