import 'package:bloc/bloc.dart';
import 'package:gh6_ucap/services/user_preferences.dart';
import 'package:meta/meta.dart';
import '../../services/profile_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileService _profileService;

  ProfileBloc({required ProfileService profileService})
    : _profileService = profileService,
      super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<CompleteQuest>(_onCompleteQuest);
    on<UpdateProfile>(_onUpdateProfile);
    on<RefreshProfile>(_onRefreshProfile);
    // on<SignOut>(_onSignOut);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final userData = await _profileService.getUserProfile();
      if (userData != null) {
        emit(ProfileLoaded(userData: userData));
      } else {
        emit(ProfileError(message: 'User not authenticated'));
      }
    } catch (e) {
      print('Error loading profile: $e');
      emit(ProfileError(message: 'Failed to load profile: $e'));
    }
  }

  Future<void> _onCompleteQuest(
    CompleteQuest event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;

      try {
        await _profileService.completeQuest(event.questIndex, event.expGained);

        // ✅ Ambil data terbaru dari SharedPreferences
        final updatedUserData = await UserPreferences.getUserData();
        if (updatedUserData != null) {
          emit(
            ProfileQuestCompleted(
              userData: updatedUserData,
              expGained: event.expGained,
            ),
          );
          await Future.delayed(const Duration(milliseconds: 100));
          emit(ProfileLoaded(userData: updatedUserData));
        }
      } catch (e) {
        print('Error completing quest: $e');
        emit(ProfileLoaded(userData: currentState.userData));
      }
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoaded) {
      final currentState = state as ProfileLoaded;

      try {
        emit(ProfileUpdating(userData: currentState.userData));

        await _profileService.updateUserProfile(
          fullname: event.fullname,
          profileImageUrl: event.profileImageUrl,
        );

        // Reload profile data
        final updatedUserData = await _profileService.getUserProfile();
        if (updatedUserData != null) {
          emit(ProfileLoaded(userData: updatedUserData));
        }
      } catch (e) {
        print('Error updating profile: $e');
        emit(ProfileLoaded(userData: currentState.userData));
      }
    }
  }

  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      final userData = await _profileService.getUserProfile();
      if (userData != null) {
        emit(ProfileLoaded(userData: userData));
      } else {
        emit(ProfileError(message: 'User not authenticated'));
      }
    } catch (e) {
      print('Error refreshing profile: $e');
      emit(ProfileError(message: 'Failed to refresh profile: $e'));
    }
  }

  // Future<void> _onSignOut(SignOut event, Emitter<ProfileState> emit) async {
  //   try {
  //     await _profileService.signOut();
  //     emit(ProfileSignedOut());
  //   } catch (e) {
  //     print('Error signing out: $e');
  //     emit(ProfileError(message: 'Failed to sign out'));
  //   }
  // }
}
