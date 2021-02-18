class Settings {
  bool useLock;
  bool onboardingDone;

  Settings({this.useLock = false, this.onboardingDone = false});

  factory Settings.fromJson(dynamic json) {
    return Settings(
        useLock: json['useLock'] as bool,
        onboardingDone: json['onboardingDone'] as bool);
  }

  Map<String, dynamic> toJson() => {
        'useLock': useLock,
        'onboardingDone': onboardingDone,
      };
}
