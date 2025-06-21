import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/waste/domain/entitty/weste.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';

class InsertWeastProfile {

 final WeastRepo repository;

  InsertWeastProfile(this.repository);

  ResultFuture<Weast> call(
    String weastId, {
    required String userId,
    required String type,
    required String quantity,
    required String location,
    required String requestStatus,
  }) async {
    return await repository.insertWeastProfile(
      weastId,
      userId: userId,
      type: type,
      quantity: quantity,
      location: location,
      requestStatus: requestStatus,
    );
  }
}