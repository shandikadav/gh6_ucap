part of 'profile_bloc.dart';

sealed class ProfileState {
  const ProfileState();

  @override
  List<Object> get props => [];
}

final class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Map<String, dynamic> userData;

  ProfileLoaded({required this.userData});
}

class ProfileUpdating extends ProfileState {
  final Map<String, dynamic> userData;

  ProfileUpdating({required this.userData});
}

class ProfileQuestCompleted extends ProfileState {
  final Map<String, dynamic> userData;
  final int expGained;

  ProfileQuestCompleted({required this.userData, required this.expGained});
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});
}

class ProfileSignedOut extends ProfileState {}
