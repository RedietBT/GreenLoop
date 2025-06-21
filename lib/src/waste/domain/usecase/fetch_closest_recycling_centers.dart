import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';
import 'package:latlong2/latlong.dart';

class FetchClosestRecyclingCenters {

  final WeastRepo repository;
  FetchClosestRecyclingCenters(this.repository);

  ResultFuture<List<Recycling_User>> call(LatLng userLocation) async {
    return await repository.fetchClosestRecyclingCenters(userLocation);
  }
} 