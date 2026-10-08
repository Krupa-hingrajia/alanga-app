import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../storage/secure_storage_service.dart';
import 'language_event.dart';
import 'language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final SecureStorageService _storageService;

  LanguageBloc({required SecureStorageService storageService})
      : _storageService = storageService,
        super(const LanguageState(locale: Locale('en'))) {
    on<LoadSavedLanguageEvent>(_onLoadSavedLanguage);
    on<ChangeLanguageEvent>(_onChangeLanguage);
  }

  Future<void> _onLoadSavedLanguage(
    LoadSavedLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      final code = await _storageService.getLanguageCode();
      if (code != null && ['en', 'ar', 'hi'].contains(code)) {
        emit(state.copyWith(locale: Locale(code)));
      }
    } catch (_) {
      // Fallback to default en
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguageEvent event,
    Emitter<LanguageState> emit,
  ) async {
    try {
      await _storageService.saveLanguageCode(event.locale.languageCode);
    } catch (_) {}
    emit(state.copyWith(locale: event.locale));
  }
}
