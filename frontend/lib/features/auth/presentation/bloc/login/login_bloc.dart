import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../../../../core/error/failures.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase _loginUseCase;

  LoginBloc({required LoginUseCase loginUseCase})
      : _loginUseCase = loginUseCase,
        super(LoginInitial()) {
    on<LoginSubmittedEvent>(_onLoginSubmitted);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmittedEvent event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());
    try {
      final user = await _loginUseCase(
        LoginParams(identifier: event.identifier, password: event.password),
      );
      emit(LoginSuccess(user: user));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      } else if (e is NetworkFailure) {
        message = e.message;
      }
      emit(LoginFailure(errorMessage: message));
    }
  }
}
