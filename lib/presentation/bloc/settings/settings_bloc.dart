import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:matka_dev/core/storage/auth_storage.dart';
import 'package:matka_dev/data/models/settings_model.dart';
import 'package:matka_dev/data/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository repository;

  SettingsBloc(this.repository) : super(SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
  }

  Future<void> _onLoadSettings(
      LoadSettings event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    try {
      final settings = await repository.fetchSettings();
      await AuthStorage.saveSettings(settings);
      emit(SettingsLoaded(settings));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }
}
