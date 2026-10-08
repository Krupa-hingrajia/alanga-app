import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class LanguageState extends Equatable {
  final Locale locale;

  const LanguageState({
    this.locale = const Locale('en'),
  });

  LanguageState copyWith({
    Locale? locale,
  }) {
    return LanguageState(
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [locale];
}
