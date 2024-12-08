import 'dart:math';

import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weekly_todo/constants.dart';
import 'package:weekly_todo/models/task.dart';
import 'package:weekly_todo/riverpods/note.dart';
import 'package:weekly_todo/utils/extensions.dart';
import 'package:weekly_todo/widgets/create_note_dialog.dart';
import 'package:weekly_todo/widgets/date_selector.dart';
import 'package:weekly_todo/widgets/search_bar.dart';
import 'package:weekly_todo/widgets/task_edit_dialog.dart';
import 'package:weekly_todo/widgets/tasks_panel.dart';

class Layout extends ConsumerWidget {
  const Layout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScrollController controller = ScrollController();
    return DragTarget(
      onAcceptWithDetails: (details) {
        if (details.data is Task) {
          ref.read(currentNoteProvider.notifier).updateTask(details.data as Task, isDelete: true);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(DSize.widgetPadding),
              child: Row(
                children: [
                  const Flexible(child: DateSelector()),
                  const SizedBox(width: DSize.defaultPadding),
                  const Flexible(child: SearchBar()),
                  const SizedBox(width: DSize.defaultPadding),
                  IconButton(
                    onPressed: () {
                      if (ref.read(allNotesProvider).first.date.startDateOfWeek == DateTime.now().startDateOfWeek) {
                        TaskEditingDialog.show(
                          context,
                          title: '',
                        ).then(
                          (value) {
                            if (value != null) {
                              var (title, content) = value;
                              ref.read(currentNoteProvider.notifier).updateTask(Task(title: title, content: content));
                            }
                          },
                        );
                      } else {
                        CreateNoteDialog.show(
                          context,
                          week: ref.read(currentNoteProvider).date.weekRange,
                        ).then(
                          (value) {
                            late ProviderSubscription<List<String>> subscription;
                            subscription = ref.listenManual(
                              allNotesProvider,
                              (previous, next) {
                                if (next.length == (previous?.length ?? 0) + 1) {
                                  ref.read(currentNoteProvider.notifier).changeNote(next.first);
                                  subscription.close();
                                }
                              },
                            );
                            ref.read(currentNoteProvider.notifier).createNote(
                                  ref.read(currentNoteProvider),
                                );
                          },
                        );
                      }
                    },
                    icon: Container(
                      height: DSize.inputFieldHeight,
                      width: DSize.inputFieldHeight,
                      decoration: BoxDecoration(
                        color: DColors.activeColor,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: DSize.icon,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: LayoutBuilder(builder: (context, constraints) {
                return Scrollbar(
                  scrollbarOrientation: ScrollbarOrientation.bottom,
                  interactive: true,
                  controller: controller,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: controller,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: max(constraints.minWidth, 1260), maxWidth: max(constraints.maxWidth, 1260)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const TasksPanel(type: Status.todo),
                          const TasksPanel(type: Status.wip),
                          const TasksPanel(type: Status.done),
                        ]
                            .map(
                              (panel) => Flexible(child: panel),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}
