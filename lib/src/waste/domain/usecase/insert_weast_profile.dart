import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';

class InsertWeastProfile {

 final WeastRepo repository;

  InsertWeastProfile(this.repository);

  Future<void> call(
    String weastId, {
    required String userId,
    required String type,
    required String quantity,
    required String location,
    required String requestStatus,
  }) async {
    await repository.insertWeastProfile(
      weastId,
      userId: userId,
      type: type,
      quantity: quantity,
      location: location,
      requestStatus: requestStatus,
    );
  }
}