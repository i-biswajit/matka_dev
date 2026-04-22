import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:matka_dev/core/error/app_exception.dart';
import 'package:matka_dev/core/storage/auth_storage.dart';
import '../../../data/repositories/password_repository.dart';

part 'password_update_event.dart';
part 'password_update_state.dart';

class PasswordUpdateBloc
    extends Bloc<PasswordUpdateEvent, PasswordUpdateState> {
  final PasswordRepository repository;

  PasswordUpdateBloc({required this.repository}) : super(PasswordInitial()) {
    on<PasswordUpdateRequested>(_onPasswordUpdateRequested);
  }

  Future<void> _onPasswordUpdateRequested(
    PasswordUpdateRequested event,
    Emitter<PasswordUpdateState> emit,
  ) async {
    emit(PasswordLoading());

    try {
      final success = await repository.updatePassword(event.newPassword);

      if (success) {
        await AuthStorage.logout();
        emit(const PasswordSuccess(
            "Password updated successfully. Please login again."));
      } else {
        emit(const PasswordFailure("Failed to update password"));
      }
    } catch (e) {
      if (e is AppException) {
        emit(PasswordFailure(e.message));
      } else {
        emit(const PasswordFailure("Something went wrong"));
      }
    }
  }
}
