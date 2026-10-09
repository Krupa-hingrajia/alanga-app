import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'phone_auth_event.dart';
import 'phone_auth_state.dart';
import '../../../domain/usecases/phone_auth_usecase.dart';
import '../../../../../core/error/failures.dart';

class PhoneAuthBloc extends Bloc<PhoneAuthEvent, PhoneAuthState> {
  final PhoneAuthUseCase _phoneAuthUseCase;
  final FirebaseAuth _firebaseAuth;

  PhoneAuthBloc({
    required PhoneAuthUseCase phoneAuthUseCase,
    FirebaseAuth? firebaseAuth,
  })  : _phoneAuthUseCase = phoneAuthUseCase,
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const PhoneAuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<DirectPhoneAuthLoginEvent>(_onDirectPhoneAuthLogin);
    on<ResetPhoneAuthStateEvent>((event, emit) => emit(const PhoneAuthInitial()));
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(const PhoneAuthLoading(message: 'Sending verification code...'));

    final completer = Completer<void>();

    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        forceResendingToken: event.forceResendingToken,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Instant auto-verification (Android SMS auto-read)
          try {
            final userCredential = await _firebaseAuth.signInWithCredential(credential);
            final user = userCredential.user;
            if (user != null) {
              add(DirectPhoneAuthLoginEvent(
                phoneNumber: event.phoneNumber,
                firebaseUid: user.uid,
              ));
            }
          } catch (_) {
            // If direct login fails, wait for manual verification
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          final friendlyMessage = _mapFirebaseErrorMessage(e);
          if (!completer.isCompleted) {
            emit(PhoneAuthFailureState(errorMessage: friendlyMessage));
            completer.complete();
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!completer.isCompleted) {
            emit(PhoneAuthCodeSentState(
              verificationId: verificationId,
              phoneNumber: event.phoneNumber,
              resendToken: resendToken,
            ));
            completer.complete();
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Keep current state or let user manual enter OTP
        },
      );

      await completer.future;
    } catch (e) {
      if (!emit.isDone) {
        emit(PhoneAuthFailureState(
          errorMessage: e is FirebaseAuthException
              ? _mapFirebaseErrorMessage(e)
              : 'Failed to send OTP: ${e.toString()}',
        ));
      }
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(const PhoneAuthLoading(message: 'Verifying code...'));

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.smsCode.trim(),
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        emit(const PhoneAuthFailureState(errorMessage: 'Firebase authentication failed. Please try again.'));
        return;
      }

      // Sync verified phone number with Backend API
      final user = await _phoneAuthUseCase(
        phoneNumber: event.phoneNumber,
        firebaseUid: firebaseUser.uid,
        fullName: event.fullName,
        businessName: event.businessName,
        email: event.email,
      );

      emit(PhoneAuthSuccessState(user: user));
    } on FirebaseAuthException catch (e) {
      emit(PhoneAuthFailureState(errorMessage: _mapFirebaseErrorMessage(e)));
    } on ServerFailure catch (e) {
      emit(PhoneAuthFailureState(errorMessage: e.message));
    } catch (e) {
      emit(PhoneAuthFailureState(errorMessage: e.toString()));
    }
  }

  Future<void> _onDirectPhoneAuthLogin(
    DirectPhoneAuthLoginEvent event,
    Emitter<PhoneAuthState> emit,
  ) async {
    emit(const PhoneAuthLoading(message: 'Logging in...'));
    try {
      final user = await _phoneAuthUseCase(
        phoneNumber: event.phoneNumber,
        firebaseUid: event.firebaseUid,
        fullName: event.fullName,
        businessName: event.businessName,
        email: event.email,
      );
      emit(PhoneAuthSuccessState(user: user));
    } catch (e) {
      String message = 'Authentication failed';
      if (e is ServerFailure) {
        message = e.message;
      } else {
        message = e.toString();
      }
      emit(PhoneAuthFailureState(errorMessage: message));
    }
  }

  String _mapFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number entered is invalid. Please check the country code and number.';
      case 'quota-exceeded':
        return 'SMS quota exceeded for today. Please try again later or use demo account.';
      case 'too-many-requests':
        return 'Too many requests sent. Please wait a few moments before trying again.';
      case 'session-expired':
        return 'The OTP verification session has expired. Please request a new code.';
      case 'invalid-verification-code':
        return 'The verification code entered is incorrect. Please check and try again.';
      case 'invalid-verification-id':
        return 'Verification session is invalid. Please resend code.';
      case 'network-request-failed':
        return 'Network connection issue. Please check your internet connection.';
      default:
        return e.message ?? 'An error occurred during phone verification.';
    }
  }
}
