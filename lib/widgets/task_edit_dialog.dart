import 'dart:math';

import 'package:flutter/material.dart';
import 'package:weekly_todo/constants.dart';
import 'package:weekly_todo/utils/extensions.dart';
import 'package:weekly_todo/widgets/dde_button.dart';
import 'package:weekly_todo/widgets/dde_text_field.dart';

late String _title;
late String? _content;
bool update = false;

class TaskEditingDialog {
  static Future<(String, String?)?> show(BuildContext context, {required String title, String? content}) {
    update = false;
    _title = title;
    _content = content;
    final saveBtnFocusNode = FocusNode();
    return showDialog<bool>(
      context: context,
      barrierColor: DColors.barrier,
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 800,
            height: 600,
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
            child: StatefulBuilder(builder: (context, setState) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Column(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          child: DTextField(
                            onComplete: (value) {
                              _title = value;
                              return true;
                            },
                            initText: title,
                            style: DTextStyle.subTitle,
                          ),
                        ),
                        const SizedBox(height: DSize.widgetPadding),
                        Flexible(
                          flex: 5,
                          child: DTextField(
                            onComplete: (value) {
                              _content = value;
                              return true;
                            },
                            initText: content,
                            style: DTextStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: DSize.defaultPadding),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      DButton.cancel(
                        width: min(context.screenSize.shortestSide * 0.3, 260),
                        onTap: () {
                          update = false;
                          context.pop();
                        },
                      ),
                      Focus(
                        focusNode: saveBtnFocusNode,
                        child: DButton.save(
                          width: min(context.screenSize.shortestSide * 0.3, 260),
                          onTap: () {
                            saveBtnFocusNode.requestFocus();
                            update = true;
                            context.pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    ).then((value) {
      return update ? (_title, _content) : null;
    });
  }
}
