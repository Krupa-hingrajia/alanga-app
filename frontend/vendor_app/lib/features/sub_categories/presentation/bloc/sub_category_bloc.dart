import 'package:flutter_bloc/flutter_bloc.dart';
import 'sub_category_event.dart';
import 'sub_category_state.dart';
import '../../domain/repositories/sub_category_repository.dart';
import '../../../../core/error/failures.dart';

class SubCategoryBloc extends Bloc<SubCategoryEvent, SubCategoryState> {
  final SubCategoryRepository _subCategoryRepository;

  SubCategoryBloc({required SubCategoryRepository subCategoryRepository})
      : _subCategoryRepository = subCategoryRepository,
        super(SubCategoryInitial()) {
    on<FetchSubCategoriesEvent>(_onFetchSubCategories);
    on<CreateSubCategorySubmittedEvent>(_onCreateSubCategory);
    on<UpdateSubCategorySubmittedEvent>(_onUpdateSubCategory);
    on<DeleteSubCategoryEvent>(_onDeleteSubCategory);
  }

  Future<void> _onFetchSubCategories(
    FetchSubCategoriesEvent event,
    Emitter<SubCategoryState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(SubCategoryListLoading());
    }
    try {
      final subCategories = await _subCategoryRepository.getSubCategories();
      emit(SubCategoryListLoaded(subCategories: subCategories));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(SubCategoryListError(message: message));
    }
  }

  Future<void> _onCreateSubCategory(
    CreateSubCategorySubmittedEvent event,
    Emitter<SubCategoryState> emit,
  ) async {
    emit(SubCategoryActionLoading());
    try {
      final subCategory = await _subCategoryRepository.createSubCategory(
        categoryId: event.categoryId,
        name: event.name,
        description: event.description,
        image: event.image,
      );
      emit(SubCategoryActionSuccess(
        subCategory: subCategory,
        message: 'SubCategory submitted successfully.\nWaiting for Admin approval.',
      ));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(SubCategoryActionError(message: message));
    }
  }

  Future<void> _onUpdateSubCategory(
    UpdateSubCategorySubmittedEvent event,
    Emitter<SubCategoryState> emit,
  ) async {
    emit(SubCategoryActionLoading());
    try {
      final subCategory = await _subCategoryRepository.updateSubCategory(
        id: event.id,
        categoryId: event.categoryId,
        name: event.name,
        description: event.description,
        image: event.image,
      );
      emit(SubCategoryActionSuccess(
        subCategory: subCategory,
        message: 'SubCategory updated and resubmitted for approval successfully.',
      ));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(SubCategoryActionError(message: message));
    }
  }

  Future<void> _onDeleteSubCategory(
    DeleteSubCategoryEvent event,
    Emitter<SubCategoryState> emit,
  ) async {
    emit(SubCategoryActionLoading());
    try {
      await _subCategoryRepository.deleteSubCategory(event.id);
      emit(const SubCategoryDeleteSuccess(message: 'SubCategory deleted successfully'));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(SubCategoryActionError(message: message));
    }
  }
}
