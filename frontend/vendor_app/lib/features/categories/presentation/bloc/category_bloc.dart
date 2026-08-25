import 'package:flutter_bloc/flutter_bloc.dart';
import 'category_event.dart';
import 'category_state.dart';
import '../../domain/repositories/category_repository.dart';
import '../../../../core/error/failures.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc({required CategoryRepository categoryRepository})
      : _categoryRepository = categoryRepository,
        super(CategoryInitial()) {
    on<FetchCategoriesEvent>(_onFetchCategories);
    on<CreateCategorySubmittedEvent>(_onCreateCategory);
    on<UpdateCategorySubmittedEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onFetchCategories(
    FetchCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(CategoryListLoading());
    }
    try {
      final categories = await _categoryRepository.getCategories();
      emit(CategoryListLoaded(categories: categories));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(CategoryListError(message: message));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategorySubmittedEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryActionLoading());
    try {
      final category = await _categoryRepository.createCategory(
        name: event.name,
        description: event.description,
        image: event.image,
      );
      emit(CategoryActionSuccess(
        category: category,
        message: 'Category submitted successfully.\nWaiting for Admin approval.',
      ));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(CategoryActionError(message: message));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategorySubmittedEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryActionLoading());
    try {
      final category = await _categoryRepository.updateCategory(
        id: event.id,
        name: event.name,
        description: event.description,
        image: event.image,
      );
      emit(CategoryActionSuccess(
        category: category,
        message: 'Category updated and resubmitted for approval successfully.',
      ));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(CategoryActionError(message: message));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryActionLoading());
    try {
      await _categoryRepository.deleteCategory(event.id);
      emit(const CategoryDeleteSuccess(message: 'Category deleted successfully'));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(CategoryActionError(message: message));
    }
  }
}
