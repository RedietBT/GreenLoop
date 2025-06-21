import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/auth/domain/entity/resycling_user.dart';
import 'package:greenloop/src/waste/domain/entitty/weste.dart';

abstract class WeastRepo {
  const WeastRepo();

  ResultFuture<Weast> insertWeastProfile(String weastId, {
    required String userId,
    required String type,
    required String quantity,
    required String location,
    required String requestStatus,
  });
  ResultFuture<Weast> updateWeastProfile(
    String weastId, {
    required Map<String, dynamic> data,
  });
  ResultFuture<ResyclingUser> fetchRecylingProfile(String resyclingId);
 
  ResultFuture<Weast> requestForPickup(String id, {
    required String userId,
    required String weastId,
    required String recyclingCenterId,
    required String location,
    required String requestStatus,
  });
}