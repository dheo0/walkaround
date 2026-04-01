import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

// 현재 로그인된 사용자 상태
final authStateProvider = AsyncNotifierProvider<AuthNotifier, AuthUser?>(
  AuthNotifier.new,
);

class AuthNotifier extends AsyncNotifier<AuthUser?> {
  @override
  Future<AuthUser?> build() async {
    // 앱 시작 시 저장된 토큰으로 사용자 정보 복원
    return ref.read(authRepositoryProvider).getCurrentUser();
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).signInWithGoogle(),
    );
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}
