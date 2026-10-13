import 'package:flutter_bloc/flutter_bloc.dart';
import 'phone_auth_event.dart';
import 'phone_auth_state.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../../../core/error/failures.dart';

class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  final AuthRepository _authRepository;

  PhoneAuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const PhoneAuthInitial()) {
    on<SendPhoneOtpEvent>(_onSendOtp);
    on<VerifyPhoneOtpEvent>(_onVerifyOtp);
    on<ResetPhoneAuthStateEvent>((event, emit) => emit(const PhoneAuthInitial()));
  }

  Future<void> _onSendOtp(
    SendPhoneOtpEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(const PhoneAuthLoading(message: 'Sending verification code...'));
    try {
      final devOtp = await _authRepository.sendPhoneOtp(event.phoneNumber);
      emit(PhoneAuthCodeSentState(
        phoneNumber: event.phoneNumber,
        devOtp: devOtp,
      ));
    } catch (e) {
      final message = e is Failure ? e.message : e.toString();
      emit(PhoneAuthFailureState(errorMessage: message));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyPhoneOtpEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(const PhoneAuthLoading(message: 'Verifying code...'));
    try {
      final user = await _authRepository.verifyPhoneOtp(
        phoneNumber: event.phoneNumber,
        otp: event.otp,
        fullName: event.fullName,
      );
      emit(PhoneAuthSuccessState(user: user));
    } catch (e) {
      final message = e is Failure ? e.message : e.toString();
      emit(PhoneAuthFailureState(errorMessage: message));
    }
  }
}
