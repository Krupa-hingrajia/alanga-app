import 'package:flutter_bloc/flutter_bloc.dart';
import 'forgot_password_event.dart';
import 'forgot_password_state.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../../../core/error/failures.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthRepository _authRepository;

  ForgotPasswordBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(ForgotPasswordInitial()) {
    on<ForgotPasswordRequestOtpEvent>(_onRequestOtp);
    on<ForgotPasswordVerifyOtpEvent>(_onVerifyOtp);
    on<ForgotPasswordResetPasswordEvent>(_onResetPassword);
    on<ForgotPasswordResetFlowEvent>(_onResetFlow);
  }

  Future<void> _onRequestOtp(
    ForgotPasswordRequestOtpEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading(step: ForgotPasswordStep.email));
    try {
      final devOtp = await _authRepository.forgotPassword(event.identifier);
      emit(ForgotPasswordOtpSent(
        identifier: event.identifier,
        devOtp: devOtp,
      ));
    } catch (e) {
      final message = e is ServerFailure ? e.message : e.toString();
      emit(ForgotPasswordFailure(
        errorMessage: message,
        step: ForgotPasswordStep.email,
        identifier: event.identifier,
      ));
    }
  }

  Future<void> _onVerifyOtp(
    ForgotPasswordVerifyOtpEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading(step: ForgotPasswordStep.otp));
    try {
      await _authRepository.verifyOtp(
        identifier: event.identifier,
        otp: event.otp,
      );
      emit(ForgotPasswordOtpVerified(
        identifier: event.identifier,
        otp: event.otp,
      ));
    } catch (e) {
      final message = e is ServerFailure ? e.message : e.toString();
      emit(ForgotPasswordFailure(
        errorMessage: message,
        step: ForgotPasswordStep.otp,
        identifier: event.identifier,
        otp: event.otp,
      ));
    }
  }

  Future<void> _onResetPassword(
    ForgotPasswordResetPasswordEvent event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(const ForgotPasswordLoading(step: ForgotPasswordStep.newPassword));
    try {
      await _authRepository.resetPassword(
        identifier: event.identifier,
        otp: event.otp,
        newPassword: event.newPassword,
      );
      emit(const ForgotPasswordSuccess(
        message: 'Password reset successfully! You can now log in.',
      ));
    } catch (e) {
      final message = e is ServerFailure ? e.message : e.toString();
      emit(ForgotPasswordFailure(
        errorMessage: message,
        step: ForgotPasswordStep.newPassword,
        identifier: event.identifier,
        otp: event.otp,
      ));
    }
  }

  void _onResetFlow(
    ForgotPasswordResetFlowEvent event,
    Emitter<ForgotPasswordState> emit,
  ) {
    emit(ForgotPasswordInitial());
  }
}
