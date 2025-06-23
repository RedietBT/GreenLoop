import 'package:dartz/dartz.dart';
import 'package:greenloop/core/errors/exceptions.dart';
import 'package:greenloop/core/errors/failure.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/pickup_request/data/datasources/pickup_request_remote_data_source.dart';
import 'package:greenloop/src/pickup_request/domain/entities/pickup_request.dart';
import 'package:greenloop/src/pickup_request/domain/repos/pickup_request_repo.dart';

class PickupRequestRepoImpl implements PickupRequestRepo {
  final PickupRequestRemoteDataSource _remoteDataSource;

  PickupRequestRepoImpl(this._remoteDataSource);

  @override
  ResultFuture<List<PickupRequest>> getPickupRequests(
      String recyclingCenterId) async {
    try {
      final result =
          await _remoteDataSource.getPickupRequests(recyclingCenterId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }

  @override
  ResultFuture<void> updatePickupRequestStatus(
      {required String requestId, required String status}) async {
    try {
      await _remoteDataSource.updatePickupRequestStatus(
          requestId: requestId, status: status);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure.fromException(e));
    }
  }
} 