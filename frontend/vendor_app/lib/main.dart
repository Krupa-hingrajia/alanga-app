import 'package:flutter/material.dart';
import 'core/dependency_injection/injection.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/widgets/keyboard_dismiss_wrapper.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Alanga Vendor',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return KeyboardDismissWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
