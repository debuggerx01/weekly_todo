import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shake_animated/flutter_shake_animated.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:weekly_todo/constants.dart';
import 'package:weekly_todo/models/task.dart';
import 'package:weekly_todo/riverpods/note.dart';
import 'package:weekly_todo/riverpods/task_effect.dart';
import 'package:weekly_todo/widgets/task_card.dart';
import 'package:weekly_todo/widgets/task_edit_dialog.dart';

class TasksPanel extends ConsumerStatefulWidget {
  final Status type;

  const TasksPanel({
    super.key,
    required this.type,
  });

  @override
  ConsumerState createState() => _TasksPanelState();
}

class _TasksPanelState extends ConsumerState<TasksPanel> {
  late ItemScrollController itemScrollController;

  @override
  void initState() {
    itemScrollController = ItemScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var tasks = ref
        .watch(currentNoteProvider)
        .tasks
        .where(
          (task) => task.status == widget.type,
        )
        .toList()
      ..sort(
        (a, b) {
          if (a.priority == b.priority) {
            switch (widget.type) {
              case Status.todo:
                return a.createdAt.compareTo(b.createdAt);
              case Status.wip:
                return a.startedAt!.compareTo(b.startedAt!);
              case Status.done:
                return a.completedAt!.compareTo(b.completedAt!);
            }
          }
          return a.priority.index.compareTo(b.priority.index);
        },
      );
    var shakeTaskId = ref.watch(taskEffectProvider);
    if (shakeTaskId != null) {
      var index = tasks.indexWhere((task) => task.id == shakeTaskId);
      if (index >= 0) {
        itemScrollController.scrollTo(
          index: index,
          duration: const Duration(milliseconds: 250),
        );
      }
    }

    return Column(
      children: [
        Text(
          '${widget.type.name.toUpperCase()} (${tasks.length})',
          style: DTextStyle.title,
        ),
        Flexible(
          child: GestureDetector(
            onDoubleTap: () {
              TaskEditingDialog.show(context, title: '').then(
                (value) {
                  if (value != null) {
                    var (title, content) = value;
                    ref.read(currentNoteProvider.notifier).updateTask(
                          Task(
                            title: title,
                            content: content,
                            status: widget.type,
                            startedAt: widget.type != Status.todo ? DateTime.now() : null,
                            completedAt: widget.type == Status.done ? DateTime.now() : null,
                          ),
                        );
                  }
                },
              );
            },
            child: DragTarget<Task>(
              onAcceptWithDetails: (details) {
                ref.read(currentNoteProvider.notifier).updateTask(
                      details.data.copyWith(status: widget.type),
                    );
              },
              builder: (context, candidateData, rejectedData) => Container(
                padding: const EdgeInsets.all(DSize.widgetPadding),
                margin: const EdgeInsets.all(DSize.widgetPadding),
                decoration: BoxDecoration(
                  color: candidateData.isNotEmpty && candidateData.first!.status != widget.type ? DColors.backgroundLight : DColors.backgroundNormal,
                  borderRadius: DRadius.borderRadiusLarge,
                ),
                child: ScrollablePositionedList.builder(
                  itemScrollController: itemScrollController,
                  padding: const EdgeInsets.only(bottom: DSize.windowPadding),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(left: DSize.widgetPadding, right: DSize.widgetPadding, top: DSize.widgetPadding),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Draggable(
                        data: tasks[index],
                        feedback: ConstrainedBox(
                          constraints: constraints,
                          child: Material(
                            borderRadius: DRadius.borderRadiusSmall,
                            child: TaskCard(task: tasks[index]),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.6,
                          child: TaskCard(task: tasks[index]),
                        ),
                        child: shakeTaskId == tasks[index].id
                            ? AnimatedScale(
                                scale: 1.05,
                                duration: const Duration(milliseconds: 300),
                                child: ShakeWidget(
                                  autoPlay: true,
                                  duration: const Duration(seconds: 3),
                                  shakeConstant: ShakeRotateConstant1(),
                                  child: TaskCard(task: tasks[index]),
                                ),
                              )
                            : AnimatedScale(
                                scale: 1,
                                duration: const Duration(milliseconds: 300),
                                child: TaskCard(task: tasks[index]),
                              ),
                      );
                    }),
                  ),
                  itemCount: tasks.length,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
