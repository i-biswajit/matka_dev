import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../data/repositories/profile_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({required this.repository}) : super(ProfileInitial()) {
    /// Load profile
    on<ProfileLoadRequested>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await repository.fetchProfile();
        emit(ProfileLoaded(
          name: profile.name,
          email: profile.email ?? '',
          mobile: profile.mobile,
        ));
      } catch (_) {
        emit(ProfileFailure("Failed to load profile"));
      }
    });

    /// Toggle edit mode
    on<ProfileEditToggled>((event, emit) {
      if (state is ProfileLoaded) {
        final s = state as ProfileLoaded;
        emit(ProfileLoaded(
          name: s.name,
          email: s.email,
          mobile: s.mobile,
          isEdit: !s.isEdit,
        ));
      }
    });

    /// Update profile
    on<ProfileUpdateRequested>((event, emit) async {
      emit(ProfileLoading());
      try {
        await repository.updateProfile(
          name: event.name,
          email: event.email,
        );

        final profile = await repository.fetchProfile();
        emit(ProfileLoaded(
          name: profile.name,
          email: profile.email ?? '',
          mobile: profile.mobile,
          successMessage: "Profile updated successfully",
        ));
      } catch (_) {
        emit(ProfileFailure("Update failed"));
      }
    });
  }
}
