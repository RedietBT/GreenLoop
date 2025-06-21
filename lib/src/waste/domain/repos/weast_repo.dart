import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';
import 'package:greenloop/src/waste/domain/entitty/weste.dart';

abstract class WeastRepo {
  const WeastRepo();

  ResultFuture<void> insertWeastProfile(
    String weastId, 
     String userId,
     String type,
     String quantity,
     String location,
  );
  ResultFuture<Weast> updateWeastProfile({
   required String weastId, 
    required Map<String, dynamic> data,
  });
  ResultFuture<List<Recycling_User>> fetchRecylingCenters(String location);
 
  ResultFuture<void> requestForPickup(
     String id, 
     String userId,
     String weastId,
     String recyclingCenterId,
     String requestStatus,
  );
}