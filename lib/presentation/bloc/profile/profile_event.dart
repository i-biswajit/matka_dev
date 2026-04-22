part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

/// Load profile data
class ProfileLoadRequested extends ProfileEvent {}

/// Toggle edit mode
class ProfileEditToggled extends ProfileEvent {}

/// Update profile
class ProfileUpdateRequested extends ProfileEvent {
  final String name;
  final String email;

  ProfileUpdateRequested({
    required this.name,
    required this.email,
  });

  @override
  List<Object?> get props => [name, email];
}
