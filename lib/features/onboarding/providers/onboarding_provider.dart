import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings/providers/settings_provider.dart';

class OnboardingState {
  final String name;
  final String? avatarPath;
  final bool isSaving;

  const OnboardingState({
    this.name = '',
    this.avatarPath,
    this.isSaving = false,
  });

  OnboardingState copyWith({
    String? name,
    String? avatarPath,
    bool clearAvatar = false,
    bool? isSaving,
  }) =>
      OnboardingState(
        name: name ?? this.name,
        avatarPath: clearAvatar ? null : (avatarPath ?? this.avatarPath),
        isSaving: isSaving ?? this.isSaving,
      );
}

class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() => const OnboardingState();

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setAvatar(String path) {
    state = state.copyWith(avatarPath: path);
  }

  Future<bool> save() async {
    if (state.name.trim().isEmpty) return false;
    state = state.copyWith(isSaving: true);
    try {
      await ref.read(settingsNotifierProvider.notifier).completeOnboarding(
            displayName: state.name.trim(),
            avatarPath: state.avatarPath,
          );
      return true;
    } catch (_) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);
