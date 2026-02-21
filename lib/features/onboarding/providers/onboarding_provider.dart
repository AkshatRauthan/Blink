import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the user's chosen name and avatar during onboarding.
class OnboardingNotifier extends Notifier<AsyncValue<({String name, String? avatarPath})>> {
  @override
  AsyncValue<({String name, String? avatarPath})> build() =>
      const AsyncData((name: '', avatarPath: null));

  void setName(String name) {
    state = AsyncData((name: name, avatarPath: state.value?.avatarPath));
  }

  void setAvatar(String path) {
    state = AsyncData(
        (name: state.value?.name ?? '', avatarPath: path));
  }

  Future<void> save() async {
    final data = state.value;
    if (data == null || data.name.isEmpty) return;
    state = const AsyncLoading();
    // TODO: Persist name + avatar path to SQLite / secure storage
    await Future.delayed(const Duration(milliseconds: 300));
    state = AsyncData(data);
  }
}

final onboardingNotifierProvider = NotifierProvider<OnboardingNotifier,
    AsyncValue<({String name, String? avatarPath})>>(
  OnboardingNotifier.new,
);
