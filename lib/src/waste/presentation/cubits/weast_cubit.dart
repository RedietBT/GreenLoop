import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greenloop/src/waste/domain/usecase/insert_weast_profile.dart';
import 'package:greenloop/src/waste/domain/usecase/update_weast_profile.dart';
import 'package:greenloop/src/waste/domain/usecase/fetch_recyling_profile.dart';
import 'package:greenloop/src/waste/domain/usecase/fetch_closest_recycling_centers.dart';
import 'package:greenloop/src/waste/domain/usecase/request_for_pickup.dart';
import 'package:greenloop/src/waste/presentation/cubits/weast_state.dart';
import 'package:latlong2/latlong.dart';

class WeastCubit  extends Cubit<WeastState>{

  final InsertWeastProfile _insertWeastProfile;
  final UpdateWeastProfile _updateWeastProfile;
  final FetchRecylingCenters _fetchRecylingCenters;
  final FetchClosestRecyclingCenters _fetchClosestRecyclingCenters;
  final RequestForPickup _requestForPickup;

  WeastCubit({
    required InsertWeastProfile insertWeastProfile,
    required UpdateWeastProfile updateWeastProfile,
    required FetchRecylingCenters fetchRecylingCenters,
    required FetchClosestRecyclingCenters fetchClosestRecyclingCenters,
    required RequestForPickup requestForPickup,
  }) : _insertWeastProfile = insertWeastProfile,
       _updateWeastProfile = updateWeastProfile,
       _fetchRecylingCenters = fetchRecylingCenters,
       _fetchClosestRecyclingCenters = fetchClosestRecyclingCenters,
       _requestForPickup = requestForPickup,
       super(WeastInitial());

  Future<void> insertWeast({
    required String weastId,
    required String userId,
    required String type,
    required String quantity,
    required LatLng? location,
    Function()? onSuccess,
  }) async {
    emit(WeastLoading());
    final result = await _insertWeastProfile(
      weastId,
      userId,
      type,
      quantity,
      location,
    );
    result.fold(
      (failure) => emit(WeastError(failure.errorMassage)),
      (_) {
        emit(WeastInserted());
        if (onSuccess != null) {
          onSuccess();
        }
      },
    );
  }

  Future<void> updateWeast({
    required String weastId,
    required Map<String, dynamic> data,
  }) async {
    emit(WeastUpdating());
    final result = await _updateWeastProfile(
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
    final result = await _fetchRecylingCenters(location);
    result.fold(
      (failure) => emit(WeastError(failure.errorMassage)),
      (recyclingCenters) => emit(RecyclingCentersLoaded(recyclingCenters)),
    );
  }

  Future<void> fetchClosestRecyclingCenters(LatLng userLocation) async {
    emit(WeastLoading());
    final result = await _fetchClosestRecyclingCenters(userLocation);
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
    final result = await _requestForPickup(
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