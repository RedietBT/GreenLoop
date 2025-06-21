import 'package:greenloop/core/utils/typedefs.dart';
import 'package:greenloop/src/profile/recycling/domain/entity/recycling_user.dart';
import 'package:greenloop/src/waste/domain/repos/weast_repo.dart';

class FetchRecylingCenters {

  final WeastRepo repository;
  FetchRecylingCenters(this.repository);

  ResultFuture<List<Recycling_User>> call(String location) async {
    return await repository.fetchRecylingCenters(location);
  }
}