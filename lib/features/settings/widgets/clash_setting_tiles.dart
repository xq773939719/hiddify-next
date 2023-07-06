import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hiddify/core/core_providers.dart';
import 'package:hiddify/core/prefs/prefs.dart';
import 'package:hiddify/domain/clash/clash.dart';
import 'package:hiddify/features/settings/widgets/settings_input_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:recase/recase.dart';

class ClashSettingTiles extends HookConsumerWidget {
  const ClashSettingTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final overrides =
        ref.watch(prefsControllerProvider.select((value) => value.clash));
    final notifier = ref.watch(prefsControllerProvider.notifier);

    return Column(
      children: [
        InputOverrideTile(
          title: t.settings.clash.overrides.httpPort,
          value: overrides.httpPort,
          resetValue: ClashConfig.initial.httpPort,
          onChange: (value) => notifier.patchClashOverrides(
            ClashConfigPatch(httpPort: value),
          ),
        ),
        InputOverrideTile(
          title: t.settings.clash.overrides.socksPort,
          value: overrides.socksPort,
          resetValue: ClashConfig.initial.socksPort,
          onChange: (value) => notifier.patchClashOverrides(
            ClashConfigPatch(socksPort: value),
          ),
        ),
        InputOverrideTile(
          title: t.settings.clash.overrides.redirPort,
          value: overrides.redirPort,
          onChange: (value) => notifier.patchClashOverrides(
            ClashConfigPatch(redirPort: value),
          ),
        ),
        InputOverrideTile(
          title: t.settings.clash.overrides.tproxyPort,
          value: overrides.tproxyPort,
          onChange: (value) => notifier.patchClashOverrides(
            ClashConfigPatch(tproxyPort: value),
          ),
        ),
        InputOverrideTile(
          title: t.settings.clash.overrides.mixedPort,
          value: overrides.mixedPort,
          resetValue: ClashConfig.initial.mixedPort,
          onChange: (value) => notifier.patchClashOverrides(
            ClashConfigPatch(mixedPort: value),
          ),
        ),
        ToggleOverrideTile(
          title: t.settings.clash.overrides.allowLan,
          value: overrides.allowLan,
          onChange: (value) => notifier.patchClashOverrides(
            ClashConfigPatch(allowLan: value),
          ),
        ),
        ToggleOverrideTile(
          title: t.settings.clash.overrides.ipv6,
          value: overrides.ipv6,
          onChange: (value) => notifier.patchClashOverrides(
            ClashConfigPatch(ipv6: value),
          ),
        ),
        ChoiceOverrideTile(
          title: t.settings.clash.overrides.mode,
          value: overrides.mode,
          options: TunnelMode.values,
          onChange: (value) => notifier.patchClashOverrides(
            ClashConfigPatch(mode: value),
          ),
        ),
        ChoiceOverrideTile(
          title: t.settings.clash.overrides.logLevel,
          value: overrides.logLevel,
          options: LogLevel.values,
          onChange: (value) => notifier.patchClashOverrides(
            ClashConfigPatch(logLevel: value),
          ),
        ),
      ],
    );
  }
}

class InputOverrideTile extends HookConsumerWidget {
  const InputOverrideTile({
    super.key,
    required this.title,
    required this.value,
    this.resetValue,
    required this.onChange,
  });

  final String title;
  final int? value;
  final int? resetValue;
  final ValueChanged<Option<int>> onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return ListTile(
      title: Text(title),
      leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyMedium,
      trailing: Text(
        value == null
            ? t.settings.clash.doNotModify.sentenceCase
            : value.toString(),
      ),
      onTap: () async {
        final result = await SettingsInputDialog<int>(
          title: title,
          initialValue: value,
          resetValue: optionOf(resetValue),
        ).show(context).then(
          (value) {
            return value?.match<Option<int>?>(
              () => none(),
              (t) {
                final i = int.tryParse(t);
                return i == null ? null : some(i);
              },
            );
          },
        );
        if (result == null) return;
        onChange(result);
      },
    );
  }
}

class ToggleOverrideTile extends HookConsumerWidget {
  const ToggleOverrideTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChange,
  });

  final String title;
  final bool? value;
  final ValueChanged<Option<bool>> onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return PopupMenuButton<Option<bool>>(
      initialValue: optionOf(value),
      onSelected: onChange,
      child: ListTile(
        title: Text(title),
        leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyMedium,
        trailing: Text(
          (value == null
                  ? t.settings.clash.doNotModify
                  : value!
                      ? t.general.toggle.enabled
                      : t.general.toggle.disabled)
              .sentenceCase,
        ),
      ),
      itemBuilder: (_) {
        return [
          PopupMenuItem(
            value: none(),
            child: Text(t.settings.clash.doNotModify.sentenceCase),
          ),
          PopupMenuItem(
            value: some(true),
            child: Text(t.general.toggle.enabled.sentenceCase),
          ),
          PopupMenuItem(
            value: some(false),
            child: Text(t.general.toggle.disabled.sentenceCase),
          ),
        ];
      },
    );
  }
}

class ChoiceOverrideTile<T extends Enum> extends HookConsumerWidget {
  const ChoiceOverrideTile({
    super.key,
    required this.title,
    required this.value,
    required this.options,
    required this.onChange,
  });

  final String title;
  final T? value;
  final List<T> options;
  final ValueChanged<Option<T>> onChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return PopupMenuButton<Option<T>>(
      initialValue: optionOf(value),
      onSelected: onChange,
      child: ListTile(
        title: Text(title),
        leadingAndTrailingTextStyle: Theme.of(context).textTheme.bodyMedium,
        trailing: Text(
          (value == null ? t.settings.clash.doNotModify : value!.name)
              .sentenceCase,
        ),
      ),
      itemBuilder: (_) {
        return [
          PopupMenuItem(
            value: none(),
            child: Text(t.settings.clash.doNotModify.sentenceCase),
          ),
          ...options.map(
            (e) => PopupMenuItem(
              value: some(e),
              child: Text(e.name.sentenceCase),
            ),
          ),
        ];
      },
    );
  }
}
