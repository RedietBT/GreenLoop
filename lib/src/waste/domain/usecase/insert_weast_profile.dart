import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';
import 'package:latlong2/latlong.dart';

class InsertWeastProfile {

 final WeastRepo repository;

  InsertWeastProfile(this.repository);

  ResultFuture<void> call(
    String weastId, 
     String userId,
     String type,
     String quantity,
     LatLng? location,
     String userType,
  ) async {
    return await repository.insertWeastProfile(
      weastId,
      userId,
      type,
      quantity,
      location,
      userType,
    );
  }
}