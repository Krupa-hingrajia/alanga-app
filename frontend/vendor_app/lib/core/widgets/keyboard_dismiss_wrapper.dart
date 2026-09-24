import 'package:flutter/material.dart';

/// Global keyboard dismissal wrapper that provides:
/// 1. Tap-anywhere-outside to unfocus/dismiss active keyboard.
/// 2. Floating "Done" accessory toolbar directly above numeric and text keyboards,
///    solving the native iOS issue where the numeric pad has no return/done key.
class KeyboardDismissWrapper extends StatelessWidget {
  final Widget child;

  const KeyboardDismissWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 80;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (isKeyboardOpen)
            Positioned(
              left: 0,
              right: 0,
              bottom: bottomInset,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF5F1),
                    border: Border(
                      top: BorderSide(color: const Color(0xFFD6E4DB), width: 1),
                      bottom: BorderSide(color: const Color(0xFFD6E4DB), width: 1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.keyboard_outlined, size: 15, color: Color(0xFF5A7565)),
                          SizedBox(width: 6),
                          Text(
                            'Alanga Input',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF5A7565),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A3827),
                            borderRadius: BorderRadius.circular(7),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1A3827).withValues(alpha: 0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Done',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.keyboard_hide_rounded, color: Colors.white, size: 13),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
