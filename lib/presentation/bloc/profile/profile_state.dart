part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String email;
  final String mobile;
  final bool isEdit;
  final String? successMessage; // add this

  ProfileLoaded({
    required this.name,
    required this.email,
    required this.mobile,
    this.isEdit = false,
    this.successMessage,
  });

  ProfileLoaded copyWith({
    String? name,
    String? email,
    String? mobile,
    bool? isEdit,
    String? successMessage,
  }) {
    return ProfileLoaded(
      name: name ?? this.name,
      email: email ?? this.email,
      mobile: mobile ?? this.mobile,
      isEdit: isEdit ?? this.isEdit,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [name, email, mobile, isEdit];
}

class ProfileSuccess extends ProfileState {
  final String message;
  ProfileSuccess(this.message);
}

class ProfileFailure extends ProfileState {
  final String error;
  ProfileFailure(this.error);
}
