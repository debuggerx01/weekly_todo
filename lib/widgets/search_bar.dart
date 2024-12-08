import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weekly_todo/constants.dart';
import 'package:weekly_todo/riverpods/note.dart';
import 'package:weekly_todo/riverpods/task_effect.dart';
import 'package:weekly_todo/utils/extensions.dart';
import 'package:weekly_todo/utils/fs.dart';

class SearchBar extends ConsumerWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late TextEditingController controller;
    return Container(
      decoration: BoxDecoration(
        borderRadius: DRadius.borderRadiusMedium,
        color: DColors.backgroundLight,
      ),
      padding: const EdgeInsets.symmetric(vertical: DSize.widgetPadding, horizontal: DSize.defaultPadding),
      child: Autocomplete<SearchResult>(
        optionsBuilder: (textEditingValue) {
          if (textEditingValue.text.trim().isEmpty) return [];
          return ref.read(allNotesProvider.notifier).search(textEditingValue.text);
        },
        onSelected: (option) {
          ref.read(currentNoteProvider.notifier).changeNote(option.date);
          controller.clear();
          ref.read(taskEffectProvider.notifier).shake(option.id);
        },
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          controller = textEditingController;
          return TextField(
            decoration: const InputDecoration(
              border: InputBorder.none,
              isCollapsed: true,
              icon: Icon(
                Icons.search,
                size: DSize.icon,
              ),
            ),
            controller: textEditingController,
            focusNode: focusNode,
            onSubmitted: (value) => onFieldSubmitted(),
            cursorColor: DColors.activeColor,
            style: DTextStyle.subTitle,
            maxLines: 1,
          );
        },
        optionsViewBuilder: (context, onSelected, options) => Align(
          alignment: Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: DRadius.borderRadiusMedium,
              color: Colors.black,
            ),
            constraints: BoxConstraints(maxHeight: 300, maxWidth: (min(context.screenWidth, 1920) - 240) / 2),
            child: ClipRRect(
              borderRadius: DRadius.borderRadiusMedium,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: DSize.widgetPadding / 2),
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final SearchResult option = options.elementAt(index);
                  return InkWell(
                    onTap: () {
                      onSelected(option);
                    },
                    child: Builder(builder: (BuildContext context) {
                      final bool highlight = AutocompleteHighlightedOption.of(context) == index;
                      if (highlight) {
                        SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
                          Scrollable.ensureVisible(context, alignment: 0.5);
                        }, debugLabel: 'AutocompleteOptions.ensureVisible');
                      }
                      return Container(
                        color: highlight ? DColors.backgroundLight : Colors.black,
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          option.toString(),
                          style: DTextStyle.normal,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
