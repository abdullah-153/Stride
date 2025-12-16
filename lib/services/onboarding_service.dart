class OnboardingService {
  int? age;
  String? gender;
  double? height;
  double? weight;
  String? fitnessLevel;

  Future<void> saveUserOnboardingData({
    required int age,
    required String gender,
    required double height,
    required double weight,
    required String fitnessLevel,
  }) async {
    this.age = age;
    this.gender = gender;
    this.height = height;
    this.weight = weight;
    this.fitnessLevel = fitnessLevel;

    await Future.delayed(const Duration(milliseconds: 200));
  }
}
