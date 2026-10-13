import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../bloc/phone_auth/phone_auth_bloc.dart';
import '../bloc/phone_auth/phone_auth_event.dart';
import '../bloc/phone_auth/phone_auth_state.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String? devOtp;
  final String? fullName;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.devOtp,
    this.fullName,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    // Auto-fill devOtp if provided in test/dev mode
    if (widget.devOtp != null && widget.devOtp!.length == 6) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (int i = 0; i < 6; i++) {
          _controllers[i].text = widget.devOtp![i];
        }
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      if (digits.length >= 6) {
        for (int i = 0; i < 6; i++) {
          _controllers[i].text = digits[i];
        }
        _focusNodes[5].requestFocus();
        _verifyOtp(context);
        return;
      }
    }

    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_otpCode.length == 6) {
          _verifyOtp(context);
        }
      }
    }
  }

  void _verifyOtp(BuildContext context) {
    if (_otpCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter complete 6-digit OTP'),
          backgroundColor: AppColors.brandRed,
        ),
      );
      return;
    }

    context.read<PhoneAuthBloc>().add(
          VerifyPhoneOtpEvent(
            phoneNumber: widget.phoneNumber,
            otp: _otpCode,
            fullName: widget.fullName,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return BlocProvider(
      create: (_) => sl<PhoneAuthBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F5),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1A3827), size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 420 : double.infinity,
                ),
                child: BlocConsumer<PhoneAuthBloc, PhoneAuthState>(
                  listener: (context, state) {
                    if (state is PhoneAuthSuccessState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Welcome, ${state.user.fullName}!'),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                      context.go('/home');
                    } else if (state is PhoneAuthFailureState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.errorMessage),
                          backgroundColor: AppColors.brandRed,
                        ),
                      );
                    } else if (state is PhoneAuthCodeSentState) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            state.devOtp != null
                                ? 'New OTP sent! Test code: ${state.devOtp}'
                                : 'OTP resent successfully',
                          ),
                          backgroundColor: AppColors.primaryGreen,
                        ),
                      );
                      _startTimer();
                    }
                  },
                  builder: (context, state) {
                    final isLoading = state is PhoneAuthLoading;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Header Icon
                          Center(
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFEAF3EE),
                              ),
                              child: const Icon(
                                Icons.mark_email_read_outlined,
                                color: AppColors.primaryGreen,
                                size: 40,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          const Text(
                            'OTP Verification',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF11261B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),

                          Text(
                            'We have sent a 6-digit verification code to\n${widget.phoneNumber}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondaryLight,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),

                          Center(
                            child: InkWell(
                              onTap: () => context.pop(),
                              borderRadius: BorderRadius.circular(8),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit, size: 14, color: AppColors.brandOrange),
                                    SizedBox(width: 4),
                                    Text(
                                      'Edit Phone Number',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.brandOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // 6 Digit Input Boxes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              return SizedBox(
                                width: 44,
                                height: 54,
                                child: TextFormField(
                                  controller: _controllers[index],
                                  focusNode: _focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF11261B),
                                  ),
                                  maxLength: 1,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    counterText: '',
                                    filled: true,
                                    fillColor: const Color(0xFFF1F5F2),
                                    contentPadding: EdgeInsets.zero,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFD1DDD6)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.primaryGreen,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) => _onDigitChanged(index, val),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 32),

                          // Verify Button
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: AppColors.brandEmeraldGradient,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withOpacity(0.35),
                                  blurRadius: 14,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () => _verifyOtp(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'VERIFY & CONTINUE',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Resend OTP Countdown
                          Center(
                            child: _countdown > 0
                                ? Text(
                                    "Didn't receive code? Resend in ${_countdown}s",
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: AppColors.textSecondaryLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                : TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () {
                                            context.read<PhoneAuthBloc>().add(
                                                  SendPhoneOtpEvent(phoneNumber: widget.phoneNumber),
                                                );
                                          },
                                    child: const Text(
                                      'Resend OTP Code',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.brandOrange,
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
