import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:weekly_todo/constants.dart';
import 'package:weekly_todo/models/task.dart';
import 'package:weekly_todo/riverpods/note.dart';
import 'package:weekly_todo/utils/extensions.dart';
import 'package:weekly_todo/widgets/markdown_preview.dart';
import 'package:weekly_todo/widgets/task_edit_dialog.dart';

class TaskCard extends ConsumerWidget {
  final Task task;

  const TaskCard({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final SuperTooltipController superTooltipController = SuperTooltipController();
    var time = task.completedAt ?? task.startedAt ?? task.createdAt;
    return InkWell(
      onTap: () {
        TaskEditingDialog.show(
          context,
          title: task.title,
          content: task.content,
        ).then(
          (value) {
            if (value != null) {
              var (title, content) = value;
              ref.read(currentNoteProvider.notifier).updateTask(
                    task.copyWith(
                      title: title,
                      content: content,
                    ),
                  );
            }
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: DRadius.borderRadiusMedium,
          color: Colors.black38,
        ),
        padding: const EdgeInsets.symmetric(vertical: DSize.widgetPadding, horizontal: DSize.defaultPadding),
        child: Column(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MouseRegion(
                      cursor: MouseCursor.uncontrolled,
                      onHover: (evt) {
                        if (!superTooltipController.isVisible) {
                          superTooltipController.showTooltip();
                        }
                      },
                      onExit: (evt) {
                        superTooltipController.hideTooltip();
                      },
                      child: Container(
                        alignment: Alignment.centerLeft,
                        height: DSize.icon,
                        child: Text(
                          '${task.status.timeStr}时间: ${time.timeStr}',
                          style: DTextStyle.normal.copyWith(
                            color: DColors.secondaryText,
                            fontSize: DTextStyle.normal.fontSize! - 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: DSize.icon,
                      child: DropdownButton<Priority>(
                        dropdownColor: DColors.backgroundDeep,
                        focusColor: Colors.transparent,
                        value: task.priority,
                        underline: const SizedBox.shrink(),
                        icon: const SizedBox.shrink(),
                        borderRadius: DRadius.borderRadiusMedium,
                        onChanged: (value) {
                          ref.read(currentNoteProvider.notifier).updateTask(task.copyWith(priority: value));
                        },
                        items: Priority.values
                            .map(
                              (priority) => DropdownMenuItem<Priority>(
                                value: priority,
                                child: Icon(
                                  Icons.flag,
                                  color: priority.color,
                                  size: DSize.icon,
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 130),
                    child: SuperTooltip(
                      showBarrier: false,
                      showOnTap: false,
                      controller: superTooltipController,
                      backgroundColor: DColors.backgroundLight,
                      arrowTipRadius: 2,
                      arrowLength: 8,
                      content: Padding(
                        padding: const EdgeInsets.all(DSize.widgetPadding / 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${Status.todo.timeStr}时间: ${task.createdAt.timeStr}',
                              style: DTextStyle.normal,
                            ),
                            Text(
                              '${Status.wip.timeStr}时间: ${task.startedAt?.timeStr ?? '-'}',
                              style: DTextStyle.normal,
                            ),
                            Text(
                              '${Status.done.timeStr}时间: ${task.completedAt?.timeStr ?? '-'}',
                              style: DTextStyle.normal,
                            ),
                          ],
                        ),
                      ),
                      child: const SizedBox.shrink(),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: MdPreview(
                    text: task.title,
                    textStyle: DTextStyle.subTitle,
                    widgetImage: (String imageUrl) => const SizedBox.shrink(),
                    onCodeCopied: () {},
                  ),
                ),
                if ((task.content ?? '').isNotEmpty)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: DSize.widgetPadding),
                    padding: const EdgeInsets.all(DSize.widgetPadding),
                    decoration: BoxDecoration(
                      color: DColors.backgroundDeep,
                      borderRadius: DRadius.borderRadiusSmall,
                    ),
                    constraints: const BoxConstraints(maxHeight: 130),
                    child: MdPreview(
                      text: task.content!,
                      textStyle: DTextStyle.normal,
                      widgetImage: (String imageUrl) => const SizedBox.shrink(),
                      onCodeCopied: () {},
                      onTapLink: (link) async {
                        if (await canLaunchUrlString(link)) {
                          launchUrlString(link);
                        }
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
