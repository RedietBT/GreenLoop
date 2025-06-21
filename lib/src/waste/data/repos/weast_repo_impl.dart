import 'package:dartz/dartz.dart';
import 'package:greenloop/core/errors/failure.dart';
import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';
import 'package:greenloop/src/waste/data/dataSource/weast_remot_data_source.dart';
import 'package:greenloop/src/waste/domain/entitty/weste.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';

class WeastRepoImpl implements WeastRepo{

  final WeastRemotDataSource remoteDataSource;
  const WeastRepoImpl(this.remoteDataSource);

  @override
  ResultFuture<void> insertWeastProfile(
     String weastId,
     String userId,
     String type,
     String quantity,
     String location,
     String requestStatus,
  ) async {
    try {
       await remoteDataSource.insertWeastProfile(
        weastId,
        userId,
        type,
        quantity,
        location,
        requestStatus,
      );
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultFuture<Weast> updateWeastProfile({
    required String weastId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final updatedWeast = await remoteDataSource.updateWeastProfile(
        weastId: weastId,
        updates: data,
      );
      return Right(updatedWeast);
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultFuture<void> requestForPickup(
     String id, 
     String userId,
     String weastId,
     String recyclingCenterId,
     String requestStatus,
  ) async {
    try {
      await remoteDataSource.requestForPickup(
        id,
        userId,
        weastId,
        recyclingCenterId,
        requestStatus,
      );
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }

  @override
  ResultFuture<Recycling_User> fetchRecylingProfile(String resyclingId) async {
    try {
      final profile = await remoteDataSource.fetchRecylingProfile(resyclingId);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(
        message: e.toString(),
        statusCode: '500',
      ));
    }
  }
}