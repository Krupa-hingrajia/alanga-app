import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../../../../core/error/failures.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final RegisterUseCase _registerUseCase;

  RegisterBloc({required RegisterUseCase registerUseCase})
      : _registerUseCase = registerUseCase,
        super(RegisterInitial()) {
    on<RegisterSubmittedEvent>(_onRegisterSubmitted);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmittedEvent event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());
    try {
      final user = await _registerUseCase(
        RegisterParams(
          fullName: event.fullName,
          email: event.email,
          countryCode: event.countryCode,
          mobileNumber: event.mobileNumber,
          password: event.password,
          confirmPassword: event.confirmPassword,
          role: event.role,
        ),
      );
      emit(RegisterSuccess(user: user));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      } else if (e is NetworkFailure) {
        message = e.message;
      }
      emit(RegisterFailure(errorMessage: message));
    }
  }
}
