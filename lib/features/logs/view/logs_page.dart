import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/domain/failures.dart';
import 'package:hiddify/features/common/common.dart';
import 'package:hiddify/features/logs/notifier/notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class LogsPage extends HookConsumerWidget {
  const LogsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final asyncState = ref.watch(logsNotifierProvider);
    final notifier = ref.watch(logsNotifierProvider.notifier);

    switch (asyncState) {
      case AsyncData(value: final state):
        return Scaffold(
          appBar: AppBar(
            // TODO: fix height
            toolbarHeight: 90,
            title: Text(t.logs.pageTitle.titleCase),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(36),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Flexible(
                      child: TextFormField(
                        onChanged: notifier.filterMessage,
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: t.logs.filterHint.sentenceCase,
                        ),
                      ),
                    ),
                    const Gap(16),
                    DropdownButton<Option<LogLevel>>(
                      value: optionOf(state.levelFilter),
                      onChanged: (v) {
                        if (v == null) return;
                        notifier.filterLevel(v.toNullable());
                      },
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      borderRadius: BorderRadius.circular(4),
                      items: [
                        DropdownMenuItem(
                          value: none(),
                          child: Text(t.logs.allLevelsFilter.sentenceCase),
                        ),
                        ...LogLevel.values.takeFirst(3).map(
                              (e) => DropdownMenuItem(
                                value: some(e),
                                child: Text(e.name.sentenceCase),
                              ),
                            ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: ListView.builder(
            itemCount: state.logs.length,
            reverse: true,
            itemBuilder: (context, index) {
              final log = state.logs[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    dense: true,
                    title: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: log.timeStamp),
                          const TextSpan(text: "   "),
                          TextSpan(
                            text: log.level.name.toUpperCase(),
                            style: TextStyle(color: log.level.color),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Text(log.message),
                  ),
                  if (index != 0)
                    const Divider(
                      indent: 16,
                      endIndent: 16,
                      height: 4,
                    ),
                ],
              );
            },
          ),
        );

      case AsyncError(:final error):
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              NestedTabAppBar(
                title: Text(t.logs.pageTitle.titleCase),
              ),
              SliverErrorBodyPlaceholder(t.presentError(error)),
            ],
          ),
        );

      case AsyncLoading():
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              NestedTabAppBar(
                title: Text(t.logs.pageTitle.titleCase),
              ),
              const SliverLoadingBodyPlaceholder(),
            ],
          ),
        );

      // TODO: remove
      default:
        return const Scaffold();
    }
  }
}
