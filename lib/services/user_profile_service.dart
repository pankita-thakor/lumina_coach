import 'functions_client.dart';

class UserProfileService {
  UserProfileService(this._fn);

  final FunctionsClient _fn;

  Future<void> updateOnboarding({
    String? communicationGoal,
    String? toneStyle,
    List<String>? challenges,
  }) async {
    await _fn.invoke(
      'update-profile',
      body: {
        if (communicationGoal != null) 'communication_goal': communicationGoal,
        if (toneStyle != null) 'tone_style': toneStyle,
        if (challenges != null) 'challenges': challenges,
      },
    );
  }
}
