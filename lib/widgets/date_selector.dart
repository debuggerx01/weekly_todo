import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weekly_todo/constants.dart';
import 'package:weekly_todo/riverpods/note.dart';
import 'package:weekly_todo/utils/extensions.dart';

class DateSelector extends ConsumerWidget {
  const DateSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var allNotes = ref.watch(allNotesProvider);
    var current = ref.watch(currentNoteProvider).date;
    var dateOfThisWeek = DateTime.now().startDateStrOfWeek;
    return Container(
      decoration: BoxDecoration(
        borderRadius: DRadius.borderRadiusMedium,
        color: DColors.backgroundLight,
      ),
      padding: const EdgeInsets.symmetric(horizontal: DSize.defaultPadding, vertical: DSize.widgetPadding / 3),
      child: DropdownButton(
        isExpanded: true,
        value: current.weekRange,
        style: DTextStyle.subTitle,
        icon: const Icon(Icons.keyboard_arrow_down, size: DSize.icon),
        underline: const SizedBox.shrink(),
        borderRadius: DRadius.borderRadiusMedium,
        items: allNotes
            .map(
              (noteDate) => DropdownMenuItem(
                value: noteDate.weekRange,
                child: Text(
                  '${noteDate.weekRange}${noteDate == dateOfThisWeek ? ' (本周)' : ''}',
                  style: DTextStyle.normal,
                ),
              ),
            )
            .toList(),
        onChanged: (String? value) {
          if (value != null) {
            ref.read(currentNoteProvider.notifier).changeNote(value.split(' ').first.replaceAll('/', '_'));
          }
        },
      ),
    );
  }
}
