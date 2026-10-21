import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/phone_auth/phone_auth_bloc.dart';
import '../bloc/phone_auth/phone_auth_event.dart';
import '../bloc/phone_auth/phone_auth_state.dart';
import '../../../../core/dependency_injection/injection.dart';
import '../../../../core/constants/app_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final int? resendToken;
  final bool isRegister;
  final String? fullName;
  final String? businessName;
  final String? email;

  const OtpVerificationScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
    this.isRegister = false,
    this.fullName,
    this.businessName,
    this.email,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<FocusNode> _keyboardFocusNodes = List.generate(6, (_) => FocusNode());

  late String _currentVerificationId;
  int? _currentResendToken;
  int _countdown = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentVerificationId = widget.verificationId;
    _currentResendToken = widget.resendToken;
    _startTimer();

    for (final node in _focusNodes) {
      node.addListener(_onFocusChange);
    }
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
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
    for (final node in _focusNodes) {
      node.removeListener(_onFocusChange);
      node.dispose();
    }
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _keyboardFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      // Handle paste of complete 6-digit OTP
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
    } else {
      // If user tapped backspace and cleared the current box, move to previous box
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
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
          VerifyOtpEvent(
            verificationId: _currentVerificationId,
            smsCode: _otpCode,
            phoneNumber: widget.phoneNumber,
            fullName: widget.fullName,
            businessName: widget.businessName,
            email: widget.email,
          ),
        );
  }

  void _resendCode(BuildContext context) {
    if (_countdown > 0) return;

    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();

    context.read<PhoneAuthBloc>().add(
          SendOtpEvent(
            phoneNumber: widget.phoneNumber,
            forceResendingToken: _currentResendToken,
          ),
        );
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (_) => sl<PhoneAuthBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFE6EFEA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF11261B), size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: size.width < 360 ? 14 : 20,
              vertical: 12,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: BlocConsumer<PhoneAuthBloc, PhoneAuthState>(
                listener: (context, state) {
                  if (state is PhoneAuthSuccessState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Welcome, ${state.user.fullName}! Authentication successful.'),
                        backgroundColor: const Color(0xFF1A3827),
                      ),
                    );
                    context.go('/home');
                  } else if (state is PhoneAuthCodeSentState) {
                    setState(() {
                      _currentVerificationId = state.verificationId;
                      _currentResendToken = state.resendToken;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('A new OTP has been sent to your mobile number.'),
                        backgroundColor: Color(0xFF1A3827),
                      ),
                    );
                  } else if (state is PhoneAuthFailureState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.errorMessage),
                        backgroundColor: AppColors.brandRed,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is PhoneAuthLoading;
                  final cardPaddingH = size.width < 360
                      ? 14.0
                      : (size.width < 400 ? 18.0 : 22.0);

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: cardPaddingH,
                      vertical: 30,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Icon header
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1A3827).withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.mark_email_read_outlined,
                              color: Color(0xFF1A3827),
                              size: 34,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Title
                        const Text(
                          'OTP Verification',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF11261B),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Phone text
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: 'We have sent a 6-digit verification code to\n',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF7A9A86),
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text: widget.phoneNumber,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF11261B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Change phone number button
                        Center(
                          child: TextButton.icon(
                            onPressed: () => context.pop(),
                            icon: const Icon(Icons.edit_outlined, size: 14, color: AppColors.brandOrange),
                            label: const Text(
                              'Edit Phone Number',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.brandOrange,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 6-digit PIN input fields (Guaranteed fit across all screens)
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final availableWidth = constraints.maxWidth;
                            final double gap = availableWidth < 280
                                ? 4.0
                                : (availableWidth < 320 ? 6.0 : 8.0);
                            final double totalGaps = gap * 5;

                            final double calculatedWidth =
                                ((availableWidth - totalGaps) / 6).floorToDouble();
                            final double boxWidth = calculatedWidth.clamp(34.0, 48.0);
                            final double boxHeight = (boxWidth * 1.18).clamp(44.0, 56.0);
                            final double fontSize = (boxWidth * 0.44).clamp(16.0, 21.0);
                            final double totalRowWidth = (boxWidth * 6) + totalGaps;

                            return Center(
                              child: SizedBox(
                                width: totalRowWidth,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: List.generate(6, (index) {
                                    final isFocused = _focusNodes[index].hasFocus;
                                    final isFilled = _controllers[index].text.isNotEmpty;

                                    return SizedBox(
                                      width: boxWidth,
                                      height: boxHeight,
                                      child: KeyboardListener(
                                        focusNode: _keyboardFocusNodes[index],
                                        onKeyEvent: (event) {
                                          if (event is KeyDownEvent &&
                                              event.logicalKey == LogicalKeyboardKey.backspace &&
                                              _controllers[index].text.isEmpty &&
                                              index > 0) {
                                            _focusNodes[index - 1].requestFocus();
                                          }
                                        },
                                        child: TextField(
                                          controller: _controllers[index],
                                          focusNode: _focusNodes[index],
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          textAlignVertical: TextAlignVertical.center,
                                          maxLength: 1,
                                          style: TextStyle(
                                            fontSize: fontSize,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF11261B),
                                          ),
                                          decoration: InputDecoration(
                                            counterText: '',
                                            filled: true,
                                            fillColor: isFocused
                                                ? Colors.white
                                                : (isFilled
                                                    ? const Color(0xFFEAF3EE)
                                                    : const Color(0xFFF1F5F2)),
                                            contentPadding: EdgeInsets.zero,
                                            isDense: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(color: Color(0xFFD1DDD6)),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                color: isFilled
                                                    ? const Color(0xFF88B39B)
                                                    : const Color(0xFFD1DDD6),
                                                width: isFilled ? 1.5 : 1.0,
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: const BorderSide(
                                                color: Color(0xFF1A3827),
                                                width: 2.0,
                                              ),
                                            ),
                                          ),
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          onChanged: (val) => _onDigitChanged(index, val),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 28),

                        // Verify Button
                        ElevatedButton(
                          onPressed: isLoading ? null : () => _verifyOtp(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: const Color(0xFF1A3827),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
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
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20),

                        // Resend OTP Countdown / Action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _countdown > 0
                                  ? "Didn't receive code? "
                                  : "Didn't receive code? ",
                              style: const TextStyle(
                                color: Color(0xFF7A9A86),
                                fontSize: 13,
                              ),
                            ),
                            if (_countdown > 0)
                              Text(
                                'Resend in ${_countdown}s',
                                style: const TextStyle(
                                  color: Color(0xFF11261B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              )
                            else
                              InkWell(
                                onTap: isLoading ? null : () => _resendCode(context),
                                child: const Text(
                                  'Resend OTP',
                                  style: TextStyle(
                                    color: Color(0xFF1A3827),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                          ],
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
    );
  }
}
