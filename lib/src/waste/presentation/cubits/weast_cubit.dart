import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';
import 'package:greenloop/src/waste/presentation/cubits/weast_state.dart';

class WeastCubit  extends Cubit<WeastState>{

  final WeastRepo weastRepo;
  WeastCubit(this.weastRepo) : super(WeastInitial());

  Future<void> insertWeast({
    required String weastId,
    required String userId,
    required String type,
    required String quantity,
    required String location,
  }) async {
    emit(WeastLoading());
    final result = await weastRepo.insertWeastProfile(
      weastId,
      userId,
      type,
      quantity,
      location,
    );
    result.fold(
      (failure) => emit(WeastError(failure.errorMassage)),
      (_) => emit(WeastInserted()),
    );
  }

  Future<void> updateWeast({
    required String weastId,
    required Map<String, dynamic> data,
  }) async {
    emit(WeastUpdating());
    final result = await weastRepo.updateWeastProfile(
      weastId: weastId,
      data: data,
    );
    result.fold(
      (failure) => emit(WeastError(failure.errorMassage)),
      (weast) => emit(WeastLoaded(weast)),
    );
  }

  Future<void> fetchRecyclingCenters(String location) async {
    emit(WeastLoading());
    final result = await weastRepo.fetchRecylingCenters(location);
    result.fold(
      (failure) => emit(WeastError(failure.errorMassage)),
      (recyclingCenters) => emit(RecyclingCentersLoaded(recyclingCenters)),
    );
  }

  Future<void> requestForPickup({
    required String id,
    required String userId,
    required String weastId,
    required String recyclingCenterId,
    required String requestStatus,
  }) async {
    emit(WeastLoading());
    final result = await weastRepo.requestForPickup(
      id,
      userId,
      weastId,
      recyclingCenterId,
      requestStatus,
    );
    result.fold(
      (failure) => emit(WeastError(failure.errorMassage)),
      (_) => emit(WeastRequestPickup()),
    );
  }
}