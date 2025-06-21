import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';

class InsertWeastProfile {

 final WeastRepo repository;

  InsertWeastProfile(this.repository);

  ResultFuture<void> call(
    String weastId, 
     String userId,
     String type,
     String quantity,
     String location,
  ) async {
    return await repository.insertWeastProfile(
      weastId,
      userId,
      type,
      quantity,
      location,
    );
  }
}