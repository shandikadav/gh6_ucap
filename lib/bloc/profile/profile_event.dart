part of 'profile_bloc.dart';

abstract class ProfileEvent {}

class LoadProfile extends ProfileEvent {}

class CompleteQuest extends ProfileEvent {
  final int questIndex;
  final int expGained;

  CompleteQuest({
    required this.questIndex,
    required this.expGained,
  });
}

class UpdateProfile extends ProfileEvent {
  final String? fullname;
  final String? profileImageUrl;

  UpdateProfile({
    this.fullname,
    this.profileImageUrl,
  });
}

class RefreshProfile extends ProfileEvent {}

class SignOut extends ProfileEvent {}
