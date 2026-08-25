import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/dependency_injection/injection.dart' as di;
import 'core/dependency_injection/injection.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'features/wishlist/presentation/bloc/wishlist_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<WishlistBloc>.value(
          value: sl<WishlistBloc>()..add(const FetchWishlistEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Alanga',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
