import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/category_cache.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final CategoryRepository _categoryRepository;
  final ProductRepository _productRepository;

  HomeBloc({
    required CategoryRepository categoryRepository,
    required ProductRepository productRepository,
  })  : _categoryRepository = categoryRepository,
        _productRepository = productRepository,
        super(HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(HomeLoading());
    }
    try {
      final results = await Future.wait([
        _categoryRepository.getCategories(),
        _productRepository.getProducts(),
      ]);

      final categories = results[0] as List<dynamic>;
      final products = results[1] as List<dynamic>;

      // Populate Cache
      CategoryCache.addAll(categories);

      // Ensure we cast appropriately
      emit(HomeLoaded(
        categories: categories.cast(),
        products: products.cast(),
      ));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(HomeError(message: message));
    }
  }
}
