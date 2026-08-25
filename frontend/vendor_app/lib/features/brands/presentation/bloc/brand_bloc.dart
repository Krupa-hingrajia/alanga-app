import 'package:flutter_bloc/flutter_bloc.dart';
import 'brand_event.dart';
import 'brand_state.dart';
import '../../domain/repositories/brand_repository.dart';
import '../../../../core/error/failures.dart';

class BrandBloc extends Bloc<BrandEvent, BrandState> {
  final BrandRepository _brandRepository;

  BrandBloc({required BrandRepository brandRepository})
      : _brandRepository = brandRepository,
        super(BrandInitial()) {
    on<FetchBrandsEvent>(_onFetchBrands);
    on<CreateBrandSubmittedEvent>(_onCreateBrand);
    on<UpdateBrandSubmittedEvent>(_onUpdateBrand);
    on<DeleteBrandEvent>(_onDeleteBrand);
  }

  Future<void> _onFetchBrands(
    FetchBrandsEvent event,
    Emitter<BrandState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(BrandListLoading());
    }
    try {
      final brands = await _brandRepository.getBrands();
      emit(BrandListLoaded(brands: brands));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(BrandListError(message: message));
    }
  }

  Future<void> _onCreateBrand(
    CreateBrandSubmittedEvent event,
    Emitter<BrandState> emit,
  ) async {
    emit(BrandActionLoading());
    try {
      final brand = await _brandRepository.createBrand(
        name: event.name,
        description: event.description,
        image: event.image,
      );
      emit(BrandActionSuccess(
        brand: brand,
        message: 'Brand submitted successfully.\nWaiting for Admin approval.',
      ));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(BrandActionError(message: message));
    }
  }

  Future<void> _onUpdateBrand(
    UpdateBrandSubmittedEvent event,
    Emitter<BrandState> emit,
  ) async {
    emit(BrandActionLoading());
    try {
      final brand = await _brandRepository.updateBrand(
        id: event.id,
        name: event.name,
        description: event.description,
        image: event.image,
      );
      emit(BrandActionSuccess(
        brand: brand,
        message: 'Brand updated and resubmitted for approval successfully.',
      ));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(BrandActionError(message: message));
    }
  }

  Future<void> _onDeleteBrand(
    DeleteBrandEvent event,
    Emitter<BrandState> emit,
  ) async {
    emit(BrandActionLoading());
    try {
      await _brandRepository.deleteBrand(event.id);
      emit(const BrandDeleteSuccess(message: 'Brand deleted successfully'));
    } catch (e) {
      String message = 'An error occurred';
      if (e is ServerFailure) {
        message = e.message;
      }
      emit(BrandActionError(message: message));
    }
  }
}
