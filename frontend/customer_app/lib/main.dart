import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/dependency_injection/injection.dart' as di;
import 'core/dependency_injection/injection.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'features/wishlist/presentation/bloc/wishlist_bloc.dart';
import 'features/wishlist/presentation/bloc/wishlist_event.dart';
import 'features/cart/presentation/bloc/cart_cubit.dart';
import 'features/addresses/presentation/bloc/address_cubit.dart';
import 'features/checkout/presentation/bloc/checkout_cubit.dart';
import 'features/checkout/presentation/bloc/order_cubit.dart';

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
        BlocProvider<CartCubit>.value(
          value: sl<CartCubit>()..fetchCart(),
        ),
        BlocProvider<AddressCubit>.value(
          value: sl<AddressCubit>()..fetchAddresses(),
        ),
        BlocProvider<CheckoutCubit>.value(
          value: sl<CheckoutCubit>(),
        ),
        BlocProvider<OrderCubit>.value(
          value: sl<OrderCubit>(),
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
