abstract interface class OnboardingRepository {
  Future<bool> isCompleted();
  Future<void> setCompleted(bool completed);
}
